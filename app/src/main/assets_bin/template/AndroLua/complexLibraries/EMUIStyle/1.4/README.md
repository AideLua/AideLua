# EMUI风格

为软件添加 EMUI 主题样式，但仅在 EMUI 上有效果。

## 使用方法

1. 导入 `EMUIStyle`

    ``` lua
    import "EMUIStyle"
    ```

2. `main.lua` 中设置主题

    ``` lua
    if androidhwext then
      pcall(function()
        activity.setTheme(androidhwext.R.style.Theme_Emui)
      end)
    end
    ```

    > 注意：必须pcall一下，因为拥有 hwext 的系统不只有 EMUI（比如 MagicUI 也拥有这个）。
