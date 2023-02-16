import "java.io.FileOutputStream"
import "java.io.RandomAccessFile"

local ZipAlignToolHelper={}
local key="alignZipTool"
ZipAlignToolHelper.key=key
ZipAlignToolHelper.items={"zipalign-android","zipalign-java"}

function ZipAlignToolHelper.alignZip(inputPath,outputPath)
  local toolType=ZipAlignToolHelper.getToolType()
  if toolType==0 then
    local ZipAlignerAndroid=luajava.bindClass "com.mcal.zipalign.utils.ZipAligner"
    ZipAlignerAndroid.ZipAlign(inputPath,outputPath)
   elseif toolType==1 then
    local ZipAlignJava=luajava.bindClass "com.iyxan23.zipalignjava.ZipAlign"
    ZipAlignJava.alignZip(RandomAccessFile(inputPath,"r"), FileOutputStream(outputPath))
  end
end

function ZipAlignToolHelper.getToolType()
  return getSharedData(key)
end

function ZipAlignToolHelper.setToolType(_type)
  setSharedData(key,_type)
end

return ZipAlignToolHelper
