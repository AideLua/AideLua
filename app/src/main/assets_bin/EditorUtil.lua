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
  xml="CodeEditor",
  java="CodeEditor",
  py="CodeEditor",
  pyw="CodeEditor",
  txt="CodeEditor",
  gradle="CodeEditor",
  bat="CodeEditor",
  json="CodeEditor",
}

EditorUtil.TextFileType2EditorLanguage={
  --lua=LuaLanguage.getInstance(),
  --aly=LuaLanguage.getInstance(),
  --xml=LanguageXML.getInstance(),

  html=HTMLLanguage(),
  xml=JavaLanguage(),
  py=PythonLanguage(),
  pyw=PythonLanguage(),
  java=JavaLanguage(),
  txt=EmptyLanguage(),
  gradle=EmptyLanguage(),
  bat=EmptyLanguage(),
  html=HTMLLanguage(),
  json=HTMLLanguage(),
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
     else
      content.setVisibility(View.GONE)
    end
  end
  return _ENV
end
return EditorUtil