-- BlackOps V6 简体中文补丁 · D类：Tooltips 表覆盖
-- 机制：本文件作为同名 hook 在 BlackOps 各模组定义 Tooltips 表之后追加运行，
--       直接覆盖全局 Tooltips 表的 title/description 中文值。
-- 注意：必须裸写 Tooltips['key'].xxx（禁止 local Tooltips = _G.Tooltips，
--       否则 _G 取不到 base 定义的全局表，会 nil 索引导致游戏卡死）。

do
    -- BlackOpsACUs
    Tooltips['exstealth_toggle'].title = '主动干扰子系统'
    Tooltips['exstealth_toggle'].description = '开启/关闭组合信号发生器与个人隐身系统'

    Tooltips['excloak_toggle'].title = '隐身子系统'
    Tooltips['excloak_toggle'].description = '开启/关闭高级隐身套件'

    Tooltips['exjammer_toggle'].title = '雷达干扰子系统'
    Tooltips['exjammer_toggle'].description = '开启/关闭雷达信号发生器'

    Tooltips['EXScryTarget'].title = '占卜瞄准'
    Tooltips['EXScryTarget'].description = '占卜术的目标区域'

    -- BlackOpsEXUnits
    Tooltips['exweapon_toggle1'].title = '防空炮'
    Tooltips['exweapon_toggle1'].description = '将TMD炮切换为防空高射炮模式'

    Tooltips['exweapon_toggle2'].title = '冰雹弹幕'
    Tooltips['exweapon_toggle2'].description = '将防空导弹切换为冰雹弹幕模式'

    Tooltips['exweapon_toggle3'].title = '鱼雷弹幕'
    Tooltips['exweapon_toggle3'].description = '将反鱼雷武器切换为鱼雷弹幕模式'

    -- BlackOpsUnleashed
    Tooltips['emp_nuke'].title = '发射EMP核弹'
    Tooltips['emp_nuke'].description = '发射EMP核弹'

    Tooltips['drone_recal'].title = '召回无人机'
    Tooltips['drone_recal'].description = '将无人机召回航母'

    Tooltips['drone_assist'].title = '无人机自动协战'
    Tooltips['drone_assist'].description = '切换无人机自动协战'

    Tooltips['lambda_field'].title = '拉姆达力场'
    Tooltips['lambda_field'].description = '开启/关闭所选单位的拉姆达力场'

    Tooltips['fire_wep'].title = '开火（主武器）'
    Tooltips['fire_wep'].description = '发射特殊武器'

    Tooltips['transform_stationary'].title = '固定模式'
    Tooltips['transform_stationary'].description = '将单位变形为固定模式'

    Tooltips['transform_mobile'].title = '机动模式'
    Tooltips['transform_mobile'].description = '将单位变形为机动模式'

    Tooltips['spoof_toggle'].title = '欺骗切换'
    Tooltips['spoof_toggle'].description = '开启/关闭所选单位的雷达欺骗'
end
