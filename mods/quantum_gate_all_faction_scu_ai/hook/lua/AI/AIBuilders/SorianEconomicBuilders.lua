#****************************************************************************
#**
#**	File:		hook/lua/AI/AIBuilders/SorianEconomicBuilders.lua
#**
#**	Description:	让 Sorian AI 通过量子门集齐四个阵营的副指挥官（SCU）。
#**
#**	机制（FA 原生 hook 拼接，无函数 monkeypatch）：
#**		本文件在加载期被「拼接（append）」到 base
#**		SorianEconomicBuilders.lua 的末尾。此时 base 文件里所有
#**		BuilderGroup 早已定义，可直接 table.insert 进目标组。
#**
#**	关键事实（已逐项核实源码）：
#**	1) Sorian 原生已会造量子门（Sorian T3 Gate Engineer，
#**	   BuildStructures={'T3QuantumGate'}）。主 mod 仅给标准门
#**	   (uab0304/ueb0304/urb0304/xsb0304) 追加 SUBCOMMANDER 类别，
#**	   门仍带 T3QuantumGate 类别，故原生即可建造 —— 无需我们再写
#**	   造门 builder。
#**	2) Sorian 原生门造 SCU 只产「本阵营」SCU（Sorian T3 Sub Commander，
#**	   BuilderType='Gate'，模板 T3LandSubCommander）。本文件补齐另外
#**	   三个阵营的 SCU，使 AI 集齐四阵营。
#**	3) 工程师造建筑的 builder 必须用 PlatoonTemplate='T3EngineerBuilderSorian'
#**	   + BuilderData.Construction.BuildStructures 格式；门造单位是
#**	   BuilderType='Gate' + PlatoonTemplate 内含 FactionSquads
#**	   （每项指向具体 SCU 单位 ID）。本文件严格照抄这两种原生格式。
#**
#**	注入目标：SorianEngineerFactoryBuilders（BuildersType='FactoryBuilder'，
#**	其中 BuilderType='Gate' 的 builder 由量子门工厂管理器读取，存在于
#**	所有 Sorian base template 的 Builders 列表）。纯数据操作，无覆盖函数。
#**
#**	依赖：	Sorian AI；主 mod quantum_gate_all_faction_scu（门可造 SUBCOMMANDER）
#**
#**	Copyright:	haojun0823
#**
#****************************************************************************

local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local SIBC = '/lua/editor/SorianInstantBuildConditions.lua'

# ---------- 4 个门造 SCU 模板：每个模板强制造「某特定阵营」的 SCU ----------
# 格式照抄 Sorian 原生 T3LandSubCommander 模板（FactionSquads 每项指向同一 SCU）。
PlatoonTemplate {
    Name = 'QG_AF_SCU_Aeon',
    FactionSquads = {
        UEF     = { { 'ual0301', 1, 1, 'support', 'none' } },
        Aeon    = { { 'ual0301', 1, 1, 'support', 'none' } },
        Cybran  = { { 'ual0301', 1, 1, 'support', 'none' } },
        Seraphim= { { 'ual0301', 1, 1, 'support', 'none' } },
    },
}

PlatoonTemplate {
    Name = 'QG_AF_SCU_UEF',
    FactionSquads = {
        UEF     = { { 'uel0301', 1, 1, 'support', 'none' } },
        Aeon    = { { 'uel0301', 1, 1, 'support', 'none' } },
        Cybran  = { { 'uel0301', 1, 1, 'support', 'none' } },
        Seraphim= { { 'uel0301', 1, 1, 'support', 'none' } },
    },
}

PlatoonTemplate {
    Name = 'QG_AF_SCU_Cybran',
    FactionSquads = {
        UEF     = { { 'url0301', 1, 1, 'support', 'none' } },
        Aeon    = { { 'url0301', 1, 1, 'support', 'none' } },
        Cybran  = { { 'url0301', 1, 1, 'support', 'none' } },
        Seraphim= { { 'url0301', 1, 1, 'support', 'none' } },
    },
}

PlatoonTemplate {
    Name = 'QG_AF_SCU_Seraphim',
    FactionSquads = {
        UEF     = { { 'xsl0301', 1, 1, 'support', 'none' } },
        Aeon    = { { 'xsl0301', 1, 1, 'support', 'none' } },
        Cybran  = { { 'xsl0301', 1, 1, 'support', 'none' } },
        Seraphim= { { 'xsl0301', 1, 1, 'support', 'none' } },
    },
}

