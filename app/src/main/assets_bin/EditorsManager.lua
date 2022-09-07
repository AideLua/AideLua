--[[
EditorsManager: 编辑器管理器
EditorsManager.keyWords: 编辑器提示关键词列表
EditorsManager.jesse205KeyWords: Jesse205库关键词列表
EditorsManager.fileType2Language: 文件类型转语言索引列表
EditorsManager.actions: 编辑器事件列表
EditorsManager.actions.undo(): 撤销
EditorsManager.actions.redo():重做
EditorsManager.actions.format(): 格式化
EditorsManager.actions.commented():注释
EditorsManager.actions.getText(): 获取编辑器文字内容
EditorsManager.actions.setText(...): 设置编辑器文字内容
EditorsManager.actions.check(show): 查错
  show (string): 展示结果
EditorsManager.actions.paste(text): 粘贴文字内容
  text (string): 文字
EditorsManager.actions.setTextSize(size): 设置文字大小
  size (number): 文字大小
EditorsManager.actions.search(text,gotoNext): 搜索
EditorsManager.openNewContent(filePath,fileType,decoder): 打开新内容
  filePath (string): 文件路径
  fileType (string): 文件扩展名
  decoder (table): 文件解析工具
EditorsManager.startSearch(): 启动搜索
EditorsManager.save2Tab(): 保存到标签
EditorsManager.checkEditorSupport(name): 检查编辑器是否支持功能
  name (string): 功能名称
EditorsManager.isEditor(): 是不是可编辑的编辑器
EditorsManager.switchPreview(state): 切换预览
  state (boolean): 状态
EditorsManager.switchLanguage(language): 切换语言
  language (Object): 语言
EditorsManager.switchEditor(editorType): 切换编辑器
  editorType (string): 编辑器类型
EditorsManager.symbolBar: 符号栏
EditorsManager.symbolBar.psButtonClick: 符号栏按钮点击时输入符号点击事件
EditorsManager.symbolBar.newPsButton(text): 初始化一个符号栏按钮
EditorsManager.symbolBar.refreshSymbolBar(state): 刷新符号栏状态
  state (boolean): 开关状态
]]
local EditorsManager={}
local managerActions={}
EditorsManager.actions=managerActions
--EditorsManager.language=nil
--编辑器活动(事件)，视图列表(table)，编辑器(View)，编辑器类型(String) 编辑器配置(table)
local editorActions,editorGroupViews,editor,editorParent,editorType,editorConfig

import "io.github.rosemoe.editor.widget.CodeEditor"
import "io.github.rosemoe.editor.langs.EmptyLanguage"
import "io.github.rosemoe.editor.langs.desc.JavaScriptDescription"
import "io.github.rosemoe.editor.langs.html.HTMLLanguage"
import "io.github.rosemoe.editor.langs.java.JavaLanguage"
import "io.github.rosemoe.editor.langs.python.PythonLanguage"
import "io.github.rosemoe.editor.langs.universal.UniversalLanguage"

local function toCustomEditorView(CodeEditor)
  return function(context)
    return luajava.override(CodeEditor,{
      onKeyShortcut=function(super,keyCode,event)
        local filteredMetaState = event.getMetaState() & ~KeyEvent.META_CTRL_MASK;
        if (KeyEvent.metaStateHasNoModifiers(filteredMetaState)) then
          if keyCode==KeyEvent.KEYCODE_C or keyCode==KeyEvent.KEYCODE_V or keyCode==KeyEvent.KEYCODE_X or keyCode==KeyEvent.KEYCODE_A then
            return super(keyCode,event)
          end
        end
        return onKeyShortcut(keyCode,event)
      end,
    })
  end
end
EditorsManager.toCustomEditorView=toCustomEditorView
MyLuaEditor=toCustomEditorView(LuaEditor)
MyCodeEditor=toCustomEditorView(CodeEditor)

import "layouts.editorLayouts"

--编辑器提示关键词
EditorsManager.keyWords=String({
  --一些事件
  "onCreate",
  "onStart",
  "onResume",
  "onPause",
  "onStop",
  "onDestroy",
  "onActivityResult",
  "onResult",
  "onCreateOptionsMenu",
  "onOptionsItemSelected",
  "onTouchEvent",
  "onKeyLongPress",
  "onConfigurationChanged",
  "onHook",
  "onAccessibilityEvent",
  "onKeyUp",
  "onKeyDown",

  "onClick",
  "onTouch",
  "onLongClick",
  "onItemClick",
  "onItemLongClick",
  "onVersionChanged",
  "onScroll";
  "onScrollChange",
  "onNewIntent",
  "onSaveInstanceState",

  --一些自带的类或者包
  "android",
  "R",

  --一些常用但不自带的类
  "PhotoView",
  "LuaLexerIteratorBuilder",
})

