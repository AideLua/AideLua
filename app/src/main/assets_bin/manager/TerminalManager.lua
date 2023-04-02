import "com.termux.shared.termux.TermuxConstants"
local RUN_COMMAND_SERVICE=TermuxConstants.TERMUX_APP.RUN_COMMAND_SERVICE

import "helper.TermuxHelper"

---终端管理器
local TerminalManager={}
---termux包名
local termuxPackageName=TermuxConstants.TERMUX_PACKAGE_NAME

function TerminalManager.init()

end

function TerminalManager.initViews()
  --TODO: 初始化终端控件
end
return TerminalManager
