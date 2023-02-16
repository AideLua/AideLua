--[[
EditorsManager: metatable(class): 编辑器管理器
EditorsManager.keyWords: 编辑器提示关键词列表
EditorsManager.jesse205KeyWords: Jesse205库关键词列表
EditorsManager.fileType2Language: 文件类型转语言索引列表
EditorsManager.actions: 编辑器事件列表
EditorsManager.actions.undo(): 撤销
EditorsManager.actions.redo():重做
EditorsManager.actions.format(): 格式化
EditorsManager.actions.commented():注释
EditorsManager.actions.getText(): string: 获取编辑器文字内容
EditorsManager.actions.setText(...): 设置编辑器文字内容
EditorsManager.actions.check(show): 查错
  show: string: 展示结果
EditorsManager.actions.paste(text): 粘贴文字内容
  text: string: 文字
EditorsManager.actions.setTextSize(size): 设置文字大小
  size: number: 文字大小
EditorsManager.actions.search(text,gotoNext): 搜索
EditorsManager.openNewContent(filePath,fileType,decoder): 打开新内容
  filePath: string: 文件路径
  fileType: string: 文件扩展名
  decoder: metatable(map): 文件解析工具
EditorsManager.startSearch(): 启动搜索
EditorsManager.save2Tab(): 保存到标签
EditorsManager.checkEditorSupport(name): 检查编辑器是否支持功能
  name: string: 功能名称
EditorsManager.isEditor(): 是不是可编辑的编辑器
EditorsManager.switchPreview(state): 切换预览
  state: boolean: 状态
EditorsManager.switchLanguage(language): 切换语言
  language: Object: 语言
EditorsManager.switchEditor(editorType): 切换编辑器
  editorType: string: 编辑器类型
EditorsManager.symbolBar: table(class): 符号栏
EditorsManager.symbolBar.psButtonClick: 符号栏按钮点击时输入符号点击事件
EditorsManager.symbolBar.newPsButton(text): 初始化一个符号栏按钮
EditorsManager.symbolBar.refreshSymbolBar(state): 刷新符号栏状态
  state: boolean: 开关状态
]]

local EditorsManager={}
local managerActions={}
---v5.1.1+
local managerActionsWithEditor={}

EditorsManager.actions=managerActions
EditorsManager.actionsWithEditor=managerActionsWithEditor

--编辑器活动(事件)，视图列表(table)，编辑器(View)，编辑器类型(String) 编辑器配置(table)
local editorActions,editorGroupViews,editor,editorParent,editorType,editorConfig

import "io.github.rosemoe.editor.widget.CodeEditor"
import "io.github.rosemoe.editor.langs.EmptyLanguage"
import "io.github.rosemoe.editor.langs.desc.JavaScriptDescription"
import "io.github.rosemoe.editor.langs.html.HTMLLanguage"
import "io.github.rosemoe.editor.langs.java.JavaLanguage"
import "io.github.rosemoe.editor.langs.python.PythonLanguage"
import "io.github.rosemoe.editor.langs.universal.UniversalLanguage"

local onKeyShortcut=function(super,keyCode,event)
  local filteredMetaState = event.getMetaState() & ~KeyEvent.META_CTRL_MASK;
  if (KeyEvent.metaStateHasNoModifiers(filteredMetaState)) then
    if keyCode==KeyEvent.KEYCODE_C or keyCode==KeyEvent.KEYCODE_V or keyCode==KeyEvent.KEYCODE_X or keyCode==KeyEvent.KEYCODE_A then
      return super(keyCode,event)
    end
  end
  return onKeyShortcut(keyCode,event)
end

local function toCustomEditorView(CodeEditor)
  return function(context)
    return luajava.override(CodeEditor,{
      onKeyShortcut=onKeyShortcut,
    })
  end
end
EditorsManager.toCustomEditorView=toCustomEditorView

MyLuaEditor=toCustomEditorView(LuaEditor)
MyCodeEditor=function(context)
  local scroller
  local view
  view=luajava.override(CodeEditor,{
    onKeyShortcut=onKeyShortcut,
    computeScroll=function(super)
      MyAnimationUtil.ScrollView.onScrollChange(view,scroller.getCurrX(),scroller.getCurrY(),0,0,appBarLayout)
      super()
    end
  })
  scroller=view.getScroller()
  return view
