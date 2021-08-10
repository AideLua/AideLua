--import "androidx.core.content.res.ResourcesCompat"

appInfo={
  {
    name=R.string.app_name,
    message="依赖Aide的一款Lua编辑器",
    icon=R.mipmap.ic_launcher,
    --typeface=ResourcesCompat.getFont(activity,R.font.app),
    click=function()
      openUrl("https://gitee.com/Jesse205/AideLua")
    end,
  },
  {
    name=R.string.windmill,
    message="为极客和程序员等打造，重认手机上的工具",
    icon=R.drawable.ic_windmill,
    click=function()
      openUrl("http://www.agyer.com/")
    end,
  },
}

developers={
  {
    name="Eddia",
    qq=2140125724,
    message="AideLua 开发者",
  },
  {
    name="xiaoyi",
    qq=2821981550,
    message="快乐程序 运营者",
  },
}

openSourceLicenses=true

qqGroups={
  {
    name="Edde 后台管理交流群",
    id=586351981,
  },
  {
    name="Aide Lua Bug测试群",
    id=680850455,
  },
  {
    name="Aide Lua 尝鲜群",
    id=628045718,
  },
  {
    name="Edde 综合群",
    id=708199076,
  },
}

--donateUrl="https://afdian.net/@Jesse205"
donateImage=R.drawable.donate_weichat
donateNewPage=false
--copyright="No Copyright"
