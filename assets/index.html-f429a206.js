import{_ as r,M as l,p as i,q as o,R as a,N as t,U as n,t as d,a1 as s}from"./framework-ea2a9e6e.js";const h={},c=s(`<h1 id="项目模板介绍" tabindex="-1"><a class="header-anchor" href="#项目模板介绍" aria-hidden="true">#</a> 项目模板介绍</h1><h2 id="文件说明" tabindex="-1"><a class="header-anchor" href="#文件说明" aria-hidden="true">#</a> 文件说明</h2><p>Aide Lua 的模板支持字模板。因此您编写的时候可以套娃。</p><details class="custom-container details"><summary>这是我们的模板结构</summary><div class="language-文件树" data-ext="文件树"><pre class="language-文件树"><code>templates   &lt;-- 模板根文件夹
│  config.lua   &lt;-- * 模板配置文件
│  keys.txt   &lt;-- 用于格式化的字符串说明
│  pageConfigs.aly   &lt;-- * 模板页面文件
│  keysFormatter.aly   &lt;-- * key的格式化器字典
│
├─AndroLua   &lt;-- AndroLua+ 子模板文件夹（名字可以随意起）
│  │  config.lua   &lt;-- * 子模版配置文件
│  │
│  └─baseTemplate   &lt;-- 子模版基础资源文件夹
│     │  androidx.zip   &lt;-- 子模板 AndroidX 项目资源文件（自动识别）
│     │  baseTemplate.zip   &lt;-- 子模版基础资源文件
│     │  normal.zip   &lt;-- 子模版非 AndroidX 资源文件（自动识别）
│     │
│     └─androluaTemplate   &lt;-- 页面 AndroLua+ 模块的模板
│         └─5.0.18(1.1)(armeabi-v7a,arm64-v8a)   &lt;-- 模块版本号对应的文件夹
│               androidx.zip   &lt;-- 模块的 AndroidX 资源文件（自动识别）
│               baseTemplate.zip   &lt;-- 模块基础资源文件
│               normal.zip   &lt;-- 模块的非 AndroidX 资源文件（自动识别）
│
├─baseTemplate   &lt;-- 模版基础资源文件夹
│  │  baseTemplate.zip   &lt;-- 模版基础资源文件
│  │  ...
│  │
│  └─appTemplate   &lt;-- 页面通用模块的模板
│      └─aide(2.1)   &lt;-- 模块版本号对应的文件夹
│              baseTemplate.zip   &lt;-- 模块基础资源文件
│              ...
│
└─LuaJ   &lt;-- LuaJ++ 子模板文件夹
       ...
</code></pre></div></details><h3 id="config-lua" tabindex="-1"><a class="header-anchor" href="#config-lua" aria-hidden="true">#</a> config.lua</h3><h3 id="pageconfigs-aly" tabindex="-1"><a class="header-anchor" href="#pageconfigs-aly" aria-hidden="true">#</a> pageConfigs.aly</h3><h3 id="basetemplate" tabindex="-1"><a class="header-anchor" href="#basetemplate" aria-hidden="true">#</a> baseTemplate/</h3><p>存放基本模板的地方</p><table><thead><tr><th>文件</th><th>说明</th></tr></thead><tbody><tr><td>baseTemplate.zip</td><td>基本模板文件</td></tr><tr><td>androidx.zip</td><td>基本AndroidX模板文件</td></tr><tr><td>normal.zip</td><td>基本非AndroidX模板文件</td></tr></tbody></table><h2 id="载入原理" tabindex="-1"><a class="header-anchor" href="#载入原理" aria-hidden="true">#</a> 载入原理</h2><h2 id="从插件中加载模板" tabindex="-1"><a class="header-anchor" href="#从插件中加载模板" aria-hidden="true">#</a> 从插件中加载模板</h2><h2 id="相关链接" tabindex="-1"><a class="header-anchor" href="#相关链接" aria-hidden="true">#</a> 相关链接</h2>`,12);function p(u,m){const e=l("RouterLink");return i(),o("div",null,[c,a("ul",null,[a("li",null,[t(e,{to:"/project/"},{default:n(()=>[d("工程介绍")]),_:1})]),a("li",null,[t(e,{to:"/functiom/newproject.html"},{default:n(()=>[d("新建项目")]),_:1})])])])}const b=r(h,[["render",p],["__file","index.html.vue"]]);export{b as default};