end

EditorsManager.PSBarHorizontalScrollView={
  _baseClass=HorizontalScrollView,
  __call=function(self,context)
    local view
    local isBarTop=false
    local initialMotionX
    view=luajava.override(HorizontalScrollView,{
      onInterceptTouchEvent=function(super,event)
        local action=event.getAction()
        local x=event.getX()
        if action==MotionEvent.ACTION_DOWN then
          isBarTop=view.getScrollX()<=0
          initialMotionX=x
          super(event)
          if isBarTop then
            drawerContainer.onInterceptTouchEvent(event)
          end
        end
        if isBarTop and initialMotionX<=x then
          drawerContainer.onInterceptTouchEvent(event)
          if view.getScrollX()<=0 then
            drawerContainer.onTouchEvent(event)
          end
         else
          return super(event)
        end
        --super(event)
      end
    },context)
    return view
  end,
}
setmetatable(EditorsManager.PSBarHorizontalScrollView,EditorsManager.PSBarHorizontalScrollView)


import "editorLayouts"


---字体改变监听器
---在 v5.1.0(51099) 添加
local typefaceChangeListeners={}

---配置更改监听器
---在 v5.1.0(51099) 添加
local sharedDataChangeListeners={}
local sharedDataCache={}
setmetatable(sharedDataChangeListeners,{__index=function(self,key)
    local listeners={}
    rawset(self,key,listeners)
    return listeners
end})
setmetatable(sharedDataCache,{__index=function(self,key)
    local value=getSharedData(key)
    rawset(self,key,value)
    return value
end})
EditorsManager.typefaceChangeListeners=typefaceChangeListeners
EditorsManager.sharedDataChangeListeners=sharedDataChangeListeners

--获取字体Typeface
local function getEditorTypefaces()
  --常规，粗体，斜体
  local typeface,boldTypeface,italicTypeface
  local id=oldEditorFontId
  if id==0 then--默认，自动读取androlua字体
    local fontDir=LuaApplication.getInstance().getLuaExtDir("fonts")

    --常规
    local defaultFile=File(fontDir, "default.ttf")
    if defaultFile.exists() then
      typeface=Typeface.createFromFile(defaultFile)
     else
      typeface=Typeface.MONOSPACE
    end

    --粗体
    local boldFile=File(fontDir, "bold.ttf")
    if boldFile.exists() then
      boldTypeface=Typeface.createFromFile(boldFile)
     else
      boldTypeface=Typeface.create(typeface,Typeface.BOLD)
    end

    --斜体
    local italicFile=File(fontDir, "italic.ttf")
    if italicFile.exists() then
      italicTypeface=Typeface.createFromFile(italicFile)
     else
      italicTypeface=Typeface.create(typeface,Typeface.ITALIC)
    end
   elseif id==1 then--JetBrains Mono
    typeface=ResourcesCompat.getFont(activity, R.font.jetbrainsmono)
    boldTypeface=Typeface.create(typeface,Typeface.BOLD)
    italicTypeface=ResourcesCompat.getFont(activity, R.font.jetbrainsmonoitalic)
   elseif id==2 then--Cascadia Code
    typeface=ResourcesCompat.getFont(activity, R.font.cascadiacode)
    boldTypeface=Typeface.create(typeface,Typeface.BOLD)
    italicTypeface=ResourcesCompat.getFont(activity, R.font.cascadiacodeitalic)
   elseif id==3 then--系统字体
    typeface=Typeface.DEFAULT
    boldTypeface=Typeface.DEFAULT_BOLD
    italicTypeface=Typeface.create(typeface,Typeface.ITALIC)
   elseif id==4 then--衬线，中文为宋体
    typeface=Typeface.SERIF
    boldTypeface=Typeface.create(typeface,Typeface.BOLD)
    italicTypeface=Typeface.create(typeface,Typeface.ITALIC)
  end
  return typeface,boldTypeface,italicTypeface
end
EditorsManager.getEditorTypefaces=getEditorTypefaces

---刷新字体，在 v5.1.0(51099) 添加
function EditorsManager.refreshTypeface()
  local typeface,boldTypeface,italicTypeface=EditorsManager.getEditorTypefaces()
  local typefaceChangeListeners=EditorsManager.typefaceChangeListeners
  for index=1,#typefaceChangeListeners do
    typefaceChangeListeners[index](typeface,boldTypeface,italicTypeface)
  end
