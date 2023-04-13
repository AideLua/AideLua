---更新检查助手
local GiteeUpdateHelper = require "helper.GiteeUpdateHelper"
local UpdateHelper = {}

function UpdateHelper.checkGiteeUpdate(owner, repo, nowTag)
    GiteeUpdateHelper.checkUpdate(owner, repo, nowTag)
end

return UpdateHelper
