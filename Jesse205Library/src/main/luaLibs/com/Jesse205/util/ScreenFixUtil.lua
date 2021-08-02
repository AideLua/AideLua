local ScreenFixUtil={}

local ScreenConfigDecoder={
  device="phone",
}
ScreenFixUtil.ScreenConfigDecoder=ScreenConfigDecoder
setmetatable(ScreenConfigDecoder,ScreenConfigDecoder)

--[[
{
  device={
    phone=function()
    pad=function()
    pc=function()
    }
  orientation={
    identical={LinearLayout...}
    different={LinearLayout...}
    }
  fillParent={View...}
  layoutManagers={LayoutManager...}
  singleViews={View...}
  }
]]
function ScreenConfigDecoder.__call(self,events)
  self=table.clone(self)
  self.events=events
  return self
end

local function setLayoutManagersSpanCount(layoutManagers,count)
  if layoutManagers then
    for index,content in ipairs(layoutManagers) do
      content.setSpanCount(count)
    end
  end
end
ScreenFixUtil.setLayoutManagersSpanCount=setLayoutManagersSpanCount

local function setLayoutsOrientation(lays,orientation)
  if lays then
    for index,content in ipairs(lays) do
      content.setOrientation(orientation)
    end
  end
end
ScreenFixUtil.setLayoutsOrientation=setLayoutsOrientation

local function setLayoutsSize(lays,height,width)
  if lays then
    for index,content in ipairs(lays) do
      local linearParams=content.getLayoutParams()
      if height then
        linearParams.height=height
      end
      if width then
        linearParams.width=width
      end
      content.setLayoutParams(linearParams)
    end
  end
end
ScreenFixUtil.setLayoutsSize=setLayoutsSize


local function setGridViewsNumColumns(gridViews,columns)
  if gridViews then
    for index,content in ipairs(gridViews) do
      content.setNumColumns(columns)
    end
  end
end
ScreenFixUtil.setGridViewsNumColumns=setGridViewsNumColumns


function ScreenConfigDecoder.decodeConfiguration(self,config)
  local smallestScreenWidthDp=config.smallestScreenWidthDp--最小宽度（dp）
  local smallestScreenWidth=math.dp2int(smallestScreenWidthDp)--最小宽度
  local screenWidthDp=config.screenWidthDp--屏幕宽度（单位为dp）
  local screenWidth=math.dp2int(screenWidthDp)--转换为像素

  local events=self.events
  local orientationLays=events.orientation
  local layoutManagers=events.layoutManagers--用于设置横向数目
  local singleCardViews=events.singleCardViews--用于设置卡片最大宽度
  local listViews=events.listViews--列表的
  local gridViews=events.gridViews--和layoutManagers作用差不多
  local fillParentViews=events.fillParentViews--充填的

  local onDeviceChanged=events.onDeviceChanged--当设备切换时调用
  local identicalLays,differentLays--同向，异向（屏幕方向）
  local orientation=config.orientation


  if orientationLays then
    identicalLays=orientationLays.identical
    differentLays=orientationLays.different
  end

  local oldDevice=self.device
  local device
  if smallestScreenWidth~=self.smallestScreenWidth then--最小宽度改变时
    if smallestScreenWidth<theme.number.padWidth then--判断设备类型
      device="phone"
     elseif smallestScreenWidth<theme.number.pcWidth then
      device="pad"
     else
      device="pc"
    end
    self.smallestScreenWidth=smallestScreenWidth
   else--没改变最小宽度，说明设备类型没改变
    device=oldDevice
  end

  if orientation~=self.orientation or device~=self.device then--切换屏幕方向
    if orientation==Configuration.ORIENTATION_LANDSCAPE then--横屏时
      setLayoutsOrientation(identicalLays,LinearLayout.HORIZONTAL)
      setLayoutsOrientation(differentLays,LinearLayout.VERTICAL)
      setLayoutsSize(fillParentViews,-1,-2)
      if device=="phone" then
        setLayoutManagersSpanCount(layoutManagers,2)
        setGridViewsNumColumns(gridViews,2)
       elseif device=="pad" then
        setLayoutManagersSpanCount(layoutManagers,4)
        setGridViewsNumColumns(gridViews,4)
       elseif device=="pc" then
        setLayoutManagersSpanCount(layoutManagers,6)
        setGridViewsNumColumns(gridViews,6)
      end
     else
      setLayoutsOrientation(identicalLays,LinearLayout.VERTICAL)
      setLayoutsOrientation(differentLays,LinearLayout.HORIZONTAL)
      setLayoutsSize(fillParentViews,-2,-1)
      if device=="phone" then
        setLayoutManagersSpanCount(layoutManagers,1)
        setGridViewsNumColumns(gridViews,1)
       elseif device=="pad" then
        setLayoutManagersSpanCount(layoutManagers,2)
        setGridViewsNumColumns(gridViews,2)
       elseif device=="pc" then
        setLayoutManagersSpanCount(layoutManagers,4)
        setGridViewsNumColumns(gridViews,4)
      end
    end
    self.orientation=config.orientation
  end

  if singleCardViews then
    if screenWidthDp>640+32 then
      setLayoutsSize(singleCardViews,nil,math.dp2int(640))
     else
      setLayoutsSize(singleCardViews,nil,-1)
    end
  end

  if listViews then
    if device=="phone" then
      if screenWidthDp>704 then
        setLayoutsSize(listViews,nil,math.dp2int(704))
       else
        setLayoutsSize(listViews,nil,-1)
      end
     else
      if screenWidthDp>800 then
        setLayoutsSize(listViews,nil,math.dp2int(800))
       else
        setLayoutsSize(listViews,nil,-1)
      end
    end
  end

  self:decodeMenus(screenWidthDp)

  if device~=oldDevice then--设备类型切换时
    self.device=device
    if onDeviceChanged then
      onDeviceChanged(device,oldDevice)
    end
  end


end

function ScreenConfigDecoder.decodeMenus(self,screenWidthDp)
  local events=self.events
  local menus=events.menus
  if menus then
    if not(MenuItemCompat) then
      import "androidx.core.view.MenuItemCompat"
    end
    for showWidthDp,content in pairs(menus) do
      for index,content in ipairs(content) do
        if showWidthDp<=screenWidthDp then
          MenuItemCompat.setShowAsAction(content, MenuItemCompat.SHOW_AS_ACTION_ALWAYS)
         else
          MenuItemCompat.setShowAsAction(content, MenuItemCompat.SHOW_AS_ACTION_NEVER)
        end
      end
    end
  end
end

return ScreenFixUtil
