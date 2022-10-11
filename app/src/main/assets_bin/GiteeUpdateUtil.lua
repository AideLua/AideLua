local owner="Jesse205"
local repo="AideLua"
local baseUrl="https://gitee.com/api/v5/repos/%s/%s/releases/latest"
local url=baseUrl:format(owner,repo)

import "cjson"
local GiteeUpdateUtil={}
local packageInfo=activity.getPackageManager().getPackageInfo(getPackageName(),0)

function GiteeUpdateUtil.showUpdateDialog(content)
  AlertDialog.Builder(this)
  .setTitle(content.name)
  .setMessage(content.body)
  .setPositiveButton("Download",function()
    
  end)
  .setNegativeButton(android.R.string.no,nil)
  .show()
end

function GiteeUpdateUtil.checkUpdate()
  Http.get(url,nil,"UTF-8",nil,function(code,content,cookie,header)
    if code==200 and content then
      GiteeUpdateManager.showUpdateDialog(cjson.decode(content))
    end
  end)

end



return GiteeUpdateManager
