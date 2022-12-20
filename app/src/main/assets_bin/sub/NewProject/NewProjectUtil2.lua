--主要给在线程里面使用
local NewProjectUtil2={}
local TEMPLATES_DIR_PATH=activity.getLuaDir("../../templates")--模板路径
local PRJS_PATH=getSharedData("projectsDir")--项目路径

NewProjectUtil2.TEMPLATES_DIR_PATH=TEMPLATES_DIR_PATH
NewProjectUtil2.PRJS_PATH=PRJS_PATH

--格式化信息用的，必须在线程内使用，且必须设置metatable
local keysFormatter={
  defaultImport=function(content) -- import "%s"
    return "\nimport \""..table.concat(content,"\"\nimport \"").."\"\n"
  end,
  includeLua=function(content) -- config.lua中的
    return ",\""..table.concat(content,"\",\"").."\""
  end,
}
--NewProjectUtil2.keysFormatter=keysFormatter

local function buildKeyItem(key,content)
  local text
  if type(content)=="table" then
    if #content~=0 then
      local formatter=keysFormatter[key]
      while type(formatter)=="string" do
        formatter=keysFormatter[formatter]
        keysFormatter[key]=formatter
      end
      if formatter then
        text=formatter(content)
        --print(text,formatter,dump(content))
       else
        print("formatter not found",key,dump(content))
      end
     else
      text=""
    end
   else
    text=tostring(content)
  end
  return text
end
NewProjectUtil2.buildKeyItem=buildKeyItem

---构建内容中的key，从 v5.1.0(51099) 支持lua语法
---@param content string 文件内容
---@param keys table 那个key的映射
---@param reallyKeysMap table 真正key的映射，一般keys不变，reallyKeysMap就不变（指的是他本身，与内容无关）
function NewProjectUtil2.buildKeysInContent(content,keys,reallyKeysMap)
  if not getmetatable(reallyKeysMap) then
    setmetatable(reallyKeysMap,{__index=function(self,key)
        local item=buildKeyItem(key,keys[key])
        self[key]=item--保存到reallyKeysMap，快速响应
        return item
    end})
  end
  content=content:gsub("{{(.-)}}",function(key)
    return assert(loadstring("return "..key,nil,nil,reallyKeysMap))()
  end)
  return content
end

function NewProjectUtil2.loadKeysFormatter(path,rootFormatter)
  local formatter=assert(loadfile(path))()
  if formatter.baseList and formatter.baseList~="default" then
    NewProjectUtil2.loadKeysFormatter(rel2AbsPath(formatter.baseList,File(path).getParent()))
  end
  setmetatable(formatter,{__index=keysFormatter})
  keysFormatter=formatter
  return formatter
end

---读取配置，就是单纯的读取文件，然后返回环境表
---@param path string 文件相对路径
---@param basePath string 文件夹路径
function NewProjectUtil2.readConfig(path,basePath)
  return getConfigFromFile(basePath.."/"..path)
end

--解压文件，不解压损坏的压缩包，并且返回状态
function NewProjectUtil2.unzip(path,unzipPath)
  File(unzipPath).mkdirs()
  local zipFile=ZipFile(path)
  if File(path).isFile() then
    if zipFile.isValidZipFile() then
      zipFile.extractAll(unzipPath)
      return true
     else
      print("损坏的压缩包:",path)
      return false
    end
  end
end

---将 itemsTable 中的项目添加到 mainTable
---@param mainTable table 待被添加的列表
---@param itemsTable table 待添加的值的列表
function NewProjectUtil2.addItemsToTable(mainTable,itemsTable)
  for index=1,#itemsTable do
    table.insert(mainTable,itemsTable[index])
  end
end


return NewProjectUtil2