--Jesse205库关键词
EditorsManager.jesse205KeyWords=String({
  "newActivity","getSupportActionBar","getSharedData","setSharedData",
  "getString","getPackageName","getColorStateList",

  --一些标识
  "initApp","notLoadTheme","useCustomAppToolbar",
  "resources","application","inputMethodService","actionBar",
  "notLoadTheme","darkStatusBar","darkNavigationBar",
  "window","safeModeEnable","notSafeModeEnable","decorView",

  "theme","formatResStr","autoSetToolTip",
  "showLoadingDia","closeLoadingDia","getNowLoadingDia",
  "showErrorDialog","toboolean","rel2AbsPath","copyText",
  "newSubActivity","isDarkColor","openInBrowser","openUrl",
  "loadlayout2","showSimpleDialog","getLocalLangObj",
  "newLayoutTransition",

  "AppPath","ThemeUtil","EditDialogBuilder","ImageDialogBuilder",
  "NetErrorStr","MyToast","AutoToolbarLayout","PermissionUtil",
  "AutoCollapsingToolbarLayout","SettingsLayUtil","Jesse205",
  "StyleWidget",

  --自定义View或者Util
  "MyTextInputLayout","MyTitleEditLayout","MyEditDialogLayout",
  "MyTipLayout","MySearchLayout","MyAnimationUtil","MyStyleUtil",

  --适配器
  "MyLuaMultiAdapter","MyLuaAdapter","LuaCustRecyclerAdapter",
  "LuaCustRecyclerHolder","AdapterCreator",
})

--默认的管理器的活动事件
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
end

function managerActions.undo()--撤销
  generalActionEvent("undo","undo")
end

function managerActions.redo()--重做
  generalActionEvent("redo","redo")
end

function managerActions.format()--格式化
  generalActionEvent("format","format")
end

function managerActions.commented()--注释
  generalActionEvent("commented","commented")
end

function managerActions.format()--格式化
  generalActionEvent("format","format")
end

function managerActions.check(show)--查错
  return generalActionEvent("check","check",show)
end

function managerActions.getText()--获取编辑器文字内容
  local _,text=generalActionEvent("getText","getText")
  if text then
    return tostring(text)
  end
end
function managerActions.setText(...)--设置编辑器文字内容
  return generalActionEvent("setText","setText",...)
end

function managerActions.paste(text)--粘贴文字内容
  generalActionEvent("paste","paste",text)
end

function managerActions.getTextSize()--获取文字大小
  local _,size=generalActionEvent("getTextSize","getTextSize")
  return size
end

function managerActions.setTextSize(size)--设置文字大小
  generalActionEvent("setTextSize","setTextSize",size)
end

function managerActions.getScrollX()
  local _,x=generalActionEvent("getScrollX","getScrollX")
  return x
end


function managerActions.getScrollY()
  local _,y=generalActionEvent("getScrollY","getScrollY")
  return y
end

function managerActions.scrollTo(x,y)
  generalActionEvent("scrollTo","scrollTo",x,y)
end


function managerActions.setSelection(l)
  generalActionEvent("setSelection","setSelection",l)
end

function managerActions.getSelectionEnd()
  local _,l=generalActionEvent("getSelectionEnd","getSelectionEnd")
  return l
end




function managerActions.search(text,gotoNext)--搜索
  local searchActions=editorActions.search
  if searchActions then
    if searchActions=="default" or searchActions.search=="default" then
      if gotoNext then
        editor.findNext(text)
      end
     elseif searchActions.search then
      searchActions.search(editorGroupViews,editorConfig,text,gotoNext)
    end
  end
end

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
    local content=decoder.read(filePath)
    fileConfig.oldContent=content
    fileConfig.newContent=content
    fileConfig.changed=false
    managerActions.setText(content,keepHistory or false)
    local scrollConfig=assert(loadstring(getSharedData("scroll_"..filePath) or "{}"))()
    managerActions.setSelection(scrollConfig.selection or 0)
    managerActions.setTextSize(scrollConfig.size or math.dp2int(14))
    managerActions.scrollTo(scrollConfig.x or 0,scrollConfig.y or 0)
   else
    decoder.apply(filePath,fileType,editor)
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
    local ids
    searching=true
    if searchActions.start then
      searchActions.start(editorGroupViews,editorConfig)
    end
    ids=SearchActionMode({
      onEditorAction=function(view,actionId,event)
        if event then
          search(view.text,true)
        end
      end,
      onTextChanged=function(text)
        searchedContent=text
        search(text)
      end,
      onActionItemClicked=function(mode,item)
        local title=item.title
        if title==activity.getString(R.string.abc_searchview_description_search) then
          local text=ids.searchEdit.text
          search(ids.searchEdit.text,true)
        end
      end,
      onDestroyActionMode=function(mode)
        searching=false
        if searchActions.finish then--结束搜索
          searchActions.finish(editorGroupViews,editorConfig)
        end
      end,
    })
    --local searchContent=application.get("editor_search_text")
    if searchedContent then--恢复已搜索的内容
      ids.searchEdit.text=searchedContent
      ids.searchEdit.setSelection(utf8.len(tostring(searchedContent)))
    end
   else
    showSnackBar(R.string.file_not_supported)
  end
