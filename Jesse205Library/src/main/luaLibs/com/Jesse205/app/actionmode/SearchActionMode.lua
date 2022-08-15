import "android.view.inputmethod.InputMethodManager"
import "com.Jesse205.layout.MyTitleEditLayout"
return function(config)
  local config=config or {}
  --local inputMethodService=activity.getSystemService(Context.INPUT_METHOD_SERVICE)
  local ids={}
  local actionMode=luajava.new(ActionMode.Callback,
  {
    onCreateActionMode=function(mode,menu)
      mode.setCustomView(MyTitleEditLayout.load({
        hint=config.hint or activity.getString(R.string.abc_search_hint);
        text=config.text;
      },ids))
      ids.searchEdit.requestFocus()--搜索框取得焦点
      inputMethodService.showSoftInput(ids.searchEdit,InputMethodManager.SHOW_FORCED)

      if config.onEditorAction then--点击回车事件
        ids.searchEdit.onEditorAction=config.onEditorAction
      end
      if config.onTextChanged then--文字变化事件
        ids.searchEdit.addTextChangedListener({onTextChanged=config.onTextChanged})
      end

      if config.onCreateActionMode then
        return config.onCreateActionMode(mode,menu)
      end
      local searchItem=menu.add(R.string.abc_searchview_description_search)
      searchItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
      searchItem.setIcon(R.drawable.ic_magnify)
      return true
    end,
    onActionItemClicked=config.onActionItemClicked,
    onDestroyActionMode=config.onDestroyActionMode,
  })
  activity.startSupportActionMode(actionMode)
  return ids
end