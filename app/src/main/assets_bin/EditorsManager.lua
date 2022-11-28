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

import "editorLayouts"


---字体改变监听器
---在 v5.1.0(51099) 添加
local typefaceChangeListeners={}
EditorsManager.typefaceChangeListeners=typefaceChangeListeners

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
    typeface=ResourcesCompat.getFont(activity, R.font.jetbrainsmonoregular)
    boldTypeface=ResourcesCompat.getFont(activity, R.font.jetbrainsmonobold)
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

--[[
function managerActions.undo()--撤销
  return generalActionEvent("undo","undo")
end

function managerActions.redo()--重做
  return generalActionEvent("redo","redo")
end

function managerActions.format()--格式化
  return generalActionEvent("format","format")
end

function managerActions.commented()--注释
  return generalActionEvent("commented","commented")
end

function managerActions.format()--格式化
  generalActionEvent("format","format")
end
function managerActions.check(show)--查错
  return generalActionEvent("check","check",show)
end]]

function managerActions.getText()--获取编辑器文字内容
  local _,text=generalActionEvent("getText","getText")
  if text then
    return tostring(text)
  end
end
--[[
function managerActions.setText(...)--设置编辑器文字内容
  return generalActionEvent("setText","setText",...)
end

function managerActions.paste(text)--粘贴文字内容
  return generalActionEvent("paste","paste",text)
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
end]]
--[[
function managerActions.scrollTo(x,y)
  generalActionEvent("scrollTo","scrollTo",x,y)
end

function managerActions.selectText(select)
  generalActionEvent("selectText","selectText",select)
end

function managerActions.setSelection(l)
  generalActionEvent("setSelection","setSelection",l)
end

function managerActions.getSelectionEnd()
  local _,l=generalActionEvent("getSelectionEnd","getSelectionEnd")
  return l
end]]

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

