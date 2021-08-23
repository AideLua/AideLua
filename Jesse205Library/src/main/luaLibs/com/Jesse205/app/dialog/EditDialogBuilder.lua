import "com.Jesse205.layout.MyEditDialogLayout"
local EditDialogBuilder={}
local cannotBeEmptyStr=activity.getString(R.string.edit_error_cannotBeEmpty)
setmetatable(EditDialogBuilder,EditDialogBuilder)

EditDialogBuilder.allowNull=true

function EditDialogBuilder.__call(self,context)
  self=table.clone(self)
  self.context=context
  return self
end

function EditDialogBuilder:setTitle(text)
  self.title=text
  return self
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
      if checkNull and not(self.allowNull) then
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
      end
    end
  end
  self[buttonType]={text,onClick}
  if defaultFunc then
    self.defaultFunc=onClick
  end
  return self
end

function EditDialogBuilder:setPositiveButton(text,func,defaultFunc,checkNull)
  return setButton(self,text,func,defaultFunc,checkNull,"positiveButton")
end

function EditDialogBuilder:setNeutralButton(text,func,defaultFunc,checkNull)
  return setButton(self,text,func,defaultFunc,checkNull,"neutralButton")
end

function EditDialogBuilder:setNegativeButton(text,func,defaultFunc,checkNull)
  return setButton(self,text,func,defaultFunc,checkNull,"negativeButton")
end

function EditDialogBuilder:show()
  local ids={}
  self.ids=ids
  local context=self.context
  local positiveButton,neutralButton,negativeButton=self.positiveButton,self.neutralButton,self.negativeButton
  local text,hint,helperText=self.text,self.hint,self.helperText
  local defaultFunc=self.defaultFunc
  local dialogBuilder=AlertDialog.Builder(context)
  .setTitle(self.title)
  .setView(MyEditDialogLayout.load(nil,ids))

  if positiveButton then--设置文字
    dialogBuilder.setPositiveButton(positiveButton[1],nil)
  end
  if neutralButton then
    dialogBuilder.setNeutralButton(neutralButton[1],nil)
  end
  if negativeButton then
    dialogBuilder.setNegativeButton(negativeButton[1],nil)
  end
  local dialog=dialogBuilder.show()

  if positiveButton and positiveButton[2] then--设置点击事件
    dialog.getButton(AlertDialog.BUTTON_POSITIVE).onClick=positiveButton[2]
  end
  if neutralButton and neutralButton[2] then
    dialog.getButton(AlertDialog.BUTTON_NEUTRAL).onClick=neutralButton[2]
  end
  if negativeButton and negativeButton[2] then
    dialog.getButton(AlertDialog.BUTTON_NEGATIVE).onClick=negativeButton[2]
  end

  self.dialog=dialog

  local edit,editLay=ids.edit,ids.editLay
  edit.requestFocus()--输入框取得焦点
  inputMethodService.showSoftInput(edit,InputMethodManager.SHOW_FORCED)
  if helperText then
    if type(helperText)=="number" then
      helperText=context.getString(helperText)
    end
    editLay.setHelperText(helperText)
    editLay.setHelperTextEnabled(true)
  end
  if text then
    edit.setText(text)
  end
  if hint then
    if type(hint)=="number" then
      hint=context.getString(hint)
    end
    editLay.setHint(hint)
  end
  if defaultFunc then
    edit.onEditorAction=defaultFunc
  end
  if not(self.allowNull) then
    edit.addTextChangedListener({
      onTextChanged=function(text,start,before,count)
        text=tostring(text)
        if text=="" then--文件夹名不能为空
          editLay
          .setError(cannotBeEmptyStr)
          .setErrorEnabled(true)
          return
        end
        editLay.setErrorEnabled(false)
      end
    })
  end
  return dialog
end


function EditDialogBuilder.settingDialog(adapter,views,key,data)
  local builder
  builder=EditDialogBuilder(activity)
  :setTitle(data.title)
  :setText(data.summary)
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