end

--检查字体是否待刷新，是的话就手动刷新，在 v5.1.0(51099) 添加
function EditorsManager.checkAndRefreshTypeface()
  local newEditorFontId = getSharedData("editor_font")
  if oldEditorFontId ~= newEditorFontId then
    oldEditorFontId = newEditorFontId--必须先赋值，因为下面的刷新靠这个识别的
    EditorsManager.refreshTypeface()
  end
end

--检查并刷新SharedData监听器
function EditorsManager.checkAndRefreshSharedDataListeners()
  for key,listeners in pairs(sharedDataChangeListeners) do
    local newValue=getSharedData(key)
    if rawget(sharedDataCache,key)~=newValue then
      sharedDataCache[key]=newValue
      for index=1,#listeners do
        listeners[index](newValue)
      end
    end
  end
end

--默认的管理器的活动事件
local function generalActionEvent(editorConfig,name1,name2,...)
  local func=editorConfig.action[name1]
  if func then--func不为nil，说明编辑器支持此功能
    local editorGroupViews=editorConfig.initedViews
    if func=="default" then
      return true,editorGroupViews.editor[name2](...)
     else
      return func(editorGroupViews,editorConfig,...)
    end
   elseif func==false then
    showSnackBar("The editor does not support this operation")
    return false
   else
    --print("警告：编辑器不支持的调用",name1)
    return nil
  end
end

function managerActionsWithEditor.getText(editorConfig)--获取编辑器文字内容
  local _,text=generalActionEvent(editorConfig,"getText","getText")
  if text then
    return tostring(text)
  end
end

function managerActionsWithEditor.search(editorConfig,text,gotoNext)--搜索
  local searchActions=editorConfig.action.search
  if searchActions then
    local editorGroupViews=editorConfig.initedViews
    if searchActions=="default" or searchActions.search=="default" then
      if gotoNext then
        editorGroupViews.editor.findNext(text)
      end
     elseif searchActions.search then
      searchActions.search(editorGroupViews,editorConfig,text,gotoNext)
    end
  end
end

---通用api
---v5.1.1+
setmetatable(managerActionsWithEditor,{__index=function(self,key)
    local action
    if key:sub(1,3)=="get" then
      action=function(editorConfig,...)
        local _,content=generalActionEvent(editorConfig,key,key,...)
        return content
      end
     else
      action=function(editorConfig,...)
        return generalActionEvent(editorConfig,key,key,...)
      end
    end
    rawset(self,key,action)
    return action
end})


--默认的管理器的活动事件
--[[
local function generalActionEvent(name1,name2,...)
  local func=editorActions[name1]
  if func then--func不为nil，说明编辑器支持此功能
    if func=="default" then
      return true,editor[name2](...)
     else
      return func(editorGroupViews,editorConfig,...)
    end
   elseif func==false then
    showSnackBar("The editor does not support this operation")
    return false
   else
    --print("警告：编辑器不支持的调用",name1)
    return nil
  end
end]]

---通用API
---在 v5.1.0(51099) 上添加
setmetatable(managerActions,{__index=function(self,key)
    local actionWithEditor=managerActionsWithEditor[key]
    local action=function(...)
      return actionWithEditor(editorConfig,...)
    end
    rawset(self,key,action)
    return action
end})

--保存到标签
function EditorsManager.save2Tab()
  local text=EditorsManager.actions.getText()
  if text then
    FilesTabManager.changeContent(text)--改变Tab保存的内容
    --else--防止意外调用函数，但是。。。
    --error("EditorsManager.actions.save2Tab:无法获取内容")
  end
end

