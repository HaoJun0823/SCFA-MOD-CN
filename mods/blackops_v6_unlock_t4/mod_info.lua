-- BlackOps V6 / T4 建造限制解除补丁
-- 依赖 6 个 BlackOps 源模组，并强制排在它们之后加载（after），
-- 这样本补丁的 hook 才是整条 ModBlueprints / Unit 链的最外层。
name = "BlackOps V6 Unlock T4"
uid = "A1B2C3D4-0000-0000-0000-BLACKOPSUT46"
version = 1
description = "解除 BlackOps V6 中「实验级 / T4 单位必须完成 T4 工程升级才能建造」的限制，让 T3 工程师、ACU、SCU 直接可建。By HaoJun0823."
author = "HaoJun0823"
url = "https://www.haojun0823.xyz/"
selectable = true
enabled = true
exclusive = false
-- 本补丁修改 sim 侧逻辑（建造限制），不是纯 UI 模组。
-- 联机时所有玩家必须启用同一套，否则会不同步。
ui_only = false
requires = {
    "9e8ea941-c306-4751-b367-a11000000600", -- BlackOpsUnleashed
    "9e8ea941-c306-4751-b367-e00000000302", -- BlackOpsACUs
    "9e8ea941-c306-4751-b367-a20000000502", -- BlackOpsBalance
    "9e8ea941-c306-4751-b367-e10000000104", -- BlackOpsEXUnits
    "9e8ea941-c306-4751-b367-e20000000102", -- BlackOpsNavalBalance
    "9e8ea941-c306-4751-b367-f00000000005", -- BlackOpsSupport
}
requiresNames = {
    "BlackOpsUnleashed",
    "BlackOpsACUs",
    "BlackOpsBalance",
    "BlackOpsEXUnits",
    "BlackOpsNavalBalance",
    "BlackOpsSupport",
}
conflicts = { }
after = {
    "9e8ea941-c306-4751-b367-a11000000600", -- BlackOpsUnleashed
    "9e8ea941-c306-4751-b367-e00000000302", -- BlackOpsACUs
    "9e8ea941-c306-4751-b367-a20000000502", -- BlackOpsBalance
    "9e8ea941-c306-4751-b367-e10000000104", -- BlackOpsEXUnits
    "9e8ea941-c306-4751-b367-e20000000102", -- BlackOpsNavalBalance
    "9e8ea941-c306-4751-b367-f00000000005", -- BlackOpsSupport
    "A1B2C3D4-0000-0000-0000-BLACKOPSBPF6", -- blackops_v6_fix
    "A1B2C3D4-0000-0000-0000-MODUNITCPFIX", -- unitcap_fix
}
before = { }
