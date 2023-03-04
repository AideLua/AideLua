import "helper.GiteeUpdateHelper"
appInfo={
  {
    name=R.string.app_name,
    message=R.string.app_summary,
    iconResource=R.mipmap.ic_launcher_round,
    browserUrl="https://aidelua.github.io/",
    clickable=true,
  },
  {
    name=R.string.aidepro,
    message=R.string.aidepro_summary,
    iconResource=R.mipmap.ic_launcher_aide_round,
    browserUrl="https://www.aidepro.top/",
    clickable=true,
  },
  {
    name=R.string.windmill,
    message=R.string.windmill_summary,
    iconResource=R.mipmap.ic_launcher_windmill_round,
    browserUrl="https://www.coolapk.com/apk/com.agyer.windmill",
    clickable=true,
  },
}
function onUpdate()
  GiteeUpdateHelper.checkUpdate("Jesse205","AideLua")
end

--开发者们
developers={
  {--Eddie
    name=res.string.developer_eddie,
    qq=2140125724,
    message=R.string.developer_eddie_description,
    url="https://b23.tv/Xp0Cc4P",
  },
  {--0047ol
    name=res.string.developer_0047ol,
    qq=2088343717,
    message=R.string.developer_0047ol_description,
  },
  {--xiaoyi
    name=res.string.developer_xiaoyi,
    qq=2821981550,
    message=R.string.developer_xiaoyi_description,
  },
}

--启用开源许可
openSourceLicenses=true

--[[格式：
{
  {
    name="群名称"; -- 群名称
    qqGroup=708199076; -- 群号
    contextMenuEnabled=true; -- 启用ContextMenu
  },
  {
    name="百度", -- 显示的名称
    url="http://www.baidu.com" -- 跳转连接
    browserUrl="http://www.baidu.com" -- 浏览器打开链接
    func=function(view) -- 执行的函数
    end,
  },
  --以此类推
}]]

moreItem={
  {--仓库
    SettingsLayUtil.ITEM_NOSUMMARY;
    title=R.string.open_source_repository;
    icon=R.drawable.ic_github;
    newPage="newApp";
    browserUrl=REPOSITORY_URL;
  },
  {--交流群
    SettingsLayUtil.ITEM;
    title=R.string.jesse205_qqGroup;
    summary="628045718",
    icon=R.drawable.ic_account_group_outline;
    newPage="newApp";
    qqGroup=628045718;
    contextMenuEnabled=true;
    menus={
      {
        title="Aide Lua Bug测试群",
        qqGroup=680850455,
      },
      {
        title="Aide Lua 尝鲜群",
        qqGroup=628045718,
      },
      {
        title="Edde 综合群",
        qqGroup=708199076,
      },
    };
  },
  {--频道
    SettingsLayUtil.ITEM;
    title=R.string.jesse205_qqChannel;
    summary="t37c1u1nmw",
    icon=R.drawable.ic_qq_channel;
    newPage="newApp";
    url="https://pd.qq.com/s/n51c4k";
  },
  {--使用文档
    SettingsLayUtil.ITEM_NOSUMMARY;
    title=R.string.app_documnet;
    icon=R.drawable.ic_file_document_outline;
    newPage="newApp";
    url=DOCS_URL;
  },
  {--支持
    SettingsLayUtil.ITEM_NOSUMMARY;
    title=R.string.jesse205_supportProject;
    icon=R.drawable.ic_wallet_giftcard;
    contextMenuEnabled=true;
    menus={
      {
        title="更多软件",
        url="https://jesse205.github.io/",
      },
      {
        title="问题反馈 (QQ频道)",
        url="https://pd.qq.com/s/97ho4f",
      },
      {
        title="问题反馈 (Gitee)",
        url=REPOSITORY_URL.."/issues",
      },
      {
        title="参与开发",
        url=REPOSITORY_URL,
      },
    };
  },
}

--感谢名单
thanks={
  难忘的旋律={"PhotoView"},
  噬心={"HtmlEditor (老版本)"},
  dingyi={"MyLuaApp","LuaEditor","Gradle 工程修复","放大镜","Preference 设置页面","布局编译","AndroLua 调试"},
  狸猫={"提供优化后的 AndroidX 模板"},
  frrrrrits={"AnimeonGo（为 Edde 系列应用优化提供了重要参考）"},
  smile={"编译 ZipAlign 并测试"},
  undraw={"插画"},
  
}

--版权信息
copyright="Copyright (c) 2020-2023, Jesse205"

PluginsUtil.setActivityName("about")

function main()
  import "db"
  local index=4
  table.insert(data,index,{--PluginsUtil 版本
    SettingsLayUtil.ITEM;
    title=getLocalLangObj("PluginsUtil 版本","PluginsUtil version");
    summary=PluginsUtil._VERSION;
    icon=R.drawable.ic_puzzle_outline;
  })
  index=index+1
  table.insert(data,index,{--LuaDB 版本
    SettingsLayUtil.ITEM;
    title=getLocalLangObj("LuaDB 版本","LuaDB version");
    summary=tostring(db.ver);
    icon=R.drawable.ic_database_outline;
  })
  index=index+2
  table.insert(data,index,{--更新日志
    SettingsLayUtil.ITEM_NOSUMMARY;
    title=getLocalLangObj("更新日志","Change Log");
    url=REPOSITORY_URL.."/blob/master/CHANGELOG.md",
    icon=R.drawable.ic_history;
    newPage="newApp";
  })
end