--打开新内容
function EditorsManager.openNewContent(filePath,fileType,decoder,keepHistory)
  if EditorsManager.isEditor() then
    local fileConfig=FilesTabManager.fileConfig
    local content,err=decoder.read(filePath)
    if content then
      --fileConfig.newContent~=content
      if tostring(managerActions.getText())~=content or not(keepHistory) then
        fileConfig.oldContent=content
        fileConfig.newContent=content
        fileConfig.changed=false
        if keepHistory then
          managerActions.selectText(false)
          assert(managerActions.setText(content,true),"The editor failed to set the text. Please pay attention to backup data.")
         else
          assert(managerActions.setText(content),"The editor failed to set the text. Please pay attention to backup data.")
        end
        --编辑器滚动历史
        local scrollConfig=filesScrollingDB:get(FilesTabManager.getScrollDbKeyByPath(filePath))
        if scrollConfig then
          managerActions.setSelection(scrollConfig.selection or 0)
          managerActions.setTextSize(scrollConfig.size or math.dp2int(14))
          managerActions.scrollTo(scrollConfig.x or 0,scrollConfig.y or 0)
        end

        EditorsManager.refreshEditorScrollState()
      end
      return true
     else
      return false,err
    end
   else
    --v5.1.1新增editorConfig
    decoder.apply(filePath,fileType,editor,editorConfig)
    EditorsManager.refreshEditorScrollState()
    return true
  end
end

--启动搜索
local searching,searchedContent
function EditorsManager.startSearch()
  local searchActions=editorActions.search
  if searchActions=="default" then
    searchActions={}--"default"就相当于是一张空的table，所有的一律默认
  end
  if searchActions then
    local search=managerActions.search--搜索
    searching=true
    if searchActions.start then
      searchActions.start(editorGroupViews,editorConfig)
    end
    local config={
      onSearch=function(text)
        search(text,true)
      end,
      onIndex=function(text)
        searchedContent=text
        search(text)
      end,
      onCancel=function()
        searching=false
        if searchActions.finish then--结束搜索
          searchActions.finish(editorGroupViews,editorConfig)
        end
      end
    }
    local ids=SearchActionMode(config)
    if searchedContent then--恢复已搜索的内容
      ids.searchEdit.text=searchedContent
      ids.searchEdit.setSelection(utf8.len(tostring(searchedContent)))
    end
   else
    showSnackBar(R.string.file_not_supported)
  end
end

function EditorsManager.checkEditorSupport(name)
  return toboolean(editorActions and editorActions[name])
end

function EditorsManager.isEditor()
  return EditorsManager.checkEditorSupport("setText")
end

EditorsManager.isPreviewing=false
---v5.1.1+
function EditorsManager.switchPreviewState(state)
  if state then
    previewChip.setChecked(true)
   else
    editChip.setChecked(true)
  end
  EditorsManager.isPreviewing=state
end

--切换预览
function EditorsManager.switchPreview(state)
  --todo: 切换预览
  FilesTabManager.saveFile()
  EditorsManager.switchPreviewState(state)
  local fileConfig=FilesTabManager.fileConfig
  local decoder=fileConfig.decoder
  local nowDecoder=state and decoder.preview or decoder
  EditorsManager.switchEditorByDecoder(nowDecoder)
  local success1,success2,msg=pcall(function()
    return assert(EditorsManager.openNewContent(fileConfig.path,fileConfig.fileType,nowDecoder,true))
  end)
  if not success1 then
    showSimpleDialog("Preview failed",success2)
   elseif not success2 then
    showSimpleDialog("Preview failed",msg)
  end
end

function EditorsManager.refreshPreviewButtonVisibility()
  if FilesTabManager.openState and FilesTabManager.fileConfig.decoder.preview and getSharedData("editor_previewButton") then
    previewChipCardView.setVisibility(View.VISIBLE)
   else
    previewChipCardView.setVisibility(View.GONE)
  end
end

function EditorsManager.switchLanguage(language)
  editor.setEditorLanguage(language)
end

