--格式化table中的内容}
local function keysTableFormater(key,content)
  if #content==0 then
    content=""
   else
    if key=="appDependencies" then
      content="\n    "..table.concat(content,"\n    ")
     elseif key=="appInclude" then
      content="\""..table.concat(content,"\",\"").."\","
     elseif key=="am_application" or key=="am_application_bottom" then
      content="\n"..table.concat(content,"\n\n").."\n"
    end
  end
end
return keysTableFormater