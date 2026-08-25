-- totalmayhem_v121_fix: 禁用 8 个停机坪 (Ground Tarmac Big / Small) 的建造
-- 停机坪同时具备两条建造路径, 都要剥:
--   * 菜单建造 (BUILDBY* 玩家 / BUILDAI* AI) —— 工程师建造菜单用
--   * 拖拽建造 (DRAGBUILD) —— 停机坪是地面涂装, 实际靠拖拽放置, 此路不查 BUILDBY*
-- 只剥 DRAGBUILD 拦不住菜单、只剥 BUILDBY* 拦不住拖拽, 所以全剥.
-- 目标单位: BRMGRND1/2 (Cybran), BRNGRND1/2 (UEF), BROGRND1/2 (Aeon), BRPGRND1/2 (Seraphim)
--
-- ★ 实现铁律: 绝不用 table.removeByValue 删「数组里连续的多个元素」!
--   FA 定制 Lua 的 table.removeByValue = `for k,v in pairs(t) do if v==val then table.remove(t,k) end end`,
--   在「连续多条待删项」(如这里下标 3~6 紧挨的 4 个 BUILDBY*) 上边遍历边删会静默失效,
--   真机实测 after==before; 而孤立单条 (如末尾 DRAGBUILD) 反而能删. 这是 BlackOps 同款写法
--   在你这 4 连删场景失效的根因. 改用「手动重建数组」—— 遍历一次把保留项塞进新表、整体
--   赋值, 纯 table 语义、与 Lua 实现无关, 100% 确定生效.
--
-- 已确认禁造生效 (v1.1.8, 用户实机复测), 调试 LOG 已移除.

do
    local oldModBlueprints = ModBlueprints

    -- 要剥离的建造类目 (精确字符串集合, 表键查找, 不依赖任何 string.*)
    -- ★ 拼写铁律: 真值是 "BUILT-BY" -> BUILT**B**Y (带 T), 不是 BUILD**B**Y (带 D)!
    --   TotalMayhem 全工程 66 处建造分类都是 BUILTBY (T), 零处 BUILDBY (D).
    --   v1.1.2~v1.1.7 一路失效的真正元凶就是这个 D/T 笔误 (误以为是 string.sub 不可靠).
    local REMOVE = {
        BUILTBYTIER1ENGINEER = true,
        BUILTBYTIER2ENGINEER = true,
        BUILTBYTIER3ENGINEER = true,
        BUILTBYCOMMANDER     = true,
        BUILTAITIER1ENGINEER = true,   -- 防御性: TM 当前无 AI 类目, 有则一并剥
        BUILTAITIER2ENGINEER = true,
        BUILTAITIER3ENGINEER = true,
        BUILTAICOMMANDER     = true,
        DRAGBUILD            = true,   -- 拖拽建造闸门
    }

    function ModBlueprints(all_bps)
        oldModBlueprints(all_bps)

        local tarmacs = {
            'brmgrnd1', 'brmgrnd2',   -- Cybran
            'brngrnd1', 'brngrnd2',   -- UEF
            'brogrnd1', 'brogrnd2',   -- Aeon
            'brpgrnd1', 'brpgrnd2',   -- Seraphim
        }

        for k, uid in pairs(tarmacs) do
            if all_bps.Unit[uid] and all_bps.Unit[uid].Categories then
                local cats = all_bps.Unit[uid].Categories
                -- 手动重建: 收集「不在 REMOVE 里」的类目, 整体替换. 不做原地删除.
                local newcats = {}
                local removed = 0
                for _, v in pairs(cats) do
                    if not REMOVE[v] then
                        table.insert(newcats, v)
                    else
                        removed = removed + 1
                    end
                end
                all_bps.Unit[uid].Categories = newcats
            end
        end
    end
end
