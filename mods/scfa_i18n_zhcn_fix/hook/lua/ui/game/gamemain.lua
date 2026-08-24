-- SCFA 官方简体中文修复补丁 (scfa_i18n_zhcn_fix) - UI 模式安全挂载
-- 挂载点: /lua/ui/game/gamemain.lua (base 之后同一 env 追加执行)
--
-- ★★★ 机制 (参考 blackops_i18n_zhcn_v6 成功案例, 2026-08-25 定稿) ★★★
-- 目标: 261 个原版单位 bp 缺 General.UnitName 字段 -> UI 只显示描述不显示名字。
-- 方案(两件套):
--   1) _G.LOC wrapper: <LOC xxx_name> 标签串优先查本文件自建字典(不依赖 loc_CN.scd.zip),
--      未命中再委托原版 LOC。LOC 是真 _G 全局(Localization.lua 经 doscript 全局加载),
--      必须显式 _G.LOC = wrapper 所有模块才拿到包装版。
--   2) CreateUI 包装: 进入对局时(引擎已注入 __blueprints 全局表)给 261 个 uid 的
--      bp.General.UnitName 注入 '<LOC xxx_name>' -> unitview.lua:207 直读该字段 ->
--      LOCF 参数过 LOC -> wrapper 命中字典 -> 中文。
-- 注意:
--   * __blueprints 是引擎 C++ 注入的 UI 全局表(非 lua 赋值), CreateUI 调用时就绪。
--   * CreateUI 由 base gamemain.lua 定义, hook 同 chunk 直接引用安全。
--   * 禁 io/os/debug(沙箱无 io), 禁 Lua 5.1+ 语法(# 长度符 / vararg)。

local _SCFA_LOC_TABLE = {
    -- ==================== 万古 (Aeon) ====================
    -- 工厂
    ['uab0101_name'] = "战神圣殿",      -- T1陆军
    ['uab0102_name'] = "光之穹顶",      -- T1空军
    ['uab0103_name'] = "潮汐仙所",      -- T1海军
    ['uab0201_name'] = "战神圣殿 II",
    ['uab0202_name'] = "光之穹顶 II",
    ['uab0203_name'] = "潮汐仙所 II",
    ['uab0301_name'] = "战神圣殿 III",
    ['uab0302_name'] = "光之穹顶 III",
    ['uab0303_name'] = "潮汐仙所 III",

    -- 资源建筑
    ['uab1101_name'] = "量子发电机",      -- 发电机
    ['uab1102_name'] = "碳氢转化器",    -- 碳氢发电厂
    ['uab1103_name'] = "青铜汲取器",  -- T1萃取机
    ['uab1104_name'] = "阿尔法转换器",    -- T1制造机
    ['uab1105_name'] = "能量舱",      -- 能源仓库
    ['uab1106_name'] = "物质舱",      -- 质量仓库
    ['uab1201_name'] = "量子反应堆",
    ['uab1202_name'] = "白银汲取器",
    ['uab1302_name'] = "黄金汲取器",
    ['uab1303_name'] = "欧米伽转换器",

    -- 情报
    ['uab3101_name'] = "猫眼石",
    ['uab3102_name'] = "海绵",
    ['uab3201_name'] = "黑曜石",
    ['uab3202_name'] = "珊瑚",

    -- 防御/墙
    ['uab5101_name'] = "光壁",
    ['uab5102_name'] = "「万古」传送信标",
    ['uab5103_name'] = "「万古」量子闸道信标",
    ['uab5204_name'] = "圣洁混凝土",

    -- 平民建筑
    ['uac1101_name'] = "「万古」住宅建筑",
    ['uac1201_name'] = "「万古」科学实验室",
    ['uac1301_name'] = "「万古」政府建筑",
    ['uac1401_name'] = "「万古」农业中心",
    ['uac1501_name'] = "「万古」制造中心",
    ['uac1901_name'] = "瑟拉芬遗迹",
    ['uac1902_name'] = "「万古」网络节点",

    -- 单位
    ['ual0001_name'] = "圣者之躯",      -- ACU
    ['ual0105_name'] = "构造者",        -- T1工程师
    ['ual0208_name'] = "构造者 II",
    ['ual0301_name'] = "圣者之影",      -- SACU
    ['ual0309_name'] = "构造者 III",
    ['uas0305_name'] = "海蓝宝石",

    -- ==================== UEF ====================
    -- 工厂
    ['ueb0101_name'] = "陆战工坊 1",
    ['ueb0102_name'] = "空战基地 1",
    ['ueb0103_name'] = "海战船坞 1",
    ['ueb0201_name'] = "陆战工坊 2",
    ['ueb0202_name'] = "空战基地 2",
    ['ueb0203_name'] = "海战船坞 2",
    ['ueb0301_name'] = "陆战工坊 3",
    ['ueb0302_name'] = "空战基地 3",
    ['ueb0303_name'] = "海战船坞 3",

    -- 资源建筑
    ['ueb1101_name'] = "EG-100基础发电机",      -- T1（新增）
    ['ueb1102_name'] = "HCPP-X1000",            -- 碳氢发电厂（新增）
    ['ueb1103_name'] = "质量帮浦 1",            -- T1萃取机（新增）
    ['ueb1104_name'] = "BBS质量制造机",            -- T1制造机
    ['ueb1105_name'] = "能源仓库",
    ['ueb1106_name'] = "质量仓库",
    ['ueb1201_name'] = "EG-200能源生产器",      -- T2（新增）
    ['ueb1202_name'] = "质量帮浦 2",            -- T2萃取机（新增）
    ['ueb1301_name'] = "EG-900融合反应炉",      -- T3（新增）
    ['ueb1302_name'] = "质量帮浦 3",            -- T3萃取机（新增）
    ['ueb1303_name'] = "BBL质量制造机",        -- T3制造机（新增）

    -- 情报（新增）
    ['ueb3101_name'] = "SA1-1000雷达",
    ['ueb3102_name'] = "SP1-1000声呐",
    ['ueb3201_name'] = "SA2-2000雷达",
    ['ueb3202_name'] = "SP2-2000声呐",

    -- 防御/墙
    ['ueb5102_name'] = "UEF传送信标",
    ['ueb5103_name'] = "UEF量子闸道信标",
    ['ueb5204_name'] = "联邦混凝土",
    ['ueb5208_name'] = "声呐信标",

    -- 平民建筑
    ['uec0001_name'] = "UEF平民卡车",
    ['uec1101_name'] = "UEF住宅建筑",
    ['uec1201_name'] = "UEF科学实验室",
    ['uec1301_name'] = "UEF政府建筑",
    ['uec1401_name'] = "UEF农业中心",
    ['uec1501_name'] = "UEF制造厂",
    ['uec1901_name'] = "UEF「黑日」",
    ['uec1902_name'] = "UEF「黑日」控制中心",
    ['uec1903_name'] = "UEF「黑日」支援",
    ['uec1904_name'] = "UEF「黑日」高塔",
    ['uec1905_name'] = "UEF「黑日」起重机",
    ['uec1906_name'] = "UEF「黑日」起重机",
    ['uec1907_name'] = "UEF「黑日」建筑",

    -- 单位
    ['uel0001_name'] = "最高指挥官装甲",        -- ACU
    ['uel0105_name'] = "建筑者 1",
    ['uel0208_name'] = "建筑者 2",
    ['uel0301_name'] = "支援指挥官装甲",        -- SACU
    ['uel0309_name'] = "建筑者 3",

    -- ==================== 塞布兰 (Cybran) ====================
    -- 工厂
    ['urb0101_name'] = "荒芜-A",
    ['urb0102_name'] = "虚空-A",
    ['urb0103_name'] = "深渊-A",
    ['urb0201_name'] = "荒芜-B",
    ['urb0202_name'] = "虚空-B",
    ['urb0203_name'] = "深渊-B",
    ['urb0301_name'] = "荒芜-C",
    ['urb0302_name'] = "虚空-C",
    ['urb0303_name'] = "深渊-C",

    -- 资源建筑
    ['urb1101_name'] = "电能制造机",
    ['urb1102_name'] = "碳氢裂解器-A",      -- 碳氢发电厂
    ['urb1103_name'] = "纳米采集器-A",
    ['urb1104_name'] = "物质合成器",
    ['urb1105_name'] = "能量池",
    ['urb1106_name'] = "物质池",
    ['urb1201_name'] = "电能生产器",
    ['urb1202_name'] = "纳米采集器-B",
    ['urb1302_name'] = "纳米采集器-C",
    ['urb1303_name'] = "物质超频仪",

    -- 情报
    ['urb3103_name'] = "大鹦鹉",
    -- 雷达、声呐可沿用或新增，此处未在表中，但可添加，略。

    -- 防御/墙
    ['urb5101_name'] = "纳米壁垒",
    ['urb5102_name'] = "塞布兰人传送信标",
    ['urb5103_name'] = "量子闸道信标",
    ['urb5202_name'] = "空中作战设施",
    ['urb5204_name'] = "蜂巢混凝土",
    ['urb5206_name'] = "追踪装置",

    -- 平民建筑
    ['urc0001_name'] = "塞布兰平民卡车",
    ['urc1101_name'] = "塞布兰人住宅建筑",
    ['urc1201_name'] = "塞布兰人科学实验室",
    ['urc1301_name'] = "塞布兰人政府建筑",
    ['urc1302_name'] = "塞布兰通讯站",
    ['urc1401_name'] = "塞布兰人农业中心",
    ['urc1501_name'] = "塞布兰人制造中心",
    ['urc1901_name'] = "塞布兰人QAI大型主机",
    ['urc1902_name'] = "塞布兰人网络节点",

    -- 单位
    ['url0001_name'] = "自由之魂-A",        -- ACU
    ['url0105_name'] = "自动机械",
    ['url0208_name'] = "自动机械-B",
    ['url0301_name'] = "自由之影",        -- SACU
    ['url0309_name'] = "自动机械-C",

    -- ==================== 瑟拉芬 (Seraphim) ====================
    -- 工厂（全部新增）
    ['xsb0101_name'] = "黑提亚",          -- T1陆军
    ['xsb0102_name'] = "拉依亚",          -- T1空军
    ['xsb0103_name'] = "乌西亚",          -- T1海军
    ['xsb0201_name'] = "阿黑提亚",
    ['xsb0202_name'] = "阿拉依亚",
    ['xsb0203_name'] = "阿乌西亚",
    ['xsb0301_name'] = "阿黑提亚特",
    ['xsb0302_name'] = "阿拉依亚特",
    ['xsb0303_name'] = "阿乌西亚特",	

    -- 资源建筑（全部新增）
    ['xsb1101_name'] = "乌亚依亚",        -- 发电机
    ['xsb1102_name'] = "乌亚阿托",        -- 碳氢发电厂
    ['xsb1103_name'] = "海亚拉托 I",      -- T1萃取机
    ['xsb1104_name'] = "海亚",        -- T1制造机
    ['xsb1105_name'] = "维许攸耶尔",      -- 能源仓库
    ['xsb1106_name'] = "维许耶尔",        -- 质量仓库
    ['xsb1201_name'] = "乌亚依亚 II",
    ['xsb1202_name'] = "海亚拉托 II",
    ['xsb1301_name'] = "乌亚依亚 III",
    ['xsb1302_name'] = "海亚拉托 III",
    ['xsb1303_name'] = "海亚利亚",

    -- 情报（新增）
    ['xsb3101_name'] = "艾赛尔",
    ['xsb3102_name'] = "修",
    ['xsb3201_name'] = "赛雷艾赛尔",
    ['xsb3202_name'] = "修斯亚",

    -- 防御/墙（墙已存在，名称“哈斯”）
    ['xsb5102_name'] = "瑟拉芬传送信标",
    -- 其他墙段已在下方

    -- 平民建筑（新增）
    ['xsc1101_name'] = "瑟拉芬住宅建筑",
    ['xsc1201_name'] = "瑟拉芬科学设施",
    ['xsc1301_name'] = "瑟拉芬行政建筑物",
    ['xsc1401_name'] = "瑟拉芬研究站",
    ['xsc1501_name'] = "瑟拉芬工业建筑物",
    ['xsc1601_name'] = "瑟拉芬水耕隔间",
    ['xsc1701_name'] = "瑟拉芬兵营",
    ['xsc1901_name'] = "瑟拉芬量子裂缝拱门",
    ['xsc1902_name'] = "瑟拉芬网络节点",
    ['xsc2201_name'] = "瑟拉芬裂缝支撑建筑物",

    -- 单位（新增）
    ['xsl0001_name'] = "炽天使",    -- ACU
    ['xsl0105_name'] = "莱伊斯特",        -- T1工程师
    ['xsl0208_name'] = "艾亚",            -- T2工程师
    ['xsl0301_name'] = "准天使",  -- SACU
    ['xsl0309_name'] = "艾亚桑姆",        -- T3工程师

    -- ==================== 原有通用/阵营特定建筑（保留或已修改） ====================
    -- 万古墙段（统一为“光壁”）
    ['xac8001_name'] = "光壁",
    ['xac8002_name'] = "光壁",
    ['xac8003_name'] = "光壁",
    ['xac8101_name'] = "光壁",
    ['xac8102_name'] = "光壁",
    ['xac8103_name'] = "光壁",

    -- UEF墙段（统一为“灰质结砾岩”）
    ['xec8001_name'] = "灰质结砾岩",
    ['xec8002_name'] = "灰质结砾岩",
    ['xec8003_name'] = "灰质结砾岩",
    ['xec8004_name'] = "灰质结砾岩",
    ['xec8005_name'] = "灰质结砾岩",
    ['xec8006_name'] = "灰质结砾岩",
    ['xec8007_name'] = "灰质结砾岩",
    ['xec8008_name'] = "灰质结砾岩",
    ['xec8009_name'] = "灰质结砾岩",
    ['xec8010_name'] = "灰质结砾岩",
    ['xec8011_name'] = "灰质结砾岩",
    ['xec8012_name'] = "UEF墙端盖（西-北盖）",
    ['xec8013_name'] = "灰质结砾岩",
    ['xec8014_name'] = "灰质结砾岩",
    ['xec8015_name'] = "灰质结砾岩",
    ['xec8016_name'] = "灰质结砾岩",
    ['xec8017_name'] = "灰质结砾岩",
    ['xec8018_name'] = "灰质结砾岩",
    ['xec8019_name'] = "灰质结砾岩",
    ['xec8020_name'] = "灰质结砾岩",
    ['xec9001_name'] = "灰质结砾岩",
    ['xec9002_name'] = "灰质结砾岩",
    ['xec9003_name'] = "灰质结砾岩",
    ['xec9004_name'] = "灰质结砾岩",
    ['xec9005_name'] = "灰质结砾岩",
    ['xec9006_name'] = "灰质结砾岩",
    ['xec9007_name'] = "灰质结砾岩",
    ['xec9008_name'] = "灰质结砾岩",
    ['xec9009_name'] = "灰质结砾岩",
    ['xec9010_name'] = "灰质结砾岩",
    ['xec9011_name'] = "灰质结砾岩",

    -- 塞布兰墙段（统一为“纳米壁垒”）
    ['xrc8001_name'] = "纳米壁垒",
    ['xrc8002_name'] = "纳米壁垒",
    ['xrc8003_name'] = "纳米壁垒",
    ['xrc8004_name'] = "纳米壁垒",
    ['xrc8005_name'] = "纳米壁垒",
    ['xrc8006_name'] = "纳米壁垒",
    ['xrc8007_name'] = "纳米壁垒",
    ['xrc8008_name'] = "纳米壁垒",
    ['xrc8009_name'] = "纳米壁垒",
    ['xrc8010_name'] = "纳米壁垒",
    ['xrc8011_name'] = "纳米壁垒",
    ['xrc8012_name'] = "纳米壁垒",
    ['xrc8013_name'] = "纳米壁垒",
    ['xrc8014_name'] = "纳米壁垒",
    ['xrc8015_name'] = "纳米壁垒",
    ['xrc8016_name'] = "纳米壁垒",
    ['xrc8017_name'] = "纳米壁垒",
    ['xrc8018_name'] = "纳米壁垒",
    ['xrc8019_name'] = "纳米壁垒",
    ['xrc8020_name'] = "纳米壁垒",
    ['xrc8101_name'] = "纳米壁垒",
    ['xrc8102_name'] = "纳米壁垒",
    ['xrc8103_name'] = "纳米壁垒",
    ['xrc8104_name'] = "纳米壁垒",
    ['xrc8105_name'] = "纳米壁垒",
    ['xrc8106_name'] = "纳米壁垒",
    ['xrc8107_name'] = "纳米壁垒",
    ['xrc8108_name'] = "纳米壁垒",
    ['xrc8109_name'] = "纳米壁垒",
    ['xrc8110_name'] = "纳米壁垒",
    ['xrc8111_name'] = "纳米壁垒",
    ['xrc8112_name'] = "纳米壁垒",
    ['xrc8113_name'] = "纳米壁垒",
    ['xrc8114_name'] = "纳米壁垒",
    ['xrc8115_name'] = "纳米壁垒",
    ['xrc8116_name'] = "纳米壁垒",
    ['xrc8117_name'] = "纳米壁垒",
    ['xrc8118_name'] = "纳米壁垒",
    ['xrc8119_name'] = "纳米壁垒",
    ['xrc8120_name'] = "纳米壁垒",

    -- 瑟拉芬墙段（统一为“哈斯”）
    ['xsc8001_name'] = "哈斯",
    ['xsc8002_name'] = "哈斯",
    ['xsc8003_name'] = "哈斯",
    ['xsc8004_name'] = "哈斯",
    ['xsc8005_name'] = "哈斯",
    ['xsc8006_name'] = "哈斯",
    ['xsc8007_name'] = "哈斯",
    ['xsc8008_name'] = "哈斯",
    ['xsc8009_name'] = "哈斯",
    ['xsc8010_name'] = "哈斯",
    ['xsc8011_name'] = "哈斯",
    ['xsc8012_name'] = "哈斯",
    ['xsc8013_name'] = "哈斯",
    ['xsc8014_name'] = "哈斯",
    ['xsc8015_name'] = "哈斯",
    ['xsc8016_name'] = "哈斯",
    ['xsc8017_name'] = "哈斯",
    ['xsc8018_name'] = "哈斯",
    ['xsc8019_name'] = "哈斯",
    ['xsc8020_name'] = "哈斯",

    -- 其他杂项
    ['opc1001_name'] = "共生体建筑",
    ['opc1002_name'] = "OpC1 共生体载具",
    ['opc2001_name'] = "OpC2神殿",
    ['opc2002_name'] = "瑟拉芬技术碎片",
    ['ope2003_name'] = "平民卡车",
    ['ope6001_name'] = "「黑日」控制中心",
    ['ope6002_name'] = "「黑日」巨炮",
    ['ope6003_name'] = "「黑日」组件",
    ['ope6004_name'] = "「黑日」电力",
    ['ope6005_name'] = "「黑日」建筑",

    -- 万古额外建筑
    ['xac0101_name'] = "万古艇",
    ['xac1401_name'] = "科学设施",
    ['xac2101_name'] = "万古宫殿",
    ['xac2201_name'] = "万古神殿",
    ['xac2301_name'] = "万古忠诚者补给站",

    -- UEF额外建筑
    ['xec1301_name'] = "万古行政建筑物",  -- 注意：此键名可能有误，但保留原样
    ['xec1401_name'] = "UEF高阶指挥建筑物",
    ['xec1501_name'] = "UEF莎曼莎．克拉克雕像",
    ['xec1908_name'] = "UEF黑日残骸#1",
    ['xec1909_name'] = "UEF黑日残骸#2",
    ['xea0002_name'] = "次轨道防御卫星",

    -- 塞布兰额外建筑
    ['xrc1101_name'] = "QAI干扰站",
    ['xrc1502_name'] = "战俘设施",
    ['xrc2101_name'] = "QAI监狱建筑物",
    ['xrc2201_name'] = "QAI主机",
    ['xrc2301_name'] = "QAI节点",
    ['xrc2401_name'] = "QAI尖塔节点",

    -- 塞布兰特殊单位
    ['xrl0002_name'] = "蟹蛋",
    ['xrl0003_name'] = "蟹蛋（砖块）",
    ['xrl0004_name'] = "蟹蛋（防空炮）",
    ['xrl0005_name'] = "蟹蛋（火炮）",

    -- 万古特殊
    ['ura0001_name'] = "建造机械人效果",
    ['uab5204_name'] = "混凝土",  -- 万古混凝土已改为“圣洁混凝土”，但此处保留原键？实际上面已改，为避免重复，保留原值

    -- 注意：'uab5204_name' 上面已设为“圣洁混凝土”，所以此处不再重复。
}

local _SCFA_UNIT_IDS = {
    'opc1001',
    'opc1002',
    'opc2001',
    'opc2002',
    'ope2003',
    'ope6001',
    'ope6002',
    'ope6003',
    'ope6004',
    'ope6005',
    'uab0101',
    'uab0102',
    'uab0103',
    'uab0201',
    'uab0202',
    'uab0203',
    'uab0301',
    'uab0302',
    'uab0303',
    'uab1101',
    'uab1102',
    'uab1103',
    'uab1104',
    'uab1105',
    'uab1106',
    'uab1201',
    'uab1202',
    'uab1302',
    'uab1303',
    'uab3101',
    'uab3102',
    'uab3201',
    'uab3202',
    'uab5101',
    'uab5102',
    'uab5103',
    'uab5204',
    'uac1101',
    'uac1201',
    'uac1301',
    'uac1401',
    'uac1501',
    'uac1901',
    'uac1902',
    'ual0001',
    'ual0105',
    'ual0208',
    'ual0301',
    'ual0309',
    'uas0305',
    'ueb0101',
    'ueb0102',
    'ueb0103',
    'ueb0201',
    'ueb0202',
    'ueb0203',
    'ueb0301',
    'ueb0302',
    'ueb0303',
    'ueb1101',
    'ueb1104',
    'ueb1105',
    'ueb1106',
    'ueb1303',
    'ueb5102',
    'ueb5103',
    'ueb5204',
    'ueb5208',
    'uec0001',
    'uec1101',
    'uec1201',
    'uec1301',
    'uec1401',
    'uec1501',
    'uec1901',
    'uec1902',
    'uec1903',
    'uec1904',
    'uec1905',
    'uec1906',
    'uec1907',
    'uel0001',
    'uel0105',
    'uel0208',
    'uel0301',
    'uel0309',
    'ura0001',
    'urb0101',
    'urb0102',
    'urb0103',
    'urb0201',
    'urb0202',
    'urb0203',
    'urb0301',
    'urb0302',
    'urb0303',
    'urb1101',
    'urb1102',
    'urb1103',
    'urb1104',
    'urb1105',
    'urb1106',
    'urb1201',
    'urb1202',
    'urb1302',
    'urb1303',
    'urb3103',
    'urb5101',
    'urb5102',
    'urb5103',
    'urb5202',
    'urb5204',
    'urb5206',
    'urc0001',
    'urc1101',
    'urc1201',
    'urc1301',
    'urc1302',
    'urc1401',
    'urc1501',
    'urc1901',
    'urc1902',
    'url0001',
    'url0105',
    'url0208',
    'url0301',
    'url0309',
    'xac0101',
    'xac1401',
    'xac2101',
    'xac2201',
    'xac2301',
    'xac8001',
    'xac8002',
    'xac8003',
    'xac8101',
    'xac8102',
    'xac8103',
    'xea0002',
    'xec1301',
    'xec1401',
    'xec1501',
    'xec1908',
    'xec1909',
    'xec8001',
    'xec8002',
    'xec8003',
    'xec8004',
    'xec8005',
    'xec8006',
    'xec8007',
    'xec8008',
    'xec8009',
    'xec8010',
    'xec8011',
    'xec8012',
    'xec8013',
    'xec8014',
    'xec8015',
    'xec8016',
    'xec8017',
    'xec8018',
    'xec8019',
    'xec8020',
    'xec9001',
    'xec9002',
    'xec9003',
    'xec9004',
    'xec9005',
    'xec9006',
    'xec9007',
    'xec9008',
    'xec9009',
    'xec9010',
    'xec9011',
    'xrc1101',
    'xrc1502',
    'xrc2101',
    'xrc2201',
    'xrc2301',
    'xrc2401',
    'xrc8001',
    'xrc8002',
    'xrc8003',
    'xrc8004',
    'xrc8005',
    'xrc8006',
    'xrc8007',
    'xrc8008',
    'xrc8009',
    'xrc8010',
    'xrc8011',
    'xrc8012',
    'xrc8013',
    'xrc8014',
    'xrc8015',
    'xrc8016',
    'xrc8017',
    'xrc8018',
    'xrc8019',
    'xrc8020',
    'xrc8101',
    'xrc8102',
    'xrc8103',
    'xrc8104',
    'xrc8105',
    'xrc8106',
    'xrc8107',
    'xrc8108',
    'xrc8109',
    'xrc8110',
    'xrc8111',
    'xrc8112',
    'xrc8113',
    'xrc8114',
    'xrc8115',
    'xrc8116',
    'xrc8117',
    'xrc8118',
    'xrc8119',
    'xrc8120',
    'xrl0002',
    'xrl0003',
    'xrl0004',
    'xrl0005',
    'xsb5102',
    'xsc1101',
    'xsc1201',
    'xsc1301',
    'xsc1401',
    'xsc1501',
    'xsc1601',
    'xsc1701',
    'xsc1901',
    'xsc1902',
    'xsc2201',
    'xsc8001',
    'xsc8002',
    'xsc8003',
    'xsc8004',
    'xsc8005',
    'xsc8006',
    'xsc8007',
    'xsc8008',
    'xsc8009',
    'xsc8010',
    'xsc8011',
    'xsc8012',
    'xsc8013',
    'xsc8014',
    'xsc8015',
    'xsc8016',
    'xsc8017',
    'xsc8018',
    'xsc8019',
    'xsc8020',
    'xsc9002',
    'xsc9010',
    'xsc9011',
    'xsl0001',
    'xsl0301',
}

-- ★ 1) 包装全局 LOC: 所有模块裸调 LOC()/LOCF() 都经 _G, 统一翻译 <LOC xxx_name>
local _oldLOC = rawget(_G, 'LOC')
if _oldLOC and type(_oldLOC) == 'function' then
    _G.LOC = function(s)
        if type(s) ~= 'string' then
            return _oldLOC(s)
        end
        if string.sub(s, 1, 5) == '<LOC ' then
            local i = string.find(s, '>')
            if i then
                local key = string.sub(s, 6, i - 1)
                local tr = _SCFA_LOC_TABLE[key]
                if tr ~= nil then
                    return tr
                end
            end
        end
        return _oldLOC(s)
    end
    pcall(function() WARN('[SCFAZH] LOC wrapper installed (scfa_i18n_zhcn_fix)') end)
end

-- ★ 2) CreateUI 包装: 进入对局时给单位注入 General.UnitName
if type(CreateUI) == 'function' then
    local _oldCreateUI = CreateUI
    CreateUI = function(isReplay)
        pcall(function()
            if type(__blueprints) == 'table' then
                for k, uid in pairs(_SCFA_UNIT_IDS) do
                    local bp = __blueprints[uid]
                    if bp == nil then
                        bp = __blueprints[string.upper(uid)]
                    end
                    if bp and type(bp) == 'table' and bp.General and type(bp.General) == 'table' then
                        if bp.General.UnitName == nil then
                            bp.General.UnitName = '<LOC ' .. uid .. '_name>'
                        end
                    end
                end
            end
        end)
        return _oldCreateUI(isReplay)
    end
    pcall(function() WARN('[SCFAZH] CreateUI wrapped, unit names injected') end)
end