# ---------- 4 个门造 SCU 的 Gate builder（注册进全局 Builders，返回名字） ----------
# BuilderType='Gate' 由量子门工厂管理器处理；限制每个阵营 SCU 最多 1 座，避免刷爆。
local QG_SCU_Aeon = Builder {
    BuilderName = 'QG AllFaction SCU - Aeon',
    PlatoonTemplate = 'QG_AF_SCU_Aeon',
    Priority = 1000,
    BuilderConditions = {
        { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.5, 0.8 } },
        { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.AEON * categories.SUBCOMMANDER } },
    },
    BuilderType = 'Gate',
}

local QG_SCU_UEF = Builder {
    BuilderName = 'QG AllFaction SCU - UEF',
    PlatoonTemplate = 'QG_AF_SCU_UEF',
    Priority = 1000,
    BuilderConditions = {
        { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.5, 0.8 } },
        { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.UEF * categories.SUBCOMMANDER } },
    },
    BuilderType = 'Gate',
}

local QG_SCU_Cybran = Builder {
    BuilderName = 'QG AllFaction SCU - Cybran',
    PlatoonTemplate = 'QG_AF_SCU_Cybran',
    Priority = 1000,
    BuilderConditions = {
        { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.5, 0.8 } },
        { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.CYBRAN * categories.SUBCOMMANDER } },
    },
    BuilderType = 'Gate',
}

local QG_SCU_Seraphim = Builder {
    BuilderName = 'QG AllFaction SCU - Seraphim',
    PlatoonTemplate = 'QG_AF_SCU_Seraphim',
    Priority = 1000,
    BuilderConditions = {
        { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.5, 0.8 } },
        { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.SERAPHIM * categories.SUBCOMMANDER } },
    },
    BuilderType = 'Gate',
}

# ---------- 动态注入：追加进已激活的工程师工厂组（FactoryBuilder，门管理器读取） ----------
local QG_SCU_Names = { QG_SCU_Aeon, QG_SCU_UEF, QG_SCU_Cybran, QG_SCU_Seraphim }
local facGrp = BuilderGroups['SorianEngineerFactoryBuilders']
if facGrp then
    for _, name in QG_SCU_Names do
        local found = false
        for _, v in facGrp do
            if v == name then
                found = true
                break
            end
        end
        if not found then
            table.insert(facGrp, name)
        end
    end
end

# ---------- 让 SCU 建造 T3 工厂，触发「工厂 AI → T3 工程师 → 裂变单位」连锁 ----------
# 机制：SCU 本质是「机动指挥官级工程师」，其建造菜单为阵营原生（Cybran SCU 只会造
# Cybran 工厂）。用 SCU 专用模板（GlobalSquads = categories.SUBCOMMANDER）让
# EngineerBuilderManager 把空闲 SCU 分配来盖工厂；工厂下属 FactoryBuilderManager 自动
# 接管，造出本阵营 T3 工程师，工程师再裂变单位 —— 从而实现「全阵营蔓延」，无需逐个强制。
# 不改动既有 4 个门造 SCU builder（按需求：SCU 生产不修改）。
PlatoonTemplate {
    Name = 'QG_SCU_Builder',
    Plan = 'EngineerBuildAISorian',
    GlobalSquads = {
        { categories.SUBCOMMANDER, 1, 1, 'support', 'None' }
    },
}

local QG_SCU_Factory = Builder {
    BuilderName = 'QG SCU Build T3 Factory',
    PlatoonTemplate = 'QG_SCU_Builder',
    Priority = 800,
    BuilderConditions = {
        { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.5, 0.8 } },
        { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.SUBCOMMANDER } },
        { UCBC, 'FactoryLessAtLocation', { 'LocationType', 12, 'FACTORY TECH3' } },
    },
    BuilderType = 'Any',
    BuilderData = {
        Construction = {
            BuildStructures = {
                'T3LandFactory',
                'T3AirFactory',
                'T3NavalFactory',
            }
        }
    }
}

local scuGrp = BuilderGroups['SorianT3EngineerBuilders']
if scuGrp then
    local found = false
    for _, v in scuGrp do
        if v == QG_SCU_Factory then
            found = true
            break
        end
    end
    if not found then
        table.insert(scuGrp, QG_SCU_Factory)
    end
end
