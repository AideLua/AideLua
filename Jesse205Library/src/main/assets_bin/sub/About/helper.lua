
---获取QQ头像链接
---@param qq integer QQ号
---@param size integer 大小，默认为640
---@return string avatarUrl 头像链接
function getUserAvatarUrl(qq, size)
  size = size or 640
  if qq then
    return ("http://q.qlogo.cn/headimg_dl?spec=%s&img_type=jpg&dst_uin=%s"):format(size, qq)
  end
end

---QQ交流
---@param qqNumber integer qq号
function chatOnQQ(qqNumber)
  local uri = Uri.parse("mqqwpa://im/chat?chat_type=wpa&uin=" .. qqNumber)
  if not pcall(activity.startActivity, Intent(Intent.ACTION_VIEW, uri)) then
    MyToast(R.string.jesse205_noQQ)
  end
end

--加入QQ交流群
function joinQQGroup(groupNumber)
  local uri = Uri.parse(("mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%s&card_type=group&source=qrcode")
  :format(groupNumber))
  if not pcall(activity.startActivity, Intent(Intent.ACTION_VIEW, uri)) then
    MyToast(R.string.jesse205_noQQ)
  end
end

---执行事件
---@param parent ViewGroup
---@param view View
---@param data table
function callItem(parent, view, data)
  if data.url then
    openUrl(data.url)
   elseif data.browserUrl then
    openInBrowser(data.browserUrl)
   elseif data.qqGroup then --QQ群
    joinQQGroup(data.qqGroup)
   elseif data.qq then
    chatOnQQ(data.qq)
   elseif data.click then
    data.click()
   elseif data.contextMenuEnabled then
    if parent and view then
      parent.showContextMenuForChild(view)
    end
  end
end