---切换编辑器。不考虑预览功能
---@param newEditorType string 新编辑器名称（虽然变量名上写的是类型，但其实是一个东西）
function EditorsManager.switchEditor(newEditorType)
  if editorType==newEditorType then--如果已经是当前编辑器，则不需要再切换一次了
    --print("警告：编辑器无效切换")
    return
  end
  if editor and EditorsManager.isEditor() then
    managerActions.setText("")
  end
  editorConfig=editorLayouts[newEditorType]
  editorConfig.name=newEditorType

  --检查是不是真的存在这个编辑器
  if not(editorConfig) then
    error("编辑器不存在")
    return
  end

  --首先把已添加到视图的编辑器移除
  editorGroup.removeAllViews()

  editorType=newEditorType

  editorActions=editorConfig.action
  if editorActions==nil then--啥操作都不行
    editorActions={}
    editorConfig.action=editorActions
  end

  --智能获取编辑器视图
  editorGroupViews=editorConfig.initedViews
  if editorGroupViews==nil then--未初始化试视图
    editorGroupViews={}
    loadlayout2(editorConfig.layout,editorGroupViews,LinearLayout)
    if editorConfig.init then
      editorConfig.init(editorGroupViews,editorConfig)
    end
    editorConfig.initedViews=editorGroupViews
    local editorGroupViews,editorConfig=editorGroupViews,editorConfig--因为以前这俩变量是全局变量，不可靠
    --字体改变
    local onTypefaceChangeListener=editorConfig.onTypefaceChangeListener
    if onTypefaceChangeListener then
      local function callListener(typeface,boldTypeface,italicTypeface)
        onTypefaceChangeListener(editorGroupViews,editorConfig,editorGroupViews.editor,typeface,boldTypeface,italicTypeface)
      end
      table.insert(typefaceChangeListeners,callListener)
      callListener(getEditorTypefaces())--添加完再响应也不迟
    end

    --配置改变
    local onSharedDataChangeListeners=editorConfig.onSharedDataChangeListeners
    if onSharedDataChangeListeners then
      for key,listener in pairs(onSharedDataChangeListeners) do
        local function callListener(newValue)
          listener(editorGroupViews,editorConfig,editorGroupViews.editor,newValue)
        end
        local listeners=sharedDataChangeListeners[key]--获取key对应的列表
        table.insert(listeners,callListener)
        callListener(sharedDataCache[key])
      end
    end

  end
  editor=editorGroupViews.editor
  editorParent=editorGroupViews.editorParent
  editorGroup.addView(editorParent)
  --必须加分号，否则编译器会认为这个括号是给上一个返回值调用的
  ;(editor or editorParent).requestFocus()
  EditorsManager.refreshEditorScrollState()

  PluginsUtil.callElevents("onSwitchEditor", newEditorType,editorConfig)
end

---同时切换编辑器和语言，一般用于打开文本文件
---@param decoder FileDecoder 文件解析工具
function EditorsManager.switchEditorByDecoder(decoder)
  --先切换编辑器，后切换编辑器语言，因为语言的设置是给当前正在使用的编辑器使用的
  EditorsManager.switchEditor(decoder.editor)
  if decoder.language then
    EditorsManager.switchLanguage(decoder.language)
  end
end

---刷新当前编辑器滚动状态
function EditorsManager.refreshEditorScrollState()
  if editorConfig then
    local scrollState=editorConfig.supportScroll
    if scrollState==true then
      MyAnimationUtil.ScrollView.onScrollChange(editor,managerActions.getScrollX(),managerActions.getScrollY(),0,0,appBarLayout,nil)
     elseif scrollState then
      scrollState(editorGroupViews,editorConfig)
     else
      MyAnimationUtil.ScrollView.onScrollChange(editor,0,0,0,0,appBarLayout,nil)
    end
  end
end

function EditorsManager.init()
  --阻止Chip取消选中
  local previewChipGroupSelectedId
  previewChipGroup.setOnCheckedChangeListener{
    onCheckedChanged=function(chipGroup, selectedId)
      if selectedId==-1 and previewChipGroupSelectedId then
        local chip=chipGroup.findViewById(previewChipGroupSelectedId)
        chip.setChecked(true)
        return
       elseif chipGroup.getParent().getVisibility()==View.VISIBLE then
        local chip=chipGroup.findViewById(selectedId)
        if chip then
          previewChipGroupSelectedId=chip.getId()
          return
        end
      end
      previewChipGroupSelectedId=nil
    end
  }

  editChip.onClick=function()
    EditorsManager.switchPreview(false)

  end
  previewChip.onClick=function()
    EditorsManager.switchPreview(true)
  end

  EditorsManager.symbolBar.refresh(oldEditorSymbolBar) -- 刷新符号栏状态
  --EditorsManager.switchEditor("NoneView")
end

