--module(...,package.seeall)
local EditorUtil={}
--[[
import "tiiehenry.code.language.LanguageNonProg"
import "tiiehenry.code.language.java.JavaLanguage"
import "tiiehenry.code.language.python.PythonLanguage"
import "tiiehenry.code.language.xml.XMLLanguage"
import "tiiehenry.code.language.lua.LuaLanguage"
import "com.myopicmobileX.textwarrior.common.LanguageXML"
import "com.xiaoyv.editor.common.LanguageJava"
import "com.xiaoyv.editor.common.LanguageNonPro"
]]
import "io.github.rosemoe.editor.langs.EmptyLanguage"
import "io.github.rosemoe.editor.langs.desc.JavaScriptDescription"
import "io.github.rosemoe.editor.langs.html.HTMLLanguage"
import "io.github.rosemoe.editor.langs.java.JavaLanguage"
import "io.github.rosemoe.editor.langs.python.PythonLanguage"
import "io.github.rosemoe.editor.langs.universal.UniversalLanguage"

EditorUtil.Editors={}
EditorUtil.IsEditors={}
EditorUtil.EditorsGroup={}

EditorUtil.NowEditorType=nil
EditorUtil.NowEditor=nil
EditorUtil.IsEdtor=nil

EditorUtil.TextFileType2EditorType={
  lua="LuaEditor",
  aly="LuaEditor",

  html="CodeEditor",
  svg="CodeEditor",
  xml="CodeEditor",
  java="CodeEditor",
  py="CodeEditor",
  pyw="CodeEditor",
  txt="CodeEditor",
  gradle="CodeEditor",
  bat="CodeEditor",
  json="CodeEditor",
}

local oldThemeId
EditorUtil.PreviewFunc={
  svg=function()
    EditorUtil.switchEditor("PhotoView")--将编辑器切换为Lua编辑器
    Sharp.loadFile(NowFile).into(NowEditor)

    return true
  end,
  aly=function()
    import "androidx"
    EditorUtil.switchEditor("LayoutView")--将编辑器切换为Lua编辑器
    oldThemeId=activity.getThemeResId()
    if ThemeUtil.NowAppTheme.night then
      activity.setTheme(R.style.Theme_MaterialComponents)
     else
      activity.setTheme(R.style.Theme_MaterialComponents_Light)
    end
    local layout=loadlayout2(loadfile(NowFile.getPath())(),{},nil,NowProjectDirectory.getPath())
    --NowEditor.removeAllViews()
    NowEditor.addView(layout)
    return true
  end,
  alyFinish=function()
    if oldThemeId then
      activity.setTheme(oldThemeId)
    end
  end,
  alyExit=function()
    NowEditor.removeAllViews()
  end,
  xml=function()
    EditorUtil.switchEditor("PhotoView")--将编辑器切换为Lua编辑器
    local content=io.readall(NowFile.getPath())
    content=content:gsub("vector","svg")
    :gsub("http://schemas.android.com/apk/res/android","http://www.w3.org/2000/svg")
    :gsub("android:fillColor","fill")
    :gsub("@android:color/white","#ffffff")
    :gsub("@android:color/black","#000000")
    :gsub('android:tint="(.-)"',"")
    :gsub('android:pathData="(.-)"/>',function(v)
      return 'd="'..v..'"/>'
    end)
    :gsub("dp","")
    :gsub("viewportWidth(.-)>",[[viewBox="0 0 24 24">]])
    :gsub("android:","")
    Sharp.loadString(content).into(NowEditor)

    return true
  end,
}


EditorUtil.TextFileType2EditorLanguage={
  --lua=LuaLanguage.getInstance(),
  --aly=LuaLanguage.getInstance(),
  --xml=LanguageXML.getInstance(),
  html=HTMLLanguage(),
  xml=JavaLanguage(),
  svg=JavaLanguage(),
  py=PythonLanguage(),
  pyw=PythonLanguage(),
  java=JavaLanguage(),
  txt=EmptyLanguage(),
  gradle=EmptyLanguage(),
  bat=EmptyLanguage(),
  html=HTMLLanguage(),
  json=JavaLanguage(),
}

function EditorUtil.switchEditor(editorType,language)
  for index,content in pairs(EditorUtil.EditorsGroup) do
    if editorType==index then
      local editor=EditorUtil.Editors[editorType]
      _G.NowEditor=editor
      _G.NowEditorType=editorType
      _G.IsEdtor=EditorUtil.IsEditors[editorType]
      EditorUtil.NowEditorType=editorType
      EditorUtil.NowEditor=editor
      if language then
        xpcall(function()
          if editorType=="CodeEditor" then
            editor.setEditorLanguage(language)
          end
        end,
        function(err)
          print(err)
        end)
      end
      content.setVisibility(View.VISIBLE)
      editor.requestFocus()
      MyAnimationUtil.ScrollView.onScrollChange(editor,editor.getScrollX(),editor.getScrollY(),0,0,appBarLayout,nil)
     else
      content.setVisibility(View.GONE)
    end
  end
  return EditorUtil
end

function EditorUtil.switchPreview(fileType,isPreview)
  if isPreview then
    local succeed,oldThemeId
    if OpenedFile and IsEdtor then
      succeed=saveFile()
     else
      succeed=true
    end
    if succeed then
      local finishFunc=EditorUtil.PreviewFunc[fileType.."Finish"]
      xpcall(function()
        EditorUtil.PreviewFunc[fileType]()
      end,
      function(err)
        AlertDialog.Builder(this)
        .setTitle("Preview error")
        .setMessage(err)
        .setPositiveButton(android.R.string.ok,nil)
        .show()
        editChip.setChecked(true)
      end)
      if finishFunc then
        finishFunc()
      end
     else
      editChip.setChecked(true)
    end
   else
    local exitFunc=EditorUtil.PreviewFunc[fileType.."Exit"]
    if exitFunc then
      exitFunc()
    end
    EditorUtil.switchEditor(EditorUtil.TextFileType2EditorType[fileType],EditorUtil.TextFileType2EditorLanguage[fileType])--将编辑器切换为Lua编辑器
  end
  return EditorUtil
end
return EditorUtil