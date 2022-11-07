import "GiteeUpdateUtil"
appInfo={
  {
    name=R.string.app_name,
    message="为更快进行移动开发",
    iconResource=R.mipmap.ic_launcher,
    url="https://jesse205.com/aidelua",
    clickable=true;
  },
 {
    name="AIDE Pro",
    message="一个经魔改过的全新版本",
    iconResource=R.drawable.ic_androidstudio,
    url="https://aidepro.top/",
    clickable=true;
  },
  {
    name=R.string.windmill,
    message="重认手机上的工具",
    iconResource=R.drawable.ic_windmill,
    url="https://www.coolapk.com/apk/com.agyer.windmill",
    clickable=true;
  },
}
function onUpdate()
  GiteeUpdateUtil.checkUpdate("Jesse205","AideLua")
end

--开发者们
developers={
  {
    name="Eddie",
    qq=2140125724,
    message="AideLua 开发者",
    url="https://b23.tv/Xp0Cc4P",
  },
  {
    name="xiaoyi",
    qq=2821981550,
    message="快乐程序 运营者",
  },
  {
    name="凌肆柒",
    qq=2088343717,
    message="AideLua 官网开发者",
  },
}

--启用开源许可
openSourceLicenses=true

moreItem={
  {--交流群
    SettingsLayUtil.ITEM_NOSUMMARY;
    title=R.string.jesse205_qqGroup;
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
    SettingsLayUtil.ITEM_NOSUMMARY;
    title=R.string.jesse205_qqChannel;
    icon=R.drawable.ic_qq_channel;
    newPage="newApp";
    url="https://pd.qq.com/s/n51c4k";
  },
  {--使用文档
    SettingsLayUtil.ITEM_NOSUMMARY;
    title=R.string.app_documnet;
    icon=R.drawable.ic_file_document_outline;
    newPage="newApp";
    url="https://jesse205.github.io/AideLua";
  },
  {--支持
    SettingsLayUtil.ITEM_NOSUMMARY;
    title=R.string.jesse205_supportProject;
    icon=R.drawable.ic_wallet_giftcard;
    contextMenuEnabled=true;
    menus={
      {
        title="问题反馈 (QQ频道)",
        url="https://pd.qq.com/s/97ho4f",
      },
      {
        title="问题反馈 (Gitee)",
        url="https://gitee.com/Jesse205/AideLua/issues",
      },
      {
        title="参与开发",
        url="https://gitee.com/Jesse205/AideLua",
      },
    };
  },
}

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
}
]]

--版权信息
copyright="Copyright (c) 2020-2022, Jesse205"

PluginsUtil.setActivityName("about")

function main()
  table.insert(data,4,{--PluginsUtil 版本
    SettingsLayUtil.ITEM;
    title=getLocalLangObj("PluginsUtil 版本","PluginsUtil version");
    summary=PluginsUtil._VERSION;
    icon=R.drawable.ic_puzzle_outline;
  })
end