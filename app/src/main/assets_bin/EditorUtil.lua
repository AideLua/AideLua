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

EditorUtil.Editors={}
EditorUtil.IsEditors={}
EditorUtil.EditorsGroup={}

EditorUtil.NowEditorType=nil
EditorUtil.NowEditor=nil
EditorUtil.IsEdtor=nil

EditorUtil.TextFileType2EditorType={
  lua="LuaEditor",
  aly="LuaEditor",

  html="LuaEditor",
  xml="LuaEditor",
  java="LuaEditor",
  py="LuaEditor",
  pyw="LuaEditor",
  txt="LuaEditor",
  gradle="LuaEditor",
  bat="LuaEditor",
  json="LuaEditor",
}

EditorUtil.TextFileType2EditorLanguage={
  --lua=LuaLanguage.getInstance(),
  --aly=LuaLanguage.getInstance(),
  --xml=LanguageXML.getInstance(),
  --[[
  html=LanguageJava.getInstance(),
  py=LanguageJava.getInstance(),
  pyw=LanguageJava.getInstance(),
  java=LanguageJava.getInstance(),
  txt=LanguageNonPro.getInstance(),
  gradle=LanguageNonPro.getInstance(),
  bat=LanguageNonPro.getInstance(),]]
}

function EditorUtil.switchEditor(editorType,language)
  for index,content in pairs(EditorUtil.EditorsGroup) do
    if editorType==index then
      local editor=EditorUtil.Editors[editorType]
      _G.NowEditor=editor
      _G.IsEdtor=EditorUtil.IsEditors[editorType]
      EditorUtil.NowEditorType=editorType
      EditorUtil.NowEditor=editor
      if language then
        xpcall(function()
          editor.setLanguage(language)
        end,
        function(err)
          print(err)
        end)
      end
      content.setVisibility(View.VISIBLE)
      editor.requestFocus()
     else
      content.setVisibility(View.GONE)
    end
  end
  return _ENV
end
return EditorUtil