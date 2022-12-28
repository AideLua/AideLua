import "java.io.File"
import "java.io.FileInputStream"
import "java.io.FileOutputStream"

local FileUtil={}
local function copyFile(fromFile,toFile,rewrite)
  local exists=toFile.exists()
  if exists and not rewrite then
    return
  end
  if exists then
    toFile.delete()
  end
  local toFileParent=toFile.getParentFile()
  if not toFileParent.isDirectory() then
    toFileParent.mkdirs()
  end
  local fosfrom = FileInputStream(fromFile)
  local fosto = FileOutputStream(toFile)
  local bt = byte[1024]
  local c = fosfrom.read(bt)
  while c>=0 do
    fosto.write(bt, 0, c) --将内容写到新文件当中
    c = fosfrom.read(bt)
  end
  fosfrom.close()
  fosto.close()
  luajava.clear(fosfrom)
  luajava.clear(fosto)
  luajava.clear(bt)
end
FileUtil.copyFile=copyFile

local function copyDir(fromFile,toFile,rewrite)
  if toFile.isFile() and rewrite then
    toFile.delete()
  end
  toFile.mkdirs()
  local toFilePath=toFile.getPath()
  local filesList=fromFile.listFiles()
  for index=0,#filesList-1 do
    local nowFile=filesList[index]
    local newFile=File(toFilePath.."/"..nowFile.getName())
    if nowFile.isFile() then
      copyFile(nowFile,newFile,rewrite)
     else
      copyDir(nowFile,newFile,rewrite)
    end
  end
  luajava.clear(filesList)
end
FileUtil.copyDir=copyDir

return FileUtil