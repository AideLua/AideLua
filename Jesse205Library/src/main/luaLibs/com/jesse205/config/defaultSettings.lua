import "android.os.Build"

local SDK_INT = Build.VERSION.SDK_INT
local isAndroidPAndUp = SDK_INT >= 28
local isAndroidSAndUp = SDK_INT >= 31
local theme_style = "Material1"

if isAndroidPAndUp then
    theme_style = "Material2"
elseif isAndroidSAndUp then
    theme_style = "Material3"
end

return {
    -- theme_darkactionbar = false,
    theme_type = "BLUE",
    theme_style = theme_style,
}
