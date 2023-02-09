import{_ as s,M as t,p as o,q as i,R as n,t as c,N as l,a1 as a}from"./framework-ea2a9e6e.js";const d={},p=a(`<h1 id="快速入门" tabindex="-1"><a class="header-anchor" href="#快速入门" aria-hidden="true">#</a> 快速入门</h1><p>AndroLua 是一个使用 Lua 语法编写可以使用安卓 API 的轻型脚本编程工具，使用它可以快速编写安卓应用。</p><p>第一次打开程序默认创建 <code>new.lua</code> ，并添加以下代码</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code>require <span class="token string">&quot;import&quot;</span>
import <span class="token string">&quot;android.widget.&quot;</span>
import <span class="token string">&quot;android.view.&quot;</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div></div></div><p><code>require &quot;import&quot;</code> 是导入 <code>import</code> 模块，该模块集成了很多实用的函数，可以大幅度减轻写代码负担，详细函数说明参考程序帮助。</p><p><code>import &quot;android.widget.*&quot;</code> 是导入 Java 包。</p><p>这里导入了 <code>android</code> 的 <code>widget</code> 和 <code>view</code> 两个包。</p><p>导入包后使用类是很容易的，新建类实例和调用 Lua 的函数一样。</p><p>比如新建一个 TextView</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code>textView<span class="token operator">=</span><span class="token function">TextView</span><span class="token punctuation">(</span>activity<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><p><code>activity</code> 表示当前活动的 <code>context</code>。</p><p>同理新建按钮</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code>button<span class="token operator">=</span><span class="token function">Button</span><span class="token punctuation">(</span>activity<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><p>给视图设置属性也非常简单</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code>button<span class="token punctuation">.</span>text<span class="token operator">=</span><span class="token string">&quot;按钮&quot;</span>
button<span class="token punctuation">.</span>backgroundColor<span class="token operator">=</span><span class="token number">0xff0000ff</span> <span class="token comment">-- 这里必须使用 number 类型</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div><div class="line-number"></div></div></div><p>添加视图事件回调函数</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code>button<span class="token punctuation">.</span>onClick<span class="token operator">=</span><span class="token keyword">function</span><span class="token punctuation">(</span>view<span class="token punctuation">)</span>
  <span class="token function">print</span><span class="token punctuation">(</span>view<span class="token punctuation">)</span>
<span class="token keyword">end</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div></div></div><p>函数参数 <code>view</code> 是视图本身。</p>`,18),u={href:"https://developer.android.google.cn/develop/ui/views/layout/linear",target:"_blank",rel:"noopener noreferrer"},r=n("code",null,"LinearLayout",-1),v=a(`<div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code>layout<span class="token operator">=</span><span class="token function">LinearLayout</span><span class="token punctuation">(</span>activity<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><p>用 <code>addView</code> 添加视图</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code>layout<span class="token punctuation">.</span><span class="token function">addView</span><span class="token punctuation">(</span>button<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><p>最后调用 <code>activity</code> 的 <code>setContentView()</code> 方法显示内容</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code>activity<span class="token punctuation">.</span><span class="token function">setContentView</span><span class="token punctuation">(</span>layout<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><p>这里演示 Androlua 基本用法，通常我们需要新建一个工程来开发，代码的用法是相同的，具体细节请详细阅读后面的内容。</p>`,6);function m(k,g){const e=t("ExternalLinkIcon");return o(),i("div",null,[p,n("p",null,[c("安卓的视图需要添加到布局才能显示到活动，一般我们常用 "),n("a",u,[r,l(e)])]),v])}const f=s(d,[["render",m],["__file","fast.html.vue"]]);export{f as default};