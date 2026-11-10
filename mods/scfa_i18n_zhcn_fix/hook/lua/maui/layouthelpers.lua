-- SCFA 官方简体中文修复补丁 (scfa_i18n_zhcn_fix) - FMV 字幕出屏修复
-- 挂载点: /lua/maui/layouthelpers.lua (base 之后同一 env 追加执行)
--
-- 问题:
--   FA 自带过场影片把字幕顶边绑在「影片底边」上:
--     /lua/ui/campaign/selectcampaign.lua:641  textArea.Top = nis.Bottom()    (时间线影片)
--     /lua/ui/dialogs/score.lua:325           textArea.Top = movie.Bottom()  (任务结算影片)
--     /lua/ui/game/missiontext.lua:413        textArea.Top = nis.Bottom()    (结局影片)
--   影片用 FillParentPreserveAspectRatio 缩放, 上下会留黑边:
--     * 影片接近 16:9 时黑边只有 1~3 像素, 6 行字幕整块被推到屏幕外;
--     * 影片约 2.38:1 时黑边够高, 字幕才看得见.
--   原版 SC 移植的 sc_campaign/campaignmovies.lua 用的是
--     background.Bottom() - height - 4 (钉屏幕底), 所以移植战役反而正常.
--
-- 为什么放在这个 mod:
--   中文没有本地化配音, 剧情全靠字幕, 字幕跑出屏幕对中文玩家是硬伤;
--   有配音的语言影响很小. 因此修复随简体中文补丁分发, 不进战役发行包.
--
-- 为什么钩 layouthelpers 而不是那三个文件:
--   hook 只能「追加并整体覆盖函数」, 不能改函数体内的一行; 复制整段函数
--   会和战役包的 schook 覆盖 (score.lua / missiontext.lua) 互相打架.
--   三处字幕都在创建末尾调用 LayoutHelpers.AtHorizontalCenterIn,
--   在这里做一次最小钳制即可同时覆盖, 且对有无战役包都成立.
--
-- 做法:
--   仅当控件是「字幕型 ItemList」(4~6 行高、Top 是函数式布局) 且当前
--   Top 已贴到或越过父容器底边时, 把 Top 重新钉到
--   parent.Bottom() - Height() - 4, 与原版移植保持一致.
--   黑边够高的影片本来就在屏内, 保持原样; 全部包在 pcall 里,
--   任何异常都退回原版行为, 正常 UI 布局零改动.

do
    local SCZH_originalAtHorizontalCenterIn = AtHorizontalCenterIn
    local SCZH_fixLogged = false

    -- 与 campaignmovies.lua 的字幕判据保持一致:
    -- 没有本地化配音的语言完全依赖字幕; 有配音的语言若玩家手动开了字幕, 同样需要修.
    local function SCZH_SubtitlesMatter()
        local okVO, hasVO = pcall(function() return HasLocalizedVO(__language) end)
        if not okVO or hasVO ~= true then
            return true
        end
        local okOpt, opt = pcall(function()
            return import('/lua/user/prefs.lua').GetOption('subtitles')
        end)
        return okOpt and (opt == true or opt == 1)
    end

    local SCZH_fixEnabled = SCZH_SubtitlesMatter()

    -- 判断是不是影片字幕条, 避免影响普通列表 / 文本框 / 评分表.
    local function SCZH_IsMovieSubtitle(control)
        local ok, matched = pcall(function()
            -- ItemList 专有方法
            if type(control.DeleteAllItems) ~= 'function' then return false end
            if type(control.GetRowHeight) ~= 'function' then return false end

            local row = control:GetRowHeight()
            local height = control.Height()
            if type(row) ~= 'number' or type(height) ~= 'number' then return false end
            if row <= 0 or height <= 0 then return false end

            -- 字幕固定 4 行 (campaignmovies) 或 6 行 (timeline / score / outro)
            local lines = height / row
            if lines < 3.5 or lines > 6.5 then return false end

            -- Top 必须支持函数式布局 (字幕都绑在影片底边或屏幕底边).
            -- 只用公开的 SetFunction 方法判断, 不碰 LazyVar 内部字段.
            if type(control.Top.SetFunction) ~= 'function' then return false end
            return true
        end)
        return ok and matched == true
    end

    function AtHorizontalCenterIn(control, parent, leftOffset)
        local result = SCZH_originalAtHorizontalCenterIn(control, parent, leftOffset)

        if SCZH_fixEnabled and SCZH_IsMovieSubtitle(control) then
            pcall(function()
                local top = control.Top()
                local bottom = parent.Bottom()
                local height = control.Height()

                -- 只在字幕确实会出屏时介入; 数值读不到时按结构特征放行.
                -- 影片尚未载入时 lazyvar 可能算出 nan, 用 x ~= x 识别.
                local numbersOk = type(top) == 'number' and type(bottom) == 'number' and type(height) == 'number'
                    and top == top and bottom == bottom and height == height and top > 0
                local shouldPin = true
                if numbersOk then
                    shouldPin = (top >= bottom - height - 8)
                end

                if shouldPin then
                    control.Top:SetFunction(function()
                        local b = parent.Bottom()
                        if type(b) ~= 'number' or b ~= b then
                            return bottom
                        end
                        return math.floor(b - height - 4)
                    end)
                    if not SCZH_fixLogged then
                        SCZH_fixLogged = true
                        pcall(function() WARN('[SCFAZH] FMV subtitle pinned to screen bottom (no localized VO fix)') end)
                    end
                end
            end)
        end

        return result
    end
end
