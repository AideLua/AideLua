--v5.1.1+
import "android.graphics.Color"
import "util.UnicodeUtil"

---Maekdown助手
local MarkdownHelper = {}

---供css使用，将颜色转换为css的rgb颜色
---@param color number
---@return string cssCode css代码
function MarkdownHelper.color2CssRGB(color, alpha)
    return "rgba(" .. Color.red(color) .. "," .. Color.green(color) .. "," .. Color.blue(color) ..
    ", " .. (alpha or 1) .. ")"
end

---将 vuepress 的 markdown 语法转换为普通 markdown 语法
---@param content string 内容
---@return string newContent 新内容
local function vuepressMd2NormalMd(content)
    --去除语言标识，因为不支持
    content = content:gsub("```[^\n]+", "```")
    local colons = "::"
    repeat
        colons = colons .. ":"
    until (not content:find(colons .. ".-" .. colons))
    for num = #colons, 3, -1 do
        local nowColons = string.rep(":", num)
        content = content:gsub(nowColons .. ".-" .. nowColons, function(content)
            local blockType, title = content:match(nowColons .. " -([^ \n]+) *([^ \n]*)")
            local blockContent = content:match(nowColons .. ".-\n(.-)\n[> ]-" .. nowColons)
            if not title or title == "" then
                if blockType == "tip" then
                    title = "TIP"
                elseif blockType == "warning" then
                    title = "WARNING"
                elseif blockType == "danger" then
                    title = "DANGER"
                elseif blockType == "code-group" then
                    title = "CODE GROUP"
                elseif blockType == "code-group-item" then
                    title = "ITEM"
                end
            end
            local newContent = ""
            if title then
                newContent = newContent .. "> " .. title .. "<br>\n"
            end
            if blockContent then
                newContent = newContent .. "> " .. blockContent:gsub("\n", "\n> ") .. "\n"
            end
            return newContent
        end)
    end
    return content
end

---加载Shdowdown，在加载内容前调用
---@param webView WebView
function MarkdownHelper.loadShowdown(webView)
    local showdownFile = io.open(AppPath.AppDataDir .. "/showdown/showdown.min.js", "r")
    local showdownJs = showdownFile:read("*a")
    showdownFile:close()
    local styleFile = io.open(AppPath.AppDataDir .. "/showdown/index.css", "r")
    local styleCss = styleFile:read("*a")
    styleFile:close()
    styleCss = styleCss:gsub("{{(.-)}}", function(key)
        return assert(loadstring("return " .. key))()
    end)
    webView.evaluateJavascript(showdownJs, nil)
    ---@language js
    webView.evaluateJavascript([[
var head = document.head || document.getElementsByTagName('head')[0];
var style = document.createElement('style');
style.innerHTML=']] .. UnicodeUtil.utf8ToUnicode(styleCss) .. [['
head.appendChild(style);
]], nil)
    --适配手机尺寸和utf8
    webView.evaluateJavascript([[
var head = document.head || document.getElementsByTagName('head')[0];
var viewportMeta = document.createElement('meta');
viewportMeta.setAttribute('name', 'viewport')
viewportMeta.setAttribute('content', 'width=device-width, initial-scale=1.0')
head.appendChild(viewportMeta);
var charsetMeta = document.createElement('meta');
charsetMeta.setAttribute('charset', 'utf-8')
head.appendChild(charsetMeta);
]], nil)
end

function MarkdownHelper.loadContent(webView, content)
    webView.evaluateJavascript([[
var converter = new showdown.Converter();
converter.setOption("tables",true);
converter.setOption("emoji",true);
converter.setOption("noHeaderId",true);
converter.setOption("strikethrough",true);
converter.setOption("tasklists",true);
converter.setOption("requireSpaceBeforeHeadingText",true);
converter.setOption("encodeEmails",true);
console.log("refreshed");
document.body.innerHTML = converter.makeHtml(']] .. UnicodeUtil.utf8ToUnicode(vuepressMd2NormalMd(content)) .. [[');
]], nil)
end

function MarkdownHelper.loadFile(webView, path)
    local nowUrl = webView.getUrl()
    if not nowUrl or Uri.parse(nowUrl).getPath() ~= path then
        webView.loadUrl("file://" .. path)
        return
    end
    local file = io.open(path, "r")
    local content = file:read("*a")
    file:close()
    MarkdownHelper.loadContent(webView, content)
end

MarkdownHelper.webViewClient = {
    onPageStarted = function(view, url, favicon)
        if url:find("%.md") or url:find("%.markdown") then
            view.stopLoading()
            --加载Showdown
            MarkdownHelper.loadShowdown(view)
            MarkdownHelper.loadFile(view, Uri.parse(url).getPath())
        end
    end
}

return MarkdownHelper
