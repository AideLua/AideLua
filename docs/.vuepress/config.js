import { defineUserConfig, defaultTheme } from 'vuepress'
// import { pwaPlugin } from '@vuepress/plugin-pwa'
// import { pwaPopupPlugin } from '@vuepress/plugin-pwa-popup'
import { searchPlugin } from '@vuepress/plugin-search'
// https://plugin-pwa2.vuejs.press/zh/
// import { pwaPlugin } from "vuepress-plugin-pwa2"
// https://plugin-copy-code2.vuejs.press/zh/
// import { copyCodePlugin } from "vuepress-plugin-copy-code2";
// https://plugin-comment2.vuejs.press/zh/
// import { commentPlugin } from "vuepress-plugin-comment2";


export default defineUserConfig({
    base: "/AideLua/",
    lang: 'zh-CN',
    title: 'Aide Lua Pro 文档',
    description: '让您在移动设备上也能享受高级的、快速的软件开发',
    head: [
        ['link', { rel: 'icon', sizes: "any", mask: "", href: "/AideLua/favicon.ico" }],
        ['link', { rel: 'icon', type: "image/png", sizes: "32x32", href: "/AideLua/favicon-32x32.png" }],
        ['link', { rel: 'icon', type: "image/png", sizes: "16x16", href: "/AideLua/favicon-16x16.png" }],
        ['link', { rel: 'apple-touch-icon', sizes: "180x180", href: "/AideLua/images/icons/apple-touch-icon.png" }],
        ['link', { rel: 'mask-icon', sizes: "180x180", href: "/AideLua/images/icons/safari-pinned-tab.svg", color: "#3F51B5" }],
        ['link', { rel: 'manifest', href: '/AideLua/manifest.webmanifest' }],
    ],
    shouldPrefetch: false,
    theme: defaultTheme({
        docsDir: "docs",
        docsRepo: "https://gitee.com/AideLua/AideLua",
        docsBranch: "master",
        editLinkText: "编辑此页",
        editLinkPattern: ":repo/edit/:branch/:path",
        contributorsText: "贡献者",
        lastUpdatedText: "最近更新",
        tip: "提示",
        warning: "警告",
        danger: "危险",
        backToHome: "返回文档首页",
        notFound: ["404 找不到页面"],
        openInNewWindow: "在新窗口打开",
        toggleColorMode: "暗色模式",
        toggleSidebar: "侧边栏",
        navbar: [
            {
                text: '首页',
                link: '/home.html',
            },
            {
                text: '使用文档',
                link: '',
            },
            {
                text: 'Gitee 仓库',
                link: 'https://gitee.com/AideLua/AideLua',
            },
            {
                text: 'Github 仓库',
                link: 'https://github.com/AideLua/AideLua',
            },
        ],
        sidebar: [
            {
                text: '使用文档',
                link: '/',
            },
            {
                text: '快速使用',
                collapsible: true,
                children: [
                    {
                        text: '概览',
                        link: '/quickly/',
                    },
                    {
                        text: '一、首次使用软件',
                        link: '/quickly/1.html',
                    },
                    {
                        text: '二、编写代码、打包发布',
                        link: '/quickly/2.html',
                    },
                    {
                        text: '三、资源文件',
                        link: '/quickly/3.html',
                    },
                    {
                        text: '四、build.gradle 和 config.lua',
                        link: '/quickly/4.html',
                    },
                ]
            },
            {
                text: '常见问题',
                link: '/faq.html',
            },
            {
                text: '用户交互',
                collapsible: true,
                children: [
                    {
                        text: '概览',
                        link: '/userinteraction/',
                    },
                ]
            },
            {
                text: 'Lua 模块',
                collapsible: true,
                children: [
                    {
                        text: 'LuaDB',
                        link: '/library/db.html',
                    },
                    {
                        text: '资源获取工具',
                        link: '/library/res.html',
                    },
                ]
            },
            {
                text: '功能介绍',
                collapsible: true,
                children: [
                    {
                        text: '新建工程',
                        link: '/function/newproject.html',
                    },
                    {
                        text: '安全调试',
                        link: '/function/safedebug.html',
                    },
                    {
                        text: '构建项目',
                        link: '/function/build.html',
                    },
                ]
            },
            {
                text: '工程介绍',
                collapsible: true,
                children: [
                    {
                        text: '概述',
                        link: '/project/',
                    },
                    {
                        text: '使用 Git',
                        link: '/project/usegit.html',
                    },
                    {
                        text: '.aidelua',
                        collapsible: true,
                        children: [
                            {
                                text: 'config.lua',
                                link: '/project/aidelua/config.lua.html',
                            },
                            {
                                text: 'bin.lua',
                                link: '/project/aidelua/bin.lua.html',
                            },
                        ]
                    },
                    {
                        text: '项目模板配置',
                        collapsible: true,
                        children: [
                            {
                                text: '概览',
                                link: '/project/template/',
                            },
                        ],
                    },
                ]
            },
            {
                text: 'Androlua+ 文档',
                collapsible: true,
                children: [
                    {
                        text: '关于',
                        link: '/androluapro/',
                    },
                    {
                        text: '软件基本操作',
                        link: '/androluapro/base.html',
                    },
                    {
                        text: '快速入门',
                        link: '/androluapro/fast.html',
                    },
                    {
                        text: '与标准 Lua5.3 的不同',
                        link: '/androluapro/differentwithlua5.3.html',
                    },
                    {
                        text: '与标准 java 的不同',
                        link: '/androluapro/differentwithjava.html',
                    },
                    {
                        text: '01. 参考链接',
                        link: '/androluapro/01.html',
                    },
                    {
                        text: '02. 导入模块',
                        link: '/androluapro/02.html',
                    },
                    {
                        text: '03. 导入包或类',
                        link: '/androluapro/03.html',
                    },
                    {
                        text: '04. 创建布局与组件',
                        link: '/androluapro/04.html',
                    },
                    {
                        text: '05. 使用方法',
                        link: '/androluapro/05.html',
                    },
                    {
                        text: '06. 使用事件',
                        link: '/androluapro/06.html',
                    },
                    {
                        text: '07. 回调方法',
                        link: '/androluapro/07.html',
                    },
                    {
                        text: '08. 按键与触控',
                        link: '/androluapro/08.html',
                    },
                    {
                        text: '09. 使用数组与 map',
                        link: '/androluapro/09.html',
                    },
                    {
                        text: '10. 使用线程',
                        link: '/androluapro/10.html',
                    },
                    {
                        text: '11. 使用布局表',
                        link: '/androluapro/11.html',
                    },
                    {
                        text: '12. 2D 绘图',
                        link: '/androluapro/12.html',
                    },
                    {
                        text: '13. Lua 类型与 Java 类型',
                        link: '/androluapro/13.html',
                    },
                    {
                        text: '14.1 canvas 模块',
                        link: '/androluapro/14.1.html',
                    },
                    {
                        text: '14.2 OpenGL 模块',
                        link: '/androluapro/14.2.html',
                    },
                    {
                        text: '14.3 http 同步网络模块',
                        link: '/androluapro/14.3.html',
                    },
                    {
                        text: '14.4 import 模块',
                        link: '/androluapro/14.4.html',
                    },
                    {
                        text: '14.5 Http 异步网络模块',
                        link: '/androluapro/14.5.html',
                    },
                    {
                        text: '14.6 bmob 网络数据库',
                        link: '/androluapro/14.6.html',
                    },
                    {
                        text: '15.1 LuaUtil 辅助库',
                        link: '/androluapro/15.1.html',
                    },
                    {
                        text: '15.2 LuaAdapter 适配器',
                        link: '/androluapro/15.2.html',
                    },
                    {
                        text: '15.3 LuaDialog 对话框',
                        link: '/androluapro/15.3.html',
                    },
                    {
                        text: '15.4 LuaDrawable 绘制',
                        link: '/androluapro/15.4.html',
                    },
                    {
                        text: '关于打包',
                        link: '/androluapro/bin.html',
                    },
                    {
                        text: '部分函数参考',
                        link: '/androluapro/api.html',
                    },
                    {
                        text: 'activity 部分 API 参考',
                        link: '/androluapro/activityapi.html',
                    },
                    {
                        text: '布局表字符串常量',
                        link: '/androluapro/layout.html',
                    },
                ]
            },
            {
                text: '插件文档',
                collapsible: true,
                children: [
                    {
                        text: '概览',
                        link: '/plugin/',
                    },
                    {
                        text: '页面配置',
                        collapsible: true,
                        children: [
                            {
                                text: 'main.aly',
                                link: '/plugin/pages/main.html',
                            },
                            {
                                text: 'newproject.aly',
                                link: '/plugin/pages/newproject.html',
                            },
                            {
                                text: 'settings.aly',
                                link: '/plugin/pages/settings.html',
                            },
                            {
                                text: 'viewclass.aly',
                                link: '/plugin/pages/viewclass.html',
                            },
                        ],
                    },
                    {
                        text: 'API变更说明',
                        link: '/plugin/apichanges.html',
                    },
                ]
            },
        ],
        themePlugins: {
            backToTop: false,
        }
    }),
    plugins: [
        searchPlugin({
            // 配置项
        }),
        /*pwaPlugin({
            cachePic: true,
            update: 'update',
            themeColor: '#3F51B5',
            favicon: '/AideLua/favicon.ico',
            apple: false,
            msTile: false,
        }),*/
        /*pwaPlugin({}),
        pwaPopupPlugin({
            locales: {
                '/zh/': {
                  message: '发现新内容可用',
                  buttonText: '刷新',
                },
            },
        }),*/
        /* copyCodePlugin({
            showInMobile: true,
            pure: true,
            delay: 100,
        }), */
        /* commentPlugin({
            provider: "Giscus",
            repo: "AideLua/AideLua",
            repoId: "R_kgDOHfPX_g",
            category: "DocumentGiscus",
            categoryId: "DIC_kwDOHfPX_s4CUCDx",
        }), */
    ],
})