# SCFA-MOD-CN

《Supreme Commander: Forged Alliance》的**简体中文补丁与修正类 Mod 合集**。

每个 `mods/<名字>/` 都是一个独立可选的 FA Mod：复制进游戏的 `mods\` 目录，
再在游戏内 Mod 管理器启用即可。其中汉化补丁都是 `ui_only = true`（只影响本机 UI，
联机时不需要其它玩家安装），修正类 Mod 会改动蓝图或脚本，按各自说明启用。

配套的**原版战役移植项目**在另一个仓库：
[SCFA-Original-Campaign](https://github.com/HaoJun0823/SCFA-Original-Campaign)。

---

## 目录

```text
loc/CN/strings_db.lua    官方简体中文词条（本地化合并用）
mods/                    各个独立 Mod
BUGS.md                  已记录的问题与修复过程
UNITS.md / units.csv     单位词条对照表
```

## Mod 清单

| 目录 | 用途 |
|------|------|
| `scfa_i18n_zhcn_fix` | **原版 FA 简体中文修复补丁**（单位文本 Key + 影片字幕，见下节） |
| `4th_i18n_zhcn_v212` / `4th_fix` | 4th Dimension 2.12 汉化 / 蓝图缺陷修正 |
| `blackops_i18n_zhcn_v6` / `blackops_v6_fix` / `blackops_v6_unlock_t4` | BlackOps V6 汉化 / 修正 / T4 解锁 |
| `brewlan_i18n_zhcn_v0899.1` | BrewLAN 家族汉化 |
| `totalmayhem_i18n_zhcn_v121` / `totalmayhem_v121_fix` | Total Mayhem v1.21 汉化 / 修正 |
| `quantum_gate_all_faction_scu` / `_ai` | 量子闸门可造全阵营 SCU（含 AI 版） |
| `unitcap_fix` | 修复单位上限崩溃 |
| `template_i18n_zhcn_v0` | 制作新语言补丁用的空模板 |

---

## 战役相关：`scfa_i18n_zhcn_fix`

这个 Mod 做两件事：

1. **补齐单位名文本 Key** —— 原版 FA 有约 262 个蓝图缺 `General.UnitName`，
   UI 只显示描述不显示名字。通过包装全局 `LOC()` 自建词典，并在 `CreateUI`
   时给蓝图注入 `<LOC xxx_name>`，让这些单位显示中文名。
2. **修复 FA 过场影片字幕被顶出屏幕**（本次新增）—— 详见下节。

### 字幕出屏问题与修复

FA 资料片自带的三处影片字幕把顶边绑在**影片底边**上：

| 位置 | 影片 |
|------|------|
| `lua/ui/campaign/selectcampaign.lua` | 主菜单时间线影片 |
| `lua/ui/dialogs/score.lua` | 任务结算后的过场影片 |
| `lua/ui/game/missiontext.lua` | 结局影片 |

影片用 `FillParentPreserveAspectRatio` 缩放，上下会留黑边：接近 16:9 的影片
黑边只有 1~3 像素，6 行字幕整块被推到屏幕外；约 2.38:1 的影片黑边够高，
字幕才看得见。原版 SC 战役移植用的是 `sc_campaign/campaignmovies.lua`，
字幕钉在**屏幕底边**（`background.Bottom() - height - 4`），所以移植战役反而正常。

**为什么只放在中文补丁里**：中文没有本地化配音，剧情完全依赖字幕，字幕看不见
就是硬伤；有配音的语言影响很小。因此这个修复随简体中文补丁分发，
**不进入战役发行包**，也不会影响其它语言玩家（代码里仍按
`HasLocalizedVO(__language)` 与游戏字幕开关判断一次）。

**为什么钩 `layouthelpers.lua` 而不是那三个文件**：FA 的 hook 只能「追加并
整体覆盖函数」，改不了函数体内的一行；把整段函数复制过来又会和战役包的
`schook` 覆盖（`score.lua` / `missiontext.lua` 都是 SC 版本）互相打架。
三处字幕在创建末尾都会调用 `LayoutHelpers.AtHorizontalCenterIn`，所以修复放在
`hook/lua/maui/layouthelpers.lua` 里，做一次最小钳制：

- 只对「字幕型 ItemList」（4~6 行高、`Top` 是函数式布局）生效；
- 只有当前 `Top` 已经贴到或越过父容器底边时，才把 `Top` 重钉到
  `parent.Bottom() - Height() - 4`，与原版移植一致；
- 黑边本来就够用的影片保持原样；所有判断包在 `pcall` 里，异常一律退回原版行为。

这样对有无战役移植包、FA 自带影片与移植影片都成立，也不碰任何原版文件。

**验证**：启用 Mod 后播放 FA 过场影片，`game.log` 里出现一次
`[SCFAZH] FMV subtitle pinned to screen bottom (no localized VO fix)`
即表示钳制已命中；字幕应贴在屏幕底部、完整可见。

---

## 相关

- 战役移植项目（18 关、发行包、修复清单）：[SCFA-Original-Campaign](https://github.com/HaoJun0823/SCFA-Original-Campaign)
- `BUGS.md` 是本地维护的问题排查记录，`UNITS.md` / `units.csv` 是单位词条对照表（本地资料，不随仓库分发）。
- 反馈问题请附 `game.log`（Steam 启动项加 `/log "game.log"`）与具体场景。

## 版权

Mod 化代码仅供个人 / 非商业用途；游戏数据版权归 © Gas Powered Games 所有，
请仅在持有原版游戏的情况下使用。
