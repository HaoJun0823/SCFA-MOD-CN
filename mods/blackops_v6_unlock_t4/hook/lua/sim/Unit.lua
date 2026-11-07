--[[
    BlackOps V6 Unlock T4 / 第 2 层：撤销「运行时」的 T4 建造禁令（核心）

    BlackOps 真正的门槛不在蓝图，而在 sim 侧脚本：
      * BlackOpsBalance/hook/units/???0001/*_script.lua   （原版四族 ACU）
        OnCreate() 里：self:AddBuildRestriction( 阵营 * BUILTBYTIER4COMMANDER )
      * BlackOpsBalance/hook/units/???0309/*_script.lua   （四族 T3 工程师）
        OnCreate() 里：人类玩家同样被加上这条限制
      * BlackOpsACUs/units/E??0001/*_script.lua           （ACUs 模组的自定义 ACU）
        一模一样的写法（该模组把开局单位换成了 eel0001/eal0001/erl0001/esl0001）
      * 上述脚本的 CreateEnhancement() 里，T3EngineeringRemove /
        T4EngineeringRemove / AdvancedEngineeringRemove 等分支会先
        RestoreBuildRestrictions() 再把这条限制重新加回去。

    只有完成 ACU 的「Tech 4 Engineering Suite」升级时，脚本才调用
    RemoveBuildRestriction() 解锁。这就是「必须做实验级升级才能造 T4」的由来。

    本补丁的做法（釜底抽薪，但不动蓝图的类别定义）：
      包装全局 Unit 类的 AddBuildRestriction。任何模组、任何单位、任何分支
      想加限制时，先照常让它加，然后立刻把「T4 那几条」精确移除。
      于是 ——
        - 不需要逐个复制 12 份 ACU / 工程师脚本，也不会丢失它们原有的
          升级 buff、武器、特效逻辑；
        - 升级拆卸、RestoreBuildRestrictions 之后重新加的限制同样会被撤掉；
        - 不动 BUILTBYTIER4COMMANDER 这个类别本身，避免出现
          categories.BUILTBYTIER4COMMANDER 为 nil 导致源脚本报错；
        - 只移除精确匹配的 T4 表达式，正常的
          UEF * (BUILTBYTIER2COMMANDER + BUILTBYTIER3COMMANDER) 等
          T2 / T3 科技限制完全保留，ACU 仍要按老路线升级。

    为什么 RemoveBuildRestriction 能精确命中：源模组自己就是这么写的 ——
    T4Engineering 分支用 ParseEntityCategory('BUILTBYTIER4COMMANDER UEF')
    去移除 OnCreate 加的 categories.UEF * categories.BUILTBYTIER4COMMANDER，
    两者是同一个 EntityCategory 表达式。本补丁复用完全相同的表达式。
]]

local oldUnit = Unit

-- 取当前链上的原始实现并保存为局部引用。
-- 用保存的引用调用，而不是 oldUnit.AddBuildRestriction(self, ...)，
-- 可以避免以后有别的模组再包装同名方法时形成递归调用。
local rawAddBuildRestriction = Unit.AddBuildRestriction

local t4Restrictions = nil

local function GetT4Restrictions()
    if t4Restrictions then return t4Restrictions end

    t4Restrictions = {}

    -- 延迟到第一次真正有人加建造限制时才构造，此时 categories 必然已就绪。
    -- pcall 是防御性的：万一某个精简模组把 BUILTBYTIER4COMMANDER 类别
    -- 整个删掉，也不会让本补丁在加载阶段抛错。
    local ok, t4 = pcall(function() return categories.BUILTBYTIER4COMMANDER end)
    if ok and t4 then
        table.insert(t4Restrictions, t4)
        table.insert(t4Restrictions, categories.UEF * t4)
        table.insert(t4Restrictions, categories.AEON * t4)
        table.insert(t4Restrictions, categories.CYBRAN * t4)
        table.insert(t4Restrictions, categories.SERAPHIM * t4)
    else
        WARN('[BlackOps Unlock T4] categories.BUILTBYTIER4COMMANDER not found; runtime unlock skipped')
    end

    return t4Restrictions
end

if rawAddBuildRestriction then
    Unit = Class(oldUnit) {
        AddBuildRestriction = function(self, cat)
            local restrictions = GetT4Restrictions()

            -- 首选路径：如果引擎的 EntityCategory 支持按内容比较，
            -- 认出这是 T4 限制就直接吞掉，根本不让它加进去。
            -- 这样连 RemoveBuildRestriction 的实现细节都不用依赖。
            for _, restriction in restrictions do
                if cat == restriction then return end
            end

            -- 兜底路径：EntityCategory 若只能按引用比较（不相等），
            -- 就照常加完再精确撤掉。源模组自己的 T4Engineering 分支
            -- 正是用同样的「相同表达式 Remove」来解锁的，行为可靠。
            rawAddBuildRestriction(self, cat)
            for _, restriction in restrictions do
                self:RemoveBuildRestriction(restriction)
            end
        end,
    }
else
    WARN('[BlackOps Unlock T4] Unit.AddBuildRestriction not found; runtime unlock skipped')
end