local symbolBar={}
EditorsManager.symbolBar=symbolBar
--在 v5.1.0(51099) 添加
symbolBar.symbols={
  --显示,显示2(为括号而准备),粘贴(默认显示),覆盖(默认粘贴),辅助提示,辅助英文提示,覆盖时移动光标偏移量
  {"func()",false,"function()","function %s()\n\nend","函数(体)","Function (Body)",-4},
  {"(",")",nil,nil,"小括号","Parentheses",-1},
  {"[","]",nil,nil,"中括号","Brackets",-1},
  {"{","}",nil,nil,"大括号","Curly Brackets",-1},
  {"\"",true,nil,nil,"双引号","Double quotation"},
  {"=",nil,nil,nil,"等号","Equal"},
  {":",nil,nil,nil,"冒号","Colon"},
  {".",nil,nil,nil,"小数点","Point"},
  {",",nil,nil,nil,"逗号","Comma"},
  {";",nil,nil,nil,"分号","Semicolon"},
  {"_",nil,nil,nil,"下划线","Underline"},
  {"+",nil,nil,nil,"加号","Plus"},
  {"-",nil,nil,nil,"减号","Minus"},
  {"*",nil,nil,nil,"星号","Asterisk"},
  {"/",nil,nil,nil,"斜杠","Slash"},
  {"\\",nil,nil,nil,"反斜杠","Backslash"},
  {"%",nil,nil,nil,"百分号","Percent"},
  {"#",nil,nil,nil,"井号","Hashtag"},
  {"^",nil,nil,nil,"插入符","Caret"},
  {"$",nil,nil,nil,"美元","Dollar"},
  {"?",nil,nil,nil,"问好","Question"},
  {"&",nil,nil,nil,"与","And"},
  {"|",nil,nil,nil,"或","Or"},
  {"<",">",nil,nil,"尖括号","Angle bracket",-1},
  {"~",nil,nil,nil,"波浪号","Tilde"},
  {"'",true,nil,nil,"单引号","Single quotation"},
}

local loadedSymbolBar=false

---在 v5.1.0(51099) 上添加
---获取符号栏要粘贴到文字
function EditorsManager.getReallPasteText(view)
  local selectedText=managerActions.getSelectedText()
  local config=view.tag
  local text=view.text
  if selectedText and selectedText~="" then
    return (config[4] and config[4]:format(selectedText)) or --识别大内容
    (config[2] and config[1]..selectedText..config[2]) or--识别括号
    config[3] or --识别缩写
    text--显示的文字
   else
    return config[3] or text
  end
end

---在 v5.1.0(51099) 添加
---符号栏按钮点击时输入符号
---@param view View 按钮视图
function symbolBar.onButtonClickListener(view)
  local config=view.tag
  local selectedText=managerActions.getSelectedText()
  
  if managerActions.paste(config.reallyText) then
    view.performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
    --移动光标到指定位置
    if EditorsManager.checkEditorSupport("setSelection") and EditorsManager.checkEditorSupport("getSelectionEnd") then
      if selectedText and selectedText~="" then--已选择文字
        local move=config[7]
        if move then
          managerActions.setSelection(managerActions.getSelectionEnd()+move)
        end
      end
    end
  end
end

---此API已在 v5.1.0(51099) 废除
function symbolBar.psButtonClick()
  print("警告","symbolBar.psButtonClick","此API已在 v5.1.0 废除")
end

---在 v5.1.0(51099) 添加
---在 v5.1.1(51199) 废除
---符号栏按钮长按时提示
function symbolBar.onButtonLongClickListener(view)
  print("警告","symbolBar.onButtonLongClickListener","此API已在 v5.1.1 废除")
end

---在 v5.1.1(51199) 添加
---符号栏按钮长按时提示
--@type View.OnTouchListener
symbolBar.onButtonTouchListener=View.OnTouchListener({
  onTouch=function(view,event)
    local action=event.getAction()
    if action==MotionEvent.ACTION_DOWN then
      local reallyText=EditorsManager.getReallPasteText(view)
      TooltipCompat.setTooltipText(view,reallyText)
      view.tag.reallyText=reallyText
    end
  end
})

