--主要给在线程里面使用
local NewProjectUtil2={}
local TEMPLATES_DIR_PATH=activity.getLuaDir("../../templates")--模板路径
local PRJS_PATH=getSharedData("projectsDir")--项目路径

NewProjectUtil2.TEMPLATES_DIR_PATH=TEMPLATES_DIR_PATH
NewProjectUtil2.PRJS_PATH=PRJS_PATH

--格式化信息用的
local tableConfigFormatter={
  dependencies=function(content)
    return "\n    "..table.concat(content,"\n    ")
  end,
  includeLua=function(content)--config.lua中的
    return "\""..table.concat(content,"\",\"").."\","
  end,
  include=function(content)--settings.gradle中的
    return ",'"..table.concat(content,"','").."'"
  end,
  defaultImport=function(content)
    return "\nimport \""..table.concat(content,"\"\nimport \"").."\"\n"
  end,
  am_application=function(content)
    return "\n"..table.concat(content,"\n\n").."\n"
  end,
  am_activity_info=function(content)
    return "\n            "..table.concat(content,"\n            ")
  end,
}
tableConfigFormatter.appDependencies=tableConfigFormatter.dependencies
tableConfigFormatter.appDependenciesEnd=tableConfigFormatter.dependencies
tableConfigFormatter.dependenciesEnd=tableConfigFormatter.dependencies

tableConfigFormatter.am_application_bottom=tableConfigFormatter.am_application
tableConfigFormatter.am_welcome_info=tableConfigFormatter.am_activity_info
tableConfigFormatter.am_main_info=tableConfigFormatter.am_activity_info

NewProjectUtil2.tableConfigFormatter=tableConfigFormatter

function NewProjectUtil2.getKeyText(key,content)
  local text
  if type(content)=="table" then
    if #content=="" then
      text=tableConfigFormatter[key](content)
     else
      text=""
    end
   else
    text=tostring(content)
  end
  return text
end

function NewProjectUtil2.readConfig(path,basePath)
  return getConfigFromFile(basePath.."/"..path)
end

return NewProjectUtil2
