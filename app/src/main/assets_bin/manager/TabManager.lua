local TabManager = {}

---@class TabConfig 标签配置
---@type table<number,any>
---@field name string 名称
---@field isClosing boolean 正在关闭或者已关闭
---@field tag TabTag 页签唯一标识
---@field fileConfig FileConfig 文件配置信息

---@alias TabTag string

---所有页签 <唯一标识,标签配置>
---@type table<TabTag,TabConfig>
local tabsMap = {}

---打开页签
function TabManager.openTab()
    --TODO: 实现打开页签
end

---关闭页签
---@param tabConfig TabConfig 页签配置
function TabManager.closeTab(tabConfig)
    --TODO: 完善关闭页签
    TabManager.closeTabByTag(tabConfig.tag)
end

---通过 TabTag 关闭页签
---@param tag TabTag 页签唯一标识
function TabManager.closeTabByTag(tag)
    --TODO: 完善关闭页签
    tabsMap[tag] = null
end

---关闭所有标签
function TabManager.closeAllTabs()
    --TODO: 完善关闭所有页签
    for key, value in pairs(tabsMap) do
        TabManager.closeTab(value)
    end
end

---切换页签
---@param tabConfig TabConfig 页签配置
function TabManager.switchTab(tabConfig)
    --TODO: 切换页签
end

return TabManager