---通用API
---在 v5.1.0(51099) 上添加
setmetatable(managerActions,{__index=function(self,key)
    local action
    if key:sub(1,3)=="get" then
      action=function(...)
        local _,content= generalActionEvent(key,key,...)
        return content
      end
     else
      action=function(...)
        return generalActionEvent(key,key,...)
      end
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
    local content=decoder.read(filePath)
    if content then
      if fileConfig.oldContent~=content or not(keepHistory) then
        fileConfig.oldContent=content
        fileConfig.newContent=content
        fileConfig.changed=false
        if keepHistory then
          managerActions.selectText(false)
          managerActions.setText(content,true)
         else
          managerActions.setText(content)
        end
        local scrollConfig=assert(loadstring(getSharedData("scroll_"..filePath) or "{}"))()
        managerActions.setSelection(scrollConfig.selection or 0)
        managerActions.setTextSize(scrollConfig.size or math.dp2int(14))
        managerActions.scrollTo(scrollConfig.x or 0,scrollConfig.y or 0)
      end
      return true
     else
      return false
    end
   else
    decoder.apply(filePath,fileType,editor)
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

--切换预览
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
  --[[
  if editorParent then
    editorGroup.removeViewAt(0)
  end]]
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
    local onTypefaceChangeListener=editorConfig.onTypefaceChangeListener
    if onTypefaceChangeListener then
      local function callOnTypefaceChangeListener(typeface,boldTypeface,italicTypeface)
        onTypefaceChangeListener(editorGroupViews,editorConfig,editorGroupViews.editor,typeface,boldTypeface,italicTypeface)
      end
      callOnTypefaceChangeListener(getEditorTypefaces())
      table.insert(typefaceChangeListeners,callOnTypefaceChangeListener)
    end
  end
  editor=editorGroupViews.editor
  editorParent=editorGroupViews.editorParent
  editorGroup.addView(editorParent)
  --必须加分号，否则编译器会认为这个括号是给上一个返回值调用的
  ;(editor or editorParent).requestFocus()

  if editorConfig.supportScroll then
    MyAnimationUtil.ScrollView.onScrollChange(editor,editor.getScrollX(),editor.getScrollY(),0,0,appBarLayout,nil)
   else
    MyAnimationUtil.ScrollView.onScrollChange(editor,0,0,0,0,appBarLayout,nil)
  end
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
      MyAnimationUtil.ScrollView.onScrollChange(editor,editor.getScrollX(),editor.getScrollY(),0,0,appBarLayout,nil)
     elseif scrollState then
      scrollState(editorGroupViews,editorConfig)
     else
      appBarLayout.setElevation(0)
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

---在 v5.1.0(51099) 上添加
---获取符号栏要粘贴到文字
function EditorsManager.getReallPasteText(view)
  local selectedText=managerActions.getSelectedText()
  local tag=view.tag
  local text=view.text
  if selectedText and selectedText~="" then
    return (tag[2] and tag[2]:format(selectedText)) or tag[1] or text
   else
    return tag[1] or text
  end
end

---符号栏按钮点击时输入符号
---@param view View 按钮视图
function symbolBar.onButtonClickListener(view)
  if managerActions.paste(EditorsManager.getReallPasteText(view)) then
    view.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY,HapticFeedbackConstants.FLAG_IGNORE_GLOBAL_SETTING)
  end
end

---此API已在 v5.1.0(51099) 改名
function symbolBar.psButtonClick(...)
  print("警告","symbolBar.psButtonClick","此API已改名")
  symbolBar.onButtonClickListener(...)
end

---在 v5.1.0(51099) 添加
---符号栏按钮长按时提示
function symbolBar.onButtonLongClickListener(view)
  TooltipCompat.setTooltipText(view,EditorsManager.getReallPasteText(view))
end

---初始化一个符号栏按钮
---@param text string 显示的文字
---@param pasteText string 默认粘贴的文字，默认为显示的文字 (在 v5.1.0(51099) 上添加)
---@param pasteText2 string 已选中时粘贴的文字，默认为pasteText (在 v5.1.0(51099) 上添加)
function symbolBar.newPsButton(text,pasteText,pasteText2)
  local button=loadlayout2({
    AppCompatTextView;
    onClick=symbolBar.onButtonClickListener;
    text=text;
    tag={pasteText,pasteText2};
    gravity="center";
    layout_height="fill";
    typeface=Typeface.DEFAULT_BOLD;--加粗一下，看的快
    paddingLeft="8dp";--保持风格统一
    paddingRight="8dp";
    minWidth="40dp";--设置最小宽度，减少误触
    allCaps=false;
    focusable=true;
    textColor=theme.color.textColorPrimary;
    background=ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary)
  })
  button.onLongClick=symbolBar.onButtonLongClickListener;

  return button
end

local loadedSymbolBar=false
---刷新符号栏状态
---@param state boolean 新状态
function symbolBar.refresh(state)
  if state then
    if not(loadedSymbolBar) then--没有加载过符号栏，就加载一次
      local ps={"func()","(",")","[","]","{","}","\"","=",":",".",",",";","_","+","-","*","/","\\","%","#","^","$","?","&","|","<",">","~","'"}
      local ps_paste={"function()"}
      local ps_paste2={"function %s()\n\nend","(%s)","(%s)","[%s]","[%s]","{%s}","{%s}",
        "\"%s\"",nil--[[=]],nil,nil,--[[.]]nil,nil--[[;]],nil,nil--[[+]],nil,nil--[[*]],nil,nil--[[\]],nil,nil--[[#]],nil,nil--[[$]],nil,nil--[[&]],
        nil--[[|]],"<%s>","<%s>",nil,"'%s'"}
      for index,content in ipairs(ps) do
        ps_bar.addView(symbolBar.newPsButton(content,ps_paste[index],ps_paste2[index]))
      end
      ps=nil
      ps_paste=nil
      loadedSymbolBar=true
    end
    bottomAppBar.setVisibility(View.VISIBLE)
   else
    bottomAppBar.setVisibility(View.GONE)
  end
end

--在 5.1.0(51099) 添加
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