---初始化一个符号栏按钮
---@param text string 显示的文字
---@param config table 按钮配置 (在 v5.1.0(51099) 上添加)
function symbolBar.newPsButton(text,config)
  local button=loadlayout2({
    AppCompatTextView;
    onClick=symbolBar.onButtonClickListener;
    text=text;
    tag=config;
    contentDescription=config[getLocalLangObj(5, 6)];
    gravity="center";
    layout_height="fill";
    typeface=Typeface.DEFAULT_BOLD;--加粗一下，看的快
    paddingLeft="8dp";--保持风格统一
    paddingRight="8dp";
    minWidth="40dp";--设置最小宽度，减少误触
    allCaps=false;
    focusable=true;
    textColor=theme.color.textColorPrimary;
    background=ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary);
  })
  button.setOnTouchListener(symbolBar.onButtonTouchListener)
  return button
end

---刷新符号栏状态
---@param state boolean 新状态
function symbolBar.refresh(state)
  if state then
    if not(loadedSymbolBar) then--没有加载过符号栏，就加载一次p
      for index,group in ipairs(symbolBar.symbols) do
        local group2
        local second=group[2]
        if second then--是成对符号
          if second==true then--是相同成对符号
            group[2]=group[1]
           else
            group2=table.clone(group)--配置不一样，复制一份
            local aTIndex=getLocalLangObj(5, 6)
            if group[aTIndex] then
              group[aTIndex]=group[aTIndex].." ("..getLocalLangObj("左", "Left")..")"
              group2[aTIndex]=group2[aTIndex].." ("..getLocalLangObj("右", "Right")..")"
            end
          end
        end
        ps_bar.addView(symbolBar.newPsButton(group[1],group))
        if second and second~=true then
          ps_bar.addView(symbolBar.newPsButton(group2[2],group2))
        end
      end
      ps_paste=nil
      loadedSymbolBar=true
    end
    ps_bar.parent.setVisibility(View.VISIBLE)
   else
    ps_bar.parent.setVisibility(View.GONE)
  end
end

---v5.1.0(51099)+
---放大镜管理器
---@type MagnifierManager
local magnifierManager={}
local magnifierUpdateRunnable
local magnifierAutoUpdateEnabled=false
local skipUpdateTime=0
EditorsManager.magnifier=magnifierManager
function magnifierManager.refresh()
  magnifierManager.magnifyEnabled = getSharedData("editor_magnify")
  if not(magnifierManager.magnifier) and magnifierManager.magnifyEnabled then
    local success=pcall(function()--放大镜，可能不存在，但不排除有部分ROM会自己实现
      import "android.widget.Magnifier"
      magnifierManager.magnifier=Magnifier(editorGroup)
    end)
    if not success then
      import "com.jesse205.widget.MyMagnifier"
      magnifierManager.magnifier=MyMagnifier(editorGroup)
    end
  end
end
function magnifierManager.isAvailable()
  return magnifierManager.magnifyEnabled and magnifierManager.magnifier
end
function magnifierManager.show(x,y)
  magnifierManager.magnifier.show(x,y)
  skipUpdateTime=skipUpdateTime+1
end
magnifierUpdateRunnable=Runnable({
  run=function()
    editorGroup.post(magnifierUpdateRunnable)
    if magnifierAutoUpdateEnabled then
      if skipUpdateTime==0 then
        magnifierManager.magnifier.update()
       else
        skipUpdateTime=skipUpdateTime-1
      end
    end
  end
})

function magnifierManager.startAutoUpdate()
  if not magnifierAutoUpdateEnabled then
    editorGroup.post(magnifierUpdateRunnable)
    magnifierAutoUpdateEnabled=true
  end
end
function magnifierManager.stopAutoUpdate()
  magnifierAutoUpdateEnabled=false
  editorGroup.removeCallbacks(magnifierUpdateRunnable)
end

function magnifierManager.start(x,y)
  magnifierManager.show(x,y)
  magnifierManager.startAutoUpdate()
end
function magnifierManager.stop()
  magnifierManager.stopAutoUpdate()
  magnifierManager.dismiss()
end

function magnifierManager.dismiss()
  magnifierManager.magnifier.dismiss()
end

function EditorsManager.getEditor()
  return editor
end
function EditorsManager.getEditorConfig()
  return editorConfig
end
--[[
function EditorsManager.setEditorConfig(config)
  editorConfig=config
end]]
function EditorsManager.getEditorType()
  return editorType
end
--[[
function EditorsManager.setEditorType(_type)
  editorType=_type
end]]


return createVirtualClass(EditorsManager)