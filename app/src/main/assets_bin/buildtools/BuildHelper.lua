local BuildHelper={}
function prinInfo(message)
  this.update("info")
  this.update(message)
end
updateInfo=prinInfo

function printDoing(message)
  this.update("doing")
  this.update(message)
end
updateDoing=printDoing

function printSuccess(message)
  this.update("success")
  this.update(message)
end
updateSuccess=printSuccess

function printError(message)
  this.update("error")
  this.update(message)
end
updateError=printError

--编译事件监听器
BuildHelper.onCompileListener={
  onError=printError,
  onDeleted=prinInfo
}

function BuildHelper.loadEvents()

end

return BuildHelper