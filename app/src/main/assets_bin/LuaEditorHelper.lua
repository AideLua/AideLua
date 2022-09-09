local LuaEditorHelper={}

local function removePackages(editor,packages)
  for index,package in pairs(packages) do
    editor.removePackage(package)
  end
end
LuaEditorHelper.removePackages=removePackages


local function screenToViewX(_textField,x)
  return x-_textField.getPaddingLeft()+_textField.getScrollX()
end
local function screenToViewY(_textField,y)
  return y-_textField.getPaddingTop()+_textField.getScrollY()
end
LuaEditorHelper.screenToViewX=screenToViewX
LuaEditorHelper.screenToViewY=screenToViewY


local function isNearChar(bounds,x,y)
  local TOUCH_SLOP=12
  return (y >= (bounds.top - TOUCH_SLOP)
  and y < (bounds.bottom + TOUCH_SLOP*2)
  and x >= (bounds.left - TOUCH_SLOP)
  and x < (bounds.right + TOUCH_SLOP))
end
LuaEditorHelper.isNearChar=isNearChar


local function isNearChar2(editor,relativeCaretX,relativeCaretY,x,y)
  local TOUCH_SLOP=editor.getTextSize()+10
  --print(TOUCH_SLOP)
  return (y >= (relativeCaretY - TOUCH_SLOP)
  and y < (relativeCaretY + TOUCH_SLOP+100)
  and x >= (relativeCaretX - TOUCH_SLOP-40)
  and x < (relativeCaretX + TOUCH_SLOP+40))
end
LuaEditorHelper.isNearChar2=isNearChar2


local _clipboardActionMode=nil
function LuaEditorHelper.onEditorSelectionChangedListener(view,status,start,end_)
  --print(Searching)
  if not(_clipboardActionMode) and status then
    local actionMode=luajava.new(ActionMode.Callback,
    {
      onCreateActionMode=function(mode,menu)
        _clipboardActionMode=mode
        mode.setTitle(android.R.string.selectTextMode)
        local inflater=mode.getMenuInflater()
        inflater.inflate(R.menu.menu_editor,menu)
        return true
      end,
      onActionItemClicked=function(mode,item)
        local id=item.getItemId()
        if id==R.id.menu_selectAll then
          view.selectAll()
         elseif id==R.id.menu_cut then
          view.cut()
         elseif id==R.id.menu_copy then
          view.copy()
         elseif id==R.id.menu_paste then
          view.paste()
         elseif id==R.id.menu_code_commented then
          EditorsManager.actions.commented(view)
         elseif id==R.id.menu_code_viewApi then
          local selectedText=view.getSelectedText()
          newSubActivity("JavaApi",{selectedText})
        end
        return false;
      end,
      onDestroyActionMode=function(mode)
        view.selectText(false)
        _clipboardActionMode=nil
      end,
    })
    activity.startSupportActionMode(actionMode)
   elseif _clipboardActionMode and not(status) then
    _clipboardActionMode.finish()
    _clipboardActionMode=nil
  end
end


function LuaEditorHelper.applyStyleToolBar(editor)
  editor.OnSelectionChangedListener=function(status,start,end_)
    LuaEditorHelper.onEditorSelectionChangedListener(editor,status,start,end_)
  end
end


function LuaEditorHelper.applyPencilInput(editor,pencilEdit)
  local cnString2EnString={
    {"，",","},
    {"（","("},
    {"）",")"},
    {"［","["},
    {"］","]"},
    {"＇","'"},
    {"＂","\""},
    {"“","\""},
    {"”","\""},
    {"〃","\""},
  }
  pencilEdit.addTextChangedListener({
    onTextChanged=function(text,start,before,count)
      text=tostring(text)
      if text~=" " then
        if text=="" then
         else
          local newText=text:match(" (.+)")
          for index,content in ipairs(cnString2EnString)
            newText=newText:gsub(content[1],content[2])
          end
          editor.paste(newText)
          --print(newText)
        end
        pencilEdit.text=" "
        pencilEdit.setSelection(1)
        editor.requestFocus()
      end
    end
  })
  pencilEdit.onFocusChange=function(view,hasFocus)
    if hasFocus then
      view.setSelection(1)
    end
  end
  pencilEdit.setBackground(nil)
end

