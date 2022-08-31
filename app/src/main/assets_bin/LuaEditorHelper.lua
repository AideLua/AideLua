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

local function isNearChar(bounds,x,y)
  local TOUCH_SLOP=12
  return (y >= (bounds.top - TOUCH_SLOP)
  and y < (bounds.bottom + TOUCH_SLOP*2)
  and x >= (bounds.left - TOUCH_SLOP)
  and x < (bounds.right + TOUCH_SLOP))
end

local function isNearChar2(editor,relativeCaretX,relativeCaretY,x,y)
  local TOUCH_SLOP=editor.getTextSize()+10
  --print(TOUCH_SLOP)
  return (y >= (relativeCaretY - TOUCH_SLOP)
  and y < (relativeCaretY + TOUCH_SLOP+100)
  and x >= (relativeCaretX - TOUCH_SLOP-40)
  and x < (relativeCaretX + TOUCH_SLOP+40))
end


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
    {"（","("},
    {"）",")"},
    {"［","["},
    {"］","]"},
    {"＇","'"},
    {"＂","\""},
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

function LuaEditorHelper.applyMagnifier(editor,magnifier,magnifierUpdateTi)
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







return LuaEditorHelper
