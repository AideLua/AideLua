# 管理器 | Manager

1. 管理器视图初始化都在 `initViews` 内，不得在管理器创建时初始化，因为初始化时间点不一致
2. 管理器应尽量做到高内聚、低耦合
3. 每一个 Manager 都可以有 Activity 生命周期的部分

## 编辑器管理器 | EditorsManager

编辑器管理器管理编辑器部分

## 文件图标管理器 | FileIconsManager

管理文件图标，包括文件夹图标

## 文件浏览器管理器 | FilesBrowserManager

管理文件管理器
