--[[
LuaEditorHelper: metatable(class): LuaEditor一些常用的工具
LuaEditorHelper.removePackages(editor,packages): 移除包
  editor:com.androlua.LuaEditor
  package: table(list)
]]
--混淆的配置，方便后期维护
local M2PName={
  ["com.myopicmobile.textwarrior.android.OnSelectionChangedListener"]={
    _class="b.b.a.a.e",
    onSelectionChanged="a",
  },
}

local LuaEditorHelper={}
local _clipboardActionMode=nil
local removePackages,screenToViewX,screenToViewY,isNearChar,isNearChar2

local clickingLuaEitorEvent=nil

---providers 在 v5.1.0(51099) 上添加
local providers={
  onTouchProviders={
    function(view,event)--放大镜提供者
      local magnifierManager=EditorsManager.magnifier
      if magnifierManager.isAvailable() then--这俩是全局变量，第一个确保放大镜已打开，第二个确保可以正常加载放大镜
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
            isNearChar=isNearChar2(view,relativeCaretX,relativeCaretY,x,y)
            clickingLuaEitorEvent={x=x,y=y}--保存
            if isNearChar then
              magnifierManager.start(magnifierX,magnifierY)
             else
              magnifierManager.stop()
            end
          end
         elseif action==MotionEvent.ACTION_CANCEL or action==MotionEvent.ACTION_UP then
          clickingLuaEitorEvent=nil
          magnifierManager.stop()
        end
      end
    end
  }
}--提供者们
LuaEditorHelper.providers=providers

function removePackages(editor,packages)
  for index,package in pairs(packages) do
    editor.removePackage(package)
  end
end
LuaEditorHelper.removePackages=removePackages


function screenToViewX(_textField,x)
  return x-_textField.getPaddingLeft()+_textField.getScrollX()
end
function screenToViewY(_textField,y)
  return y-_textField.getPaddingTop()+_textField.getScrollY()
end
LuaEditorHelper.screenToViewX=screenToViewX
LuaEditorHelper.screenToViewY=screenToViewY


function isNearChar(bounds,x,y)
  local TOUCH_SLOP=12
  return (y >= (bounds.top - TOUCH_SLOP)
  and y < (bounds.bottom + TOUCH_SLOP*2)
  and x >= (bounds.left - TOUCH_SLOP)
  and x < (bounds.right + TOUCH_SLOP))
end
LuaEditorHelper.isNearChar=isNearChar


function isNearChar2(editor,relativeCaretX,relativeCaretY,x,y)
  local TOUCH_SLOP=editor.getTextSize()+10
  --print(TOUCH_SLOP)
  return (y >= (relativeCaretY - TOUCH_SLOP)
  and y < (relativeCaretY + TOUCH_SLOP+100)
  and x >= (relativeCaretX - TOUCH_SLOP-40)
  and x < (relativeCaretX + TOUCH_SLOP+40))
end
LuaEditorHelper.isNearChar2=isNearChar2


