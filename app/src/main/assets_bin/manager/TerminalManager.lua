import "com.termux.shared.termux.TermuxConstants"
local RUN_COMMAND_SERVICE = TermuxConstants.TERMUX_APP.RUN_COMMAND_SERVICE

import "helper.TermuxHelper"

---终端管理器
---@class TerminalManager
local TerminalManager = {}

---termux包名
---@type string
local termuxPackageName = TermuxConstants.TERMUX_PACKAGE_NAME

---新建一个终端
function TerminalManager.newTerminal()
    --TODO: 新建终端，返回终端配置
end

---初始化 TerminalManager
function TerminalManager.init()
    TerminalManager.initViews()
end

---初始化 TerminalManager 所需的控件
function TerminalManager.initViews()
    --TODO: 初始化终端控件
end

return TerminalManager
