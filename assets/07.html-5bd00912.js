import{_ as t,M as e,p as o,q as c,R as n,t as p,N as i,a1 as s}from"./framework-ea2a9e6e.js";const l={},u=s('<h1 id="回调方法" tabindex="-1"><a class="header-anchor" href="#回调方法" aria-hidden="true">#</a> 回调方法</h1><p>在活动文件添加以下函数，这些函数可以在活动的特定状态执行。</p><h2 id="activity-生命周期概念" tabindex="-1"><a class="header-anchor" href="#activity-生命周期概念" aria-hidden="true">#</a> Activity 生命周期概念</h2><p>为了在 Activity 生命周期的各个阶段之间导航转换，Activity 类提供六个核心回调：<code>onCreate()</code> 、<code>onStart()</code> 、<code>onResume()</code> 、<code>onPause()</code> 、<code>onStop()</code> 和 <code>onDestroy()</code>。当 Activity 进入新状态时，系统会调用其中每个回调。<br><img src="https://developer.android.google.cn/guide/components/images/activity_lifecycle.png?hl=zh-cn" alt="Activity 生命周期的简化图示"></p>',4),d={href:"https://developer.android.google.cn/guide/components/activities/activity-lifecycle?hl=zh_cn",target:"_blank",rel:"noopener noreferrer"},k=s(`<h2 id="androlua-中的回调" tabindex="-1"><a class="header-anchor" href="#androlua-中的回调" aria-hidden="true">#</a> Androlua 中的回调</h2><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token keyword">function</span> <span class="token function">main</span><span class="token punctuation">(</span><span class="token punctuation">...</span><span class="token punctuation">)</span>
    <span class="token comment">--...：newActivity() 传递过来的参数。</span>
    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&quot;入口函数&quot;</span><span class="token punctuation">,</span> <span class="token punctuation">...</span><span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onCreate</span><span class="token punctuation">(</span><span class="token punctuation">)</span>
    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&quot;活动创建&quot;</span><span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onStart</span><span class="token punctuation">(</span><span class="token punctuation">)</span>
    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&quot;活动开始&quot;</span><span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onResume</span><span class="token punctuation">(</span><span class="token punctuation">)</span>
    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&quot;返回活动&quot;</span><span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onPause</span><span class="token punctuation">(</span><span class="token punctuation">)</span>
    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&quot;活动暂停&quot;</span><span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onStop</span><span class="token punctuation">(</span><span class="token punctuation">)</span>
    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&quot;活动停止&quot;</span><span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onDestroy</span><span class="token punctuation">(</span><span class="token punctuation">)</span>
    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&quot;活动销毁&quot;</span><span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onResult</span><span class="token punctuation">(</span>name<span class="token punctuation">,</span> <span class="token punctuation">...</span><span class="token punctuation">)</span>
    <span class="token comment">--name：返回的活动名称</span>
    <span class="token comment">--...：返回的参数</span>
    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&quot;返回参数&quot;</span><span class="token punctuation">,</span> name<span class="token punctuation">,</span> <span class="token punctuation">...</span><span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onCreateOptionsMenu</span><span class="token punctuation">(</span>menu<span class="token punctuation">)</span>
    <span class="token comment">--menu：选项菜单</span>
    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&quot;添加菜单&quot;</span><span class="token punctuation">,</span> menu<span class="token punctuation">)</span>
    menu<span class="token punctuation">.</span><span class="token function">add</span><span class="token punctuation">(</span><span class="token string">&quot;菜单&quot;</span><span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onOptionsItemSelected</span><span class="token punctuation">(</span>item<span class="token punctuation">)</span>
    <span class="token comment">--item：选中的菜单项</span>
    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&quot;选择菜单&quot;</span><span class="token punctuation">,</span> item<span class="token punctuation">.</span>title<span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onConfigurationChanged</span><span class="token punctuation">(</span>config<span class="token punctuation">)</span>
    <span class="token comment">--config：配置信息</span>
    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&quot;配置信息更改&quot;</span><span class="token punctuation">,</span> config<span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onAccessibilityEvent</span><span class="token punctuation">(</span>event<span class="token punctuation">)</span>
    <span class="token comment">--event：辅助功能事件</span>
    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&quot;辅助功能&quot;</span><span class="token punctuation">,</span> event<span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onKeyDown</span><span class="token punctuation">(</span>keycode<span class="token punctuation">,</span> event<span class="token punctuation">)</span>
    <span class="token comment">--keycode：键值</span>
    <span class="token comment">--event：事件</span>
    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&quot;按键按下&quot;</span><span class="token punctuation">,</span> keycode<span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onKeyUp</span><span class="token punctuation">(</span>keycode<span class="token punctuation">,</span> event<span class="token punctuation">)</span>
    <span class="token comment">--keycode：键值</span>
    <span class="token comment">--event：事件</span>
    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&quot;按键抬起&quot;</span><span class="token punctuation">,</span> keycode<span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onKeyLongPress</span><span class="token punctuation">(</span>keycode<span class="token punctuation">,</span> event<span class="token punctuation">)</span>
    <span class="token comment">--keycode：键值</span>
    <span class="token comment">--event：事件</span>
    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&quot;按键长按&quot;</span><span class="token punctuation">,</span> keycode<span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onTouchEvent</span><span class="token punctuation">(</span>event<span class="token punctuation">)</span>
    <span class="token comment">--event：事件</span>
    <span class="token function">print</span><span class="token punctuation">(</span><span class="token string">&quot;触摸事件&quot;</span><span class="token punctuation">,</span> event<span class="token punctuation">)</span>
<span class="token keyword">end</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div></div></div>`,2);function r(v,m){const a=e("ExternalLinkIcon");return o(),c("div",null,[u,n("p",null,[n("a",d,[p("了解 Activity 生命周期"),i(a)])]),k])}const f=t(l,[["render",r],["__file","07.html.vue"]]);export{f as default};
