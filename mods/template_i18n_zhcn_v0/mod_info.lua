-- 拷贝后新模组推荐命名 name = "模组名 模组版本 语言 补丁"，例如 name = "BlackOps V6 简体中文补丁"
name = "SCFA Mod 翻译模板"
uid = "4AC44619-4B93-37DE-00E6-71ECCE445844"
version = 0
description = "语言翻译模板，没有实际意义，仅用于制作新的语言时快速完成项目文件夹。"
author = "HaoJun0823"
url = "https://www.haojun0823.xyz/"
selectable = true
enabled = true
exclusive = false
-- ui_only模组不会导致语言不同而联机不同步。
ui_only = true
-- requires写uuid,按照顺序requiresNames会展示出模组名称。
-- 事实上不需要编辑requires，因为没有相关模组即便加载该补丁翻译也不会生效。
requires = { }
requiresNames = { }
conflicts = { }
after = { }
-- 写UUID，一定在需要被翻译的模组后加载。
before = { }
