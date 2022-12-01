--主要给在线程里面使用
local NewProjectUtil2={}
local TEMPLATES_DIR_PATH=activity.getLuaDir("../../templates")--模板路径
local PRJS_PATH=getSharedData("projectsDir")--项目路径

NewProjectUtil2.TEMPLATES_DIR_PATH=TEMPLATES_DIR_PATH
NewProjectUtil2.PRJS_PATH=PRJS_PATH

--格式化信息用的，必须在线程内使用，且必须设置metatable
local tableConfigFormatter={
  defaultImport=function(content) -- import "%s"
    return "\nimport \""..table.concat(content,"\"\nimport \"").."\"\n"
  end,
  includeLua=function(content) -- config.lua中的
    return "\""..table.concat(content,"\",\"").."\","
  end,
}
NewProjectUtil2.tableConfigFormatter=tableConfigFormatter


local function buildKeyItem(formatter,content)
  local text
  if type(content)=="table" then
    if #content=="" then
      text=formatter(content)
     else
      text=""
    end
   else
    text=tostring(content)
  end
  return text
end
NewProjectUtil2.buildKeyItem=buildKeyItem

--构建内容中的key
function NewProjectUtil2.buildKeysInContent(content,keys,reallyKeysMap)
  local env={}
  setmetatable(env,{__index=function(self,key)
      local item=reallyKeysMap[key]--防止重复构建
      if not(item) then
        local formatter=tableConfigFormatter[key]
        if formatter and type(formatter)=="function" then
          item=buildKeyItem(formatter,keys[key])
          reallyKeysMap[key]=item
        end
      end
      return item
  end})
  content:gsub("{{(.-)}}",function(key)
    local content=assert(loadstring("return "..key,nil,nil,env))()
    return content
  end)
  return content
end

function NewProjectUtil2.readConfig(path,basePath)
  return getConfigFromFile(basePath.."/"..path)
end

--解压文件，不解压损坏的压缩包，并且返回状态
function NewProjectUtil2.unzip(path,unzipPath)
  File(unzipPath).mkdirs()
  local zipFile=ZipFile(path)
  if zipFile.isValidZipFile() then
    zipFile.extractAll(unzipPath)
    return true
   else
    --print("损坏的压缩包:",path)
    return false
  end
end

--将 itemsTable 中的项目添加到 mainTable
function NewProjectUtil2.addItemsToTable(mainTable,itemsTable)
  for index=1,#itemsTable do
    table.insert(mainTable,itemsTable[index])
  end
end


return NewProjectUtil2