function LuaEditorHelper.onEditorSelectionChangedListener(view,status,start,end_)

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
          EditorsManager.actions.commented()
         elseif id==R.id.menu_code_viewApi then
          local selectedText=view.getSelectedText()
          newSubActivity("JavaApi",{selectedText},true)
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
  if _clipboardActionMode then
    local selectedText=view.getSelectedText()
    local previewString
    local color,colorName=getColorAndHex(selectedText)
    if color then
      previewString = SpannableString(colorName or selectedText)
      previewString.setSpan(BackgroundColorSpan(color),0,#previewString,Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
      if ColorUtil.isLightColor(color) then
        previewString.setSpan(ForegroundColorSpan(theme.color.Black),0,#previewString,Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
       else
        previewString.setSpan(ForegroundColorSpan(theme.color.White),0,#previewString,Spannable.SPAN_EXCLUSIVE_INCLUSIVE)
      end
    end
    _clipboardActionMode.setTitle(previewString or android.R.string.selectTextMode)
  end
end

function LuaEditorHelper.applyStyleToolBar(editor)
  --混淆这里有一点反混淆

  editor.setOnSelectionChangedListener({
    [M2PName["com.myopicmobile.textwarrior.android.OnSelectionChangedListener"].onSelectionChanged]=function(active,selStart,selEnd)
      LuaEditorHelper.onEditorSelectionChangedListener(editor,active,selStart,selEnd)
    end
  })
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
      if text~=" " then--华为默认会在输入法插入空格
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

--未完待续
---在 v5.1.0(51099) 添加
function LuaEditorHelper.applyTouchListener(editor)
  local onTouchProviders=providers.onTouchProviders
  editor.onTouch=function(view,event)
    for index,content in pairs(onTouchProviders) do
      content(view,event)
    end
  end
  --[[
  editor.onLongClick=function(view)
    if editor_magnify and magnifier then--这俩是全局变量，第一个确保放大镜已打开，第二个确保可以正常加载放大镜
      print(1)
    end
  end]]
end

--在 v5.1.0(51099) 废除
function LuaEditorHelper.applyMagnifier(editor)
  print("警告","LuaEditorHelper.applyMagnifier","此API已废除")
  local showingMagnifier=false
  local clickingLuaEitorEvent=nil
  editor.onTouch=function(view,event)
    if editor_magnify and magnifier then--这俩是全局变量，第一个确保放大镜已打开，第二个确保可以正常加载放大镜
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
          clickingLuaEitorEvent={x=x,y=y}--保存
          if isNearChar then
            magnifier.show(magnifierX,magnifierY)
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

function LuaEditorHelper.initKeysTaskFunc(keysListJ,packagesListJ)
  require "import"
  import "androidApis.editor.androluaApis"
  import "androidApis.editor.systemApis"

  local namesCheck={}
  local application=activity.getApplication()
  local Lexer=luajava.bindClass("b.b.a.b.k")
  local lang=Lexer.e()
  local names=application.get("editorBaseList")
  if not(names) then
    names=lang.g()--获取现在的names
    application.set("editorBaseList",names)
  end
  names=luajava.astable(names)
  local keysList=luajava.astable(keysListJ)
  local packagesList=luajava.astable(packagesListJ)
  luajava.clear(keysListJ)
  luajava.clear(packagesListJ)
  for index,content in ipairs(names) do--首先把已添加的标记一下
    namesCheck[content]=true
  end
  --添加关键字
  function addWords(wordsList,indexOffset)
    for index=1,#wordsList do
      local word=wordsList[index+indexOffset]
      if not(namesCheck[word]) then--查重
        table.insert(names,word)
        namesCheck[word]=true
      end
    end
  end

  --添加包
  function addPackages(packages)
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
  local success,message=pcall(function()
    for index,content in pairs(keysList) do
      addWords(content,-1)
    end

    for index,content in ipairs({androluaApis,systemApis}) do--插入新的names
      addWords(content,0)
    end

    --androidx关键字在这里
    if activity.getSharedData("androidX_support") then
      import "androidApis.editor.androidxApis"
      addWords(androidxApis,0)
    end

    addPackages({"activity","application","LuaUtil","android","R"})
    for index,packages in pairs(packagesList) do
      for index,content in pairs(luajava.astable(packages)) do
        lang.a(index,content)
      end
    end
  end)
  lang.B(names)--设置成新的names
  return success,message
end

function LuaEditorHelper.initKeys(editor,editorParent,pencilEdit,progressBar)
  --application.set("luaeditor_initialized",false)--强制初始化编辑器
  if application.get("luaeditor_initialized") then--已初始化过编辑器
    editorParent.removeView(progressBar)--移除进度条
    editorParent.setLayoutTransition(newLayoutTransition() or nil)
   else
    editorParent.removeView(pencilEdit)--先移除view，避免手写输入以及编辑器渲染导致的bug
    editorParent.removeView(editor)
    local editorConfig=editorLayouts.LuaEditor
    local editorText=editor.text--保存一下编辑器内文字，
    editor.text=""--防止渲染文字造成的卡顿

    local keywordsList=editorConfig.keywordsList
    local packagesList=editorConfig.packagesList
    keywordsList.normalKeywords=editorConfig.normalKeywords
    if oldJesse205Support then--添加杰西205库
      --现构建，因为这个要执行的东西有一点多
      keywordsList.jesse205Words=editorConfig.jesse205Keywords
      packagesList.jesse205Words=Map({
        string=String(getTableIndexList(string)),
        utf8=String(getTableIndexList(utf8)),
        math=String(getTableIndexList(math)),
        theme=String(getTableIndexList(theme)),
        android=String(getTableIndexList(android)),
        res=String({
          "color","colorStateList","drawable","id","string",
          "dimension","int","float","boolean",
          table.unpack(getTableIndexList(res))}),
        jesse205=String(getTableIndexList(jesse205)),
        AppPath=String(getTableIndexList(AppPath)),
        MyToast=String(getTableIndexList(MyToast)),
      })
     else
      keywordsList.jesse205Words=nil
      packagesList.jesse205Words=nil
    end

    activity.newTask(LuaEditorHelper.initKeysTaskFunc,
    function(success,message)
      if not(success) then
        showErrorDialog("Load Keyword Error",message)
      end
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
    end).execute({Map(keywordsList),Map(packagesList)})
  end
end

return LuaEditorHelper
