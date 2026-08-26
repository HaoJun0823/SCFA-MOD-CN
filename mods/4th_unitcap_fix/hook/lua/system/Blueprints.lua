local oldModBP = ModBlueprints

function ModBlueprints(all_bps)
	-- 4th Dimension Unit Cap 1.0 的 hook 对缺少 Economy 的单位
	-- 在 STRUCTURE/DEFENSE 分支用 nil 的 capcosts 做算术导致崩溃。
	# 本修复位于 4th UnitCap hook 之后（外链先执行），先为缺失单位补最小
	# Economy / General / Categories 兜底，再调用原链，使 UnitCap 的
	# capcosts 计算始终有效（min enma 35 -> capcosts 0.15 -> STRUCTURE 0.075）。
	if all_bps.Unit then
		for id,bp in all_bps.Unit do
			if not bp.General then
				bp.General = { CapCost = 1 }
			end
			if not bp.Categories then
				bp.Categories = {}
			end
			if bp.Economy then
				if not bp.Economy.BuildCostMass then
					bp.Economy.BuildCostMass = 10
				end
				if not bp.Economy.BuildCostEnergy then
					bp.Economy.BuildCostEnergy = 1000
				end
			else
				bp.Economy = {
					BuildCostMass = 10,
					BuildCostEnergy = 1000,
				}
			end
		end
	end

	oldModBP(all_bps)
end