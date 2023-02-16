--v5.1.1+
local UnicodeUtil={}

function UnicodeUtil.utf8ToUnicode(inStr)
  local inStr=String(inStr)
  local myBuffer=inStr.toCharArray()--数组
  local sb =StringBuffer()
  for i=0,inStr.length()-1 do
    sb.append(string.format("\\u%04x",myBuffer[i]))
  end
  return sb.toString()
end

return UnicodeUtil
