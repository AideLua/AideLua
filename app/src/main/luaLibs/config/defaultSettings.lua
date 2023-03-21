import "android.os.Build"
import "android.os.Environment"

local SDK_INT=Build.VERSION.SDK_INT

return {
  {
    key="richAnim",
    func=function()
      if SDK_INT>=28 then
        return true
       else
        return false
      end
    end,
  },
  {
    key="moreCompleteRun",
    value=true,
  },
  {
    key="compileLua",
    value=true,
  },
  {
    key="alignZip",
    value=true,
  },
  {
    key="alignZipTool",
    value=0,
  },
  {
    key="jesse205Lib_support",
    value=false,
  },
  {
    key="androidX_support",
    value=true,
  },
  {
    key="editor_wordwrap",
    value=false,
  },
  {
    key="editor_showBlankChars",
    value=false,
  },
  {
    key="editor_magnify",
    func=function()
      if SDK_INT>=28 then
        return true
       else
        return false
      end
    end,
  },

}