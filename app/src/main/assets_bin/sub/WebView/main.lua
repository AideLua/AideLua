require "import"
import "jesse205"
import "android.webkit.WebChromeClient"

activity.setTitle(R.string.app_name)
activity.setContentView(loadlayout2("layout"))
actionBar.setDisplayHomeAsUpEnabled(true)

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    if webView.canGoBack() then
      webView.goBack()
     else
      activity.finish()
    end
  end
end

local url,name=...

webView.loadUrl(url)
if name then
  activity.setTitle(name)
end

webView.setWebChromeClient(luajava.override(WebChromeClient,{
  onReceivedTitle=function(super,view,title)
    if name then
      actionBar.setSubtitle(title)
     else
      actionBar.setTitle(title)
    end
  end
}))
