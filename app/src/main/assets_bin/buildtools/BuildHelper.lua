local BuildHelper={}
function updateInfo(message)
  this.update("info")
  this.update(message)
end
function updateDoing(message)
  this.update("doing")
  this.update(message)
end

function updateSuccess(message)
  this.update("success")
  this.update(message)
end

function updateError(message)
  this.update("error")
  this.update(message)
end

--编译事件监听器
BuildHelper.onCompileListener={
  onError=updateError,
  onDeleted=updateInfo
}

function BuildHelper.loadEvents()

end

return BuildHelper