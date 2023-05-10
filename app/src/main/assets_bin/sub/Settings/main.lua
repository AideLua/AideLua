RedirectHelper = require "RedirectHelper"
if RedirectHelper.toAndroidActivity("com.jesse205.app.activity.SettingsActivity") then
    return
end

require "import"
initApp = true
import "jesse205"
local normalkeys = jesse205.normalkeys
normalkeys.configType = true
normalkeys.config = true

import "android.preference.PreferenceManager"
import "com.google.android.material.dialog.MaterialAlertDialogBuilder"
import "com.jesse205.layout.util.SettingsLayUtil"
import "com.jesse205.layout.innocentlayout.RecyclerViewLayout"
import "com.jesse205.app.dialog.EditDialogBuilder"
import "com.jesse205.app.dialog.ThemeSelectDialogBuilder"
import "helper.ZipAlignToolHelper"

packageInfo = activity.getPackageManager().getPackageInfo(getPackageName(), 0)
PluginsUtil.setActivityName("settings")

import "settings"

activity.setTitle(R.string.settings)
activity.setContentView(loadlayout2(RecyclerViewLayout))

actionBar.setDisplayHomeAsUpEnabled(true)

--oldTheme=ThemeUtil.getAppTheme()

configType, config = ...

function onOptionsItemSelected(item)
    local id = item.getItemId()
    if id == android.R.id.home then
        activity.finish()
    end
end

function onResume()
   
end

function reloadActivity(closeViews)
    local aRanim = android.R.anim
    local pos, scroll
    if recyclerView then
        if closeViews then
            activity.getDecorView().addView(View(activity).setClickable(true))
        end
        pos = layoutManager.findFirstVisibleItemPosition()
        scroll = recyclerView.getChildAt(0).getTop()
    end
    newActivity("main", aRanim.fade_in, aRanim.fade_out, { "scroll", { pos, scroll } })
    activity.finish()
end

function onItemClick(view, views, key, data)
    local action = data.action
    if key == "theme_picker" then
        --newSubActivity("ThemePicker")
        ThemeSelectDialogBuilder(activity)
            :setCallback(function(changed, newTheme)
                return changed and reloadActivity({ view })
            end)
            :show()
    elseif key == "about" then
        newSubActivity("About")
    elseif key == ThemeManager.THEME_DARK_ACTION_BAR or key == ThemeManager.THEME_MATERIAL3 then
        reloadActivity({ view, views.switchView })
    elseif key == "plugins_manager" then
        newSubActivity("PluginsManager")
    else
        if action == "editString" then
            EditDialogBuilder.settingDialog(adapter, views, key, data)
        elseif action == "singleChoose" then
            MaterialAlertDialogBuilder(activity)
                .setTitle(data.title)
                .setSingleChoiceItems(data.items, getSharedData(key) or 0, function(dialog, which)
                    setSharedData(key, which)
                    dialog.dismiss()
                    adapter.notifyDataSetChanged()
                end)
                .show()
        end
    end
    PluginsUtil.callElevents("onItemClick", views, key, data)
end

--v5.2.0+
SettingsGroupMap = SettingsLayUtil.generateSettingsGroupMap(settings)

--添加插件设置项
local items = {}
PluginsUtil.callElevents("onLoadItemList", items)
for index2, content in ipairs(items) do
    table.insert(SettingsGroupMap.plugins, content)
end

settingsData = SettingsLayUtil.loadSettingItems(settings)
adapter = SettingsLayUtil.newAdapter(settingsData, onItemClick)
recyclerView.setAdapter(adapter)
layoutManager = LinearLayoutManager()
recyclerView.setLayoutManager(layoutManager)
recyclerView.addOnScrollListener(RecyclerView.OnScrollListener {
    onScrolled = function(view, dx, dy)
        AnimationHelper.onScrollListenerForActionBarElevation(actionBar, view.canScrollVertically(-1))
    end
})
recyclerView.getViewTreeObserver().addOnGlobalLayoutListener({
    onGlobalLayout = function()
        if activity.isFinishing() then
            return
        end
        AnimationHelper.onScrollListenerForActionBarElevation(actionBar, recyclerView.canScrollVertically(-1))
    end
})

mainLay.onTouch = function(view, ...)
    recyclerView.onTouchEvent(...)
end

if config then
    config = luajava.astable(config)
    if tostring(configType) == "scroll" then
        layoutManager.scrollToPositionWithOffset(config[1], config[2])
    end
end

mainLay.ViewTreeObserver
    .addOnGlobalLayoutListener(ScreenUtil.LayoutListenersBuilder.listViews(mainLay, { recyclerView }))
