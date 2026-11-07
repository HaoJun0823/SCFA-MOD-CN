--[[
    BlackOps V6 Unlock T4 / 第 1 层：补「蓝图层面的建造权限」

    背景（SCFA 的建造权限模型）：
      每个单位蓝图有两个关键字段：
        Categories            —— 这个单位「自己带什么标签」
        Economy.BuildableCategory —— 这个单位「能建带什么标签的单位」
      一个建造者能造某单位，当且仅当被造单位的 Categories 满足建造者
      BuildableCategory 里的某一条表达式（一条里空格 = AND，多条之间 = OR）。

    BlackOpsBalance 的做法是：给一批实验级 / T4 单位打上专属标签
    'BUILTBYTIER4COMMANDER'，并把这个标签写进 ACU / SCU / T3 工程师的
    BuildableCategory，于是「蓝图层面」它们其实是能造的；真正的门槛是
    第 2 层（sim/Unit.lua 里 hook 的运行时 AddBuildRestriction）。

    本文件的作用：兜底保证这个蓝图权限一定存在。
      - 万一用户没启用 BlackOpsBalance，或者别的模组覆盖 / 重置了
        BuildableCategory，T3 工程师依然能造这些单位。
      - 也能自动覆盖其它模组新增的 T3 工程师，不用逐个列单位 ID。

    注意加载顺序：FA 把所有 hook/lua/system/Blueprints.lua 依次挂载成一条
    ModBlueprints 调用链，最后加载的模组处在「最外层」。本模组通过
    mod_info.lua 的 after 排在所有 BlackOps 之后，所以本函数最先被调用。
    这里「先调用旧链、再做自己的收尾」，可保证我们的修改发生在所有
    BlackOps 蓝图改动之后，不会被它们覆盖回去。
]]

local oldModBlueprints = ModBlueprints

local FACTION_LIST = { 'UEF', 'AEON', 'CYBRAN', 'SERAPHIM' }

local function HasCategory(bp, wanted)
    if not bp.Categories then return false end
    for _, cat in bp.Categories do
        if cat == wanted then return true end
    end
    return false
end

local function FactionOf(bp)
    for _, faction in FACTION_LIST do
        if HasCategory(bp, faction) then return faction end
    end
    return nil
end

local function HasBuildableCategory(bp, wanted)
    for _, expr in bp.Economy.BuildableCategory do
        if expr == wanted then return true end
    end
    return false
end

function ModBlueprints(all_bps)
    -- 先让源模组把蓝图改完，我们最后收尾
    oldModBlueprints(all_bps)

    if not all_bps.Unit then return end

    local t4Count = 0
    local patchedBuilders = 0

    for id, bp in all_bps.Unit do
        if HasCategory(bp, 'BUILTBYTIER4COMMANDER') then
            t4Count = t4Count + 1
        end

        -- 只给「指挥官 / 副指挥官 / T3 工程师」补权限。
        -- 故意不给 T1、T2 工程师，也不给 T3 工厂：T4 依旧是后期科技，
        -- 只是不再额外要求 ACU 先做完 T4 工程升级而已。
        local isCommander = HasCategory(bp, 'COMMAND') or HasCategory(bp, 'SUBCOMMANDER')
        local isT3Engineer = HasCategory(bp, 'ENGINEER') and HasCategory(bp, 'TECH3')
        local faction = FactionOf(bp)

        if faction and (isCommander or isT3Engineer)
           and bp.Economy and type(bp.Economy.BuildableCategory) == 'table' then

            -- 例：'BUILTBYTIER4COMMANDER UEF'
            -- 要求被造单位同时带 BUILTBYTIER4COMMANDER 和 UEF 两个标签。
            local expr = 'BUILTBYTIER4COMMANDER ' .. faction
            if not HasBuildableCategory(bp, expr) then
                table.insert(bp.Economy.BuildableCategory, expr)
                patchedBuilders = patchedBuilders + 1
            end
        end
    end

    LOG('[BlackOps Unlock T4] blueprints: ' .. t4Count ..
        ' T4/experimental units, ' .. patchedBuilders ..
        ' builders granted BUILTBYTIER4COMMANDER')
end
