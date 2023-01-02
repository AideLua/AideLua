import "com.jesse205.layout.MyEditDialogLayout"
local EditDialogBuilder={}
setmetatable(EditDialogBuilder,EditDialogBuilder)
local metatable={__index=EditDialogBuilder}
local cannotBeEmptyStr=getString(R.string.jesse205_edit_error_cannotBeEmpty)

function EditDialogBuilder.__call(class,context)
  local self={}
  setmetatable(self,metatable)
  self.context=context
  self.buttonConfigs={}
  self.checkNullButtons={}
  self.dialogBuilder=AlertDialog.Builder(context)
  return self
end

function EditDialogBuilder.__index(class,key)
  local isReturn=key:sub(1,3)=="get"
  return function(self,...)
    local result=rawget(self,"dialogBuilder")[key](...)
    if isReturn then
      return result
     else
      return self
    end
  end
end

function EditDialogBuilder:setText(text)
  self.text=text
  return self
end

function EditDialogBuilder:setHint(text)
  self.hint=text
  return self
end

function EditDialogBuilder:setHelperText(text)
  self.helperText=text
  return self
end

function EditDialogBuilder:setAllowNull(state)
  self.allowNull=state
  return self
end

local function setButton(self,text,func,defaultFunc,checkNull,buttonType)
  local onClick
  if func then
    function onClick()
      local dialog=self.dialog
      local text=self.ids.edit.text
      local editLay=self.ids.editLay
      if checkNull and self.allowNull==false then
        if text=="" then
          editLay
          .setError(cannotBeEmptyStr)
          .setErrorEnabled(true)
          return true
        end
      end
      if not(func(dialog,text)) then
        editLay.setErrorEnabled(false)
        dialog.dismiss()
        luajava.clear(dialog)
      end
    end
  end
  self.buttonConfigs[buttonType]={text,onClick,checkNull}
  if defaultFunc then--按回车键默认执行
    self.defaultFunc=onClick
  end
  return self
end

function EditDialogBuilder:setPositiveButton(text,func,defaultFunc,checkNull)
  return setButton(self,text,func,defaultFunc,checkNull,"positive")
end

function EditDialogBuilder:setNeutralButton(text,func,defaultFunc,checkNull)
  return setButton(self,text,func,defaultFunc,checkNull,"neutral")
end

function EditDialogBuilder:setNegativeButton(text,func,defaultFunc,checkNull)
  return setButton(self,text,func,defaultFunc,checkNull,"negative")
end

function EditDialogBuilder:show()
  local ids={}
  self.ids=ids
  local dialogBuilder=rawget(self,"dialogBuilder")
  local context,checkNullButtons,buttonConfigs=rawget(self,"context"),rawget(self,"checkNullButtons"),rawget(self,"buttonConfigs")
  local text,hint,helperText=rawget(self,"text"),rawget(self,"hint"),rawget(self,"helperText")
  local defaultFunc=self.defaultFunc

  dialogBuilder.setView(MyEditDialogLayout.load(nil,ids))

  for index,content in pairs(buttonConfigs) do
    dialogBuilder["set"..index:gsub("^%l", string.upper).."Button"](content[1],nil)
  end
  local dialog=dialogBuilder.show()
  local textState=toboolean(text==nil or text=="")

  for index,content in pairs(buttonConfigs) do
    local button=dialog.getButton(AlertDialog["BUTTON_"..string.upper(index)])
    if content[2] then
      button.onClick=content[2]
    end
    if content[3] then
      table.insert(checkNullButtons,button)
      if textState then
        button.setEnabled(false)
      end
    end
  end

  self.dialog=dialog

  local edit,editLay=ids.edit,ids.editLay
  edit.requestFocus()--输入框取得焦点

  if helperText then
    if type(helperText)=="number" then
      helperText=context.getString(helperText)
    end
    editLay.setHelperText(helperText)
    editLay.setHelperTextEnabled(true)
  end
  if text then
    edit.setText(text)
    edit.setSelection(utf8.len(text))--光标后置
  end
  if hint then
    if type(hint)=="number" then
      hint=getString(hint)
    end
    editLay.setHint(hint)
  end
  if defaultFunc then
    edit.onEditorAction=defaultFunc
  end

  if self.allowNull==false then
    local oldErrorEnabled=textState
    edit.addTextChangedListener({
      onTextChanged=function(text,start,before,count)
        text=tostring(text)--获取到的text是java类型的
        if text=="" and not(oldErrorEnabled) then--文件夹名不能为空
          editLay
          .setError(cannotBeEmptyStr)
          .setErrorEnabled(true)
          oldErrorEnabled=true
          for index,content in ipairs(checkNullButtons) do
            content.setEnabled(false)
          end
          return
         elseif oldErrorEnabled then
          editLay.setErrorEnabled(false)
          oldErrorEnabled=false
          for index,content in ipairs(checkNullButtons) do
            content.setEnabled(true)
          end
        end
      end
    })
  end
  return dialog
end


function EditDialogBuilder.settingDialog(adapter,views,key,data)
  local builder
  builder=EditDialogBuilder(activity)
  :setTitle(data.title)--设置标题
  :setText(data.summary)--设置文字
  :setHint(data.hint)
  :setHelperText(data.helperText)
  :setAllowNull(data.allowNull)
  :setPositiveButton(android.R.string.ok,function(dialog,text)
    data.summary=text
    setSharedData(key,text)
    adapter.notifyDataSetChanged()
  end,true,true)
  :setNegativeButton(android.R.string.no,nil)
  builder:show()
  return builder
end
return EditDialogBuilder