function LuaEditorHelper.applyMagnifier(editor)
  local showingMagnifier=false
  local clickingLuaEitorEvent=nil
  editor.onTouch=function(view,event)
    --print(view.getRowWidth())
    if magnifier and editor_magnify then
      local action=event.action
      local relativeCaretX=view.getCaretX()-view.getScrollX()
      local relativeCaretY=view.getCaretY()-view.getScrollY()
      local x=event.getX()
      local y=event.getY()
      local magnifierX=x
      local magnifierY=relativeCaretY-view.getTextSize()/2+math.dp2int(2)
      local isNearChar

      if action==MotionEvent.ACTION_DOWN or action==MotionEvent.ACTION_MOVE then
        if not(clickingLuaEitorEvent) or (clickingLuaEitorEvent.x~=x or clickingLuaEitorEvent.y~=y) then
          isNearChar=isNearChar2(editor,relativeCaretX,relativeCaretY,x,y)
          clickingLuaEitorEvent={x=x,y=y}
          if isNearChar then
            magnifier.show(magnifierX,magnifierY)
            --print(magnifierX,magnifierY,x,y)
            showingMagnifier=true
            if not(magnifierUpdateTi.isRun()) then
              magnifierUpdateTi.start()
            end
            if not(magnifierUpdateTi.getEnabled()) then
              magnifierUpdateTi.setEnabled(true)
            end
           else
            if showingMagnifier then
              magnifierUpdateTi.setEnabled(false)
              magnifier.dismiss()
              showingMagnifier=false
            end
          end
        end
       elseif action==MotionEvent.ACTION_CANCEL or action==MotionEvent.ACTION_UP then
        clickingLuaEitorEvent=nil
        if showingMagnifier then
          magnifierUpdateTi.setEnabled(false)
          magnifier.dismiss()
          showingMagnifier=false
        end
      end
    end
  end
end

function LuaEditorHelper.initKeysTaskFunc(keyWords,jesse205KeyWords)
  require "import"
  import "androidApis.editor.androluaApis"
  import "androidApis.editor.systemApis"

  local namesCheck={}
  local application=activity.getApplication()
  function addPackages(lang,packages)
    for index,package in pairs(packages) do
      local methods={}
      local packageTable=_G[package]
      local packageType=type(packageTable)

      if packageType=="table" then
        for method,func in pairs(packageTable) do
          table.insert(methods,method)
        end
       elseif packageType=="userdata" then
        local inserted={}
        local class=packageTable.getClass()
        pcall(function()
          for index,content in ipairs(luajava.astable(class.getMethods())) do
            local name=content.getName()
            if not(inserted[name]) then
              inserted[name]=true
              table.insert(methods,name)
            end
          end
        end)
      end
      lang.a(package,methods)
    end
  end
  local Lexer=luajava.bindClass("b.b.a.b.k")
  local lang=Lexer.e()

  local names=application.get("editorBaseList")
  if not(names) then
    names=lang.g()--获取现在的names
    application.set("editorBaseList",names)
  end
  names=luajava.astable(names)
  for index,content in ipairs(names) do
    namesCheck[content]=true
  end

  for index,content in ipairs({androluaApis,systemApis,luajava.astable(keyWords)}) do--插入新的names
    for index,content in ipairs(content) do
      if not(namesCheck[content]) then
        table.insert(names,content)
        namesCheck[content]=true
      end
    end
  end
  if activity.getSharedData("AndroidX_Highlight") then
    import "androidApis.editor.androidxApis"
    for index,content in ipairs(androidxApis) do
      if not(namesCheck[content]) then
        table.insert(names,content)
        namesCheck[content]=true
      end
    end
  end

  addPackages(lang,{"activity","application","LuaUtil","android","R"})

  if activity.getSharedData("Jesse205Lib_Highlight") then--添加杰西205库
    notLoadTheme=true
    require "Jesse205"
    for index,content in ipairs(luajava.astable(jesse205KeyWords)) do
      if not(namesCheck[content]) then
        table.insert(names,content)
        namesCheck[content]=true
      end
    end
    for index,content in ipairs(StyleWidget.types) do
      if not(namesCheck[content]) then
        table.insert(names,content)
        namesCheck[content]=true
      end
    end
    addPackages(lang,{"string","utf8","math","theme","Jesse205","AppPath","MyToast"})
  end
  lang.B(names)--设置成新的names
  return true
end

function LuaEditorHelper.initKeys(editor,editorParent,pencilEdit,progressBar)
  --application.set("luaeditor_initialized",false)--强制初始化编辑器
  if not(application.get("luaeditor_initialized")) then--编辑器未初始化
    editorParent.removeView(pencilEdit)--先移除view，避免手写输入以及编辑器渲染导致的bug
    editorParent.removeView(editor)
    local editorText=editor.text--保存一下编辑器内文字，
    editor.text=""--防止渲染文字造成的卡顿
    local keysList={EditorsManager.keyWords,EditorsManager.jesse205KeyWords}
    activity.newTask(LuaEditorHelper.initKeysTaskFunc,
    function(success)
      editor.respan()
      editor.invalidate()--不知道干啥的，调用一下就对了
      if editorText~="" then
        editor.text=editorText
      end
      editorParent.addView(pencilEdit)
      editorParent.addView(editor)
      editorParent.removeView(progressBar)--移除进度条
      application.set("luaeditor_initialized",success)
      MyAnimationUtil.ScrollView.onScrollChange(editor,editor.getScrollX(),editor.getScrollY(),0,0,appBarLayout,nil,true)
      editorParent.setLayoutTransition(newLayoutTransition() or nil)
    end).execute(keysList)
   else--已初始化过编辑器
    editorParent.removeView(progressBar)--移除进度条
    editorParent.setLayoutTransition(newLayoutTransition() or nil)
  end
end






return LuaEditorHelper