end

function EditorsManager.checkEditorSupport(name)
  return toboolean(editorActions[name])
end

function EditorsManager.isEditor()
  return EditorsManager.checkEditorSupport("setText")
end

function EditorsManager.switchPreview(state)
  --todo: 切换预览
  print("警告：未切换预览")
end

function EditorsManager.switchLanguage(language)
  editor.setEditorLanguage(language)
end

--切换编辑器
function EditorsManager.switchEditor(newEditorType)
  if editorType==newEditorType then--如果已经是当前编辑器，则不需要再切换一次了
    --print("警告：编辑器无效切换")
    return
  end

  editorConfig=editorLayouts[newEditorType]

  --检查是不是真的存在这个编辑器
  if not(editorConfig) then
    error("Editor not found")
    return
  end

  --首先把已添加到视图的编辑器移除
  if editorParent then
    editorGroup.removeViewAt(0)
  end
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
  end
  editor=editorGroupViews.editor
  editorParent=editorGroupViews.editorParent
  editorGroup.addView(editorParent)
  ;(editor or editorParent).requestFocus()

  if editorConfig.supportScroll then
    MyAnimationUtil.ScrollView.onScrollChange(editor,editor.getScrollX(),editor.getScrollY(),0,0,appBarLayout,nil)
   else
    MyAnimationUtil.ScrollView.onScrollChange(editor,0,0,0,0,appBarLayout,nil)
  end
end

--同时切换编辑器和语言，一般用于打开文本文件
function EditorsManager.switchEditorByDecoder(decoder)
  --先切换编辑器，后切换编辑器语言，因为语言的设置是给当前正在使用的编辑器使用的
  --print(decoder.editor)
  EditorsManager.switchEditor(decoder.editor)
  if decoder.language then
    EditorsManager.switchLanguage(decoder.language)
  end
end

function EditorsManager.refreshEditorScrollState()
  if editorConfig then
    local scrollState=editorConfig.supportScroll
    if scrollState==true then
      MyAnimationUtil.ScrollView.onScrollChange(editor,editor.getScrollX(),editor.getScrollY(),0,0,appBarLayout,nil)
     elseif scrollState then
      scrollState(editorGroupViews,editorConfig)
     else
      appBarLayout.setElevation(0)
    end
  end
end

--[[
local function fixFileDecodersItem(config)
  local super=config.super
  if super then
    local oldConfig=FileDecoders[super]
    fixFileDecodersItem(oldConfig)
    safeCloneTable(oldConfig,config)
    config.super=nil
  end
end]]

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
  EditorsManager.switchEditor("NoneView")


end



local symbolBar={}
EditorsManager.symbolBar=symbolBar

--符号栏按钮点击时输入符号
function symbolBar.psButtonClick(view)
  local text=view.text
  EditorsManager.actions.paste(text)
end

--初始化一个符号栏按钮
function symbolBar.newPsButton(text)
  return loadlayout2({
    AppCompatTextView;
    onClick=symbolBar.psButtonClick;
    text=text;
    gravity="center";
    layout_height="fill";
    typeface=Typeface.DEFAULT_BOLD;--加粗一下，看的快
    paddingLeft="8dp";--保持风格统一
    paddingRight="8dp";
    minWidth="40dp";--设置最小宽度，减少误触
    allCaps=false;
    --padding="16dp";
    focusable=true;
    textColor=theme.color.textColorPrimary;
    background=ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary)
  })
end

local loadedSymbolBar=false
function symbolBar.refresh(state)--刷新符号栏状态
  if state then
    if not(loadedSymbolBar) then--没有加载过符号栏，就加载一次
      local ps={"function()","(",")","[","]","{","}","\"","=",":",".",",",";","_","+","-","*","/","\\","%","#","^","$","?","&","|","<",">","~","'"};
      for index,content in ipairs(ps) do
        ps_bar.addView(symbolBar.newPsButton(content))
      end
      ps=nil
      loadedSymbolBar=true
    end
    bottomAppBar.setVisibility(View.VISIBLE)
   else
    bottomAppBar.setVisibility(View.GONE)
  end
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