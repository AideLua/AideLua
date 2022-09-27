appname="Material Design 2 输入框"--插件名
packagename="com.aidelua.md2edit"--插件包名
appver="1.0"
appcode=1099
mode="plugin"--模式：插件
utilversion="3.1"--Util版本，此变量不起作用
smallicon=true--当icon.png为小图标时，启用此项
supported2={--支持的APP
  aidelua={mincode=50499,targetcode=59999}
}
thirdplugins={}
events={
  onCreate=function(activityName)
    --import "com.jesse205.layout.MyTextInputLayout"
    import "com.jesse205.layout.MyTextInputLayout"
    MyTextInputLayout.layout.boxBackgroundMode=TextInputLayout.BOX_BACKGROUND_OUTLINE
    MyTextInputLayout.layout[2].padding="16dp";
    package.loaded["com.jesse205.layout.MyEditDialogLayout"]=nil
    import "com.jesse205.layout.MyEditDialogLayout"
    package.loaded["com.jesse205.layout.MySearchLayout"]=nil
    import "com.jesse205.layout.MySearchLayout"
    MySearchLayout.layout[2][3].layout_marginButtom="16dp"
    function setViews(viewGroup)
      for index=0,viewGroup.getChildCount()-1 do
        local view=viewGroup.getChildAt(index)
        if luajava.instanceof(view,TextInputLayout) then
          view.boxBackgroundMode=TextInputLayout.BOX_BACKGROUND_OUTLINE
          pcall(setViews,view)
         elseif luajava.instanceof(view,TextInputEditText) then
          view.setPadding(math.dp2int(16),math.dp2int(16),math.dp2int(16),math.dp2int(16))
         else
          pcall(setViews,view)
        end
      end
    end
    setViews(activity.getDecorView())
  end
}