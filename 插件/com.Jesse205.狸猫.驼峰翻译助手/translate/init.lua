module('translate',package.seeall)

local cjson=require 'cjson'
local theme=this.getTheme()
import "android.graphics.Typeface"
local Uri=luajava.bindClass "android.net.Uri"
local Color = luajava.bindClass 'android.graphics.Color'
local ColorStateList=luajava.bindClass "android.content.res.ColorStateList"
local PopupWindowCompat=luajava.bindClass "androidx.core.widget.PopupWindowCompat"
local typedValue = luajava.newInstance 'android.util.TypedValue'
theme.resolveAttribute(android.R.attr.colorAccent, typedValue, true)
local tcolor = typedValue.data
local ripples = activity.obtainStyledAttributes({android.R.attr.selectableItemBackground}).getResourceId(0, 0)
local typedValue = luajava.newInstance 'android.util.TypedValue'
theme.resolveAttribute(android.R.attr.windowBackground, typedValue, true)
local bcolor = typedValue.data
local hsv = float[3]
Color.colorToHSV(bcolor, hsv)
local dark = hsv[2] < 0.5
local color=dark and 0x20ffffff or 0x20000000
local bgcolor=dark and 0xffffffff or 0xff000000

local scale = activity.getResources().getDisplayMetrics().scaledDensity
local function dp(dpValue)
  return dpValue * scale + 0.5
end

local ids={}
local msg=loadlayout('translate.msg',ids)
local list=loadlayout('translate.list',ids)
local data={}
local adp=LuaAdapter(this,data,require 'translate.item')

ids.tv.setTextColor(tcolor)
.getPaint().setFakeBoldText(true)
ids.img.setColorFilter(tcolor)
ids.bg.background=activity.Resources.getDrawable(ripples)
.setColor(ColorStateList({{}},{color}))
ids.list.setAdapter(adp)
ids.list.setEmptyView(ids.empty)



ids.list.onItemClick=function(s,v,p,i)
  if onResult
    onResult(data[i].word.text)
  end
end

local pop1=PopupWindow(this)
.setContentView(msg)

.setWidth(dp(170))
.setHeight(dp(100))
pop1.setBackgroundDrawable(nil)

local pop2=PopupWindow(this)
.setContentView(list)
.setWidth(-1)
.setHeight(dp(218))
pop2.setBackgroundDrawable(nil)

function call(view,state,s,e)
  if state and e-s>0 then
    --pop1.showAsDropDown(view)
    --PopupWindowCompat.showAsDropDown(pop1,view,0,0,Gravity.BOTTOM|Gravity.CENTER)
    pop1.showAsDropDown(view,view.width/2-dp(85),0)
    --pop1.showAtLocation(view,Gravity.BOTTOM|Gravity.CENTER,0,0)
   else
    pop1.dismiss()
    pop2.dismiss()
  end
end

local function t2c(str)
local t={}
str:gsub('[^_]+',function(w)
  t[#t+1]=w
end)

local s={}
for k,v ipairs(t)
when v=='the' continue
when v=='a' continue
when k>1
  v=v:sub(1,1):upper()..v:sub(2)
  s[#s+1]=v
end
s=table.concat(s)

adp.add{
  word={
    text=s,
    textColor=tcolor
  },
  type=' camelCase 驼峰(小)'
}

local s={}
for k,v ipairs(t)
when v=='the' continue
  when v=='a' continue
    v=v:sub(1,1):upper()..v:sub(2)
    s[#s+1]=v
  end
  s=table.concat(s)

  adp.add{
    word={
      text=s,
      textColor=tcolor
    },
    type=' pascalCase 驼峰(大)'
  }

  adp.add{
    word={
      text=str,
      textColor=tcolor
    },
    type=' snakeCase 下划线'
  }

  adp.add{
    word={
      text=str:upper(),
      textColor=tcolor
    },
    type=' constantCase 常量'
  }

end

ids.bg.onClick=function()
  ids.empty.visibility=0
  adp.clear()
  ids.pgs.text="正在翻译该文本..."
  pop1.dismiss()
  pop2.showAsDropDown(view)
  Http.post('https://fanyi.phpstudyhelper.com/TranslateWord',
  {word=Uri.encode(view.getSelectedText()),
    named_type='3',
    translation_mode='1'},
  function(a,b)
    if a==200 then
      local t=cjson.decode(b)
      if t.code==200 then
        ids.empty.visibility=8
        t2c(t.data.word)
       else
        ids.pgs.text="服务器访问出错！"
      end
     else
      ids.pgs.text="服务器访问出错！"
    end
  end)
end



return _M