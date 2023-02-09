import{_ as a,p as n,q as s,a1 as e}from"./framework-ea2a9e6e.js";const t={},i=e(`<h1 id="luadialog-对话框" tabindex="-1"><a class="header-anchor" href="#luadialog-对话框" aria-hidden="true">#</a> LuaDialog 对话框</h1><h2 id="构建方法" tabindex="-1"><a class="header-anchor" href="#构建方法" aria-hidden="true">#</a> 构建方法</h2><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code>dlg<span class="token operator">=</span><span class="token function">LuaDialog</span><span class="token punctuation">(</span>activity<span class="token punctuation">,</span>theme<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><p><code>activity</code> 当前活动 <code>theme</code> 主题(可选)</p><h2 id="公有方法" tabindex="-1"><a class="header-anchor" href="#公有方法" aria-hidden="true">#</a> 公有方法</h2><h3 id="标题" tabindex="-1"><a class="header-anchor" href="#标题" aria-hidden="true">#</a> 标题</h3><p>设置标题</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token function">setTitle</span><span class="token punctuation">(</span>title<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><p>获取标题</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token function">getTitle</span><span class="token punctuation">(</span><span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><h3 id="提示信息" tabindex="-1"><a class="header-anchor" href="#提示信息" aria-hidden="true">#</a> 提示信息</h3><p>设置提示信息</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token function">setMessage</span><span class="token punctuation">(</span>message<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><p>获取提示信息</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token function">getMessage</span><span class="token punctuation">(</span><span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><h3 id="视图" tabindex="-1"><a class="header-anchor" href="#视图" aria-hidden="true">#</a> 视图</h3><p>设置视图</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token function">setView</span><span class="token punctuation">(</span>view<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><p>获取视图</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token function">getView</span><span class="token punctuation">(</span><span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><p>获取列表</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token function">getListView</span><span class="token punctuation">(</span><span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><h3 id="其他" tabindex="-1"><a class="header-anchor" href="#其他" aria-hidden="true">#</a> 其他</h3><p>设置图标</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token function">setIcon</span><span class="token punctuation">(</span>icon<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><p>设置是否可取消</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token function">setCancelable</span><span class="token punctuation">(</span>cancelable<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><p>设置按钮</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token function">setButton</span><span class="token punctuation">(</span>text<span class="token punctuation">,</span> listener<span class="token punctuation">)</span>
<span class="token function">setPositiveButton</span><span class="token punctuation">(</span>text<span class="token punctuation">,</span> listener<span class="token punctuation">)</span>
<span class="token function">setNegativeButton</span><span class="token punctuation">(</span>text<span class="token punctuation">,</span> listener<span class="token punctuation">)</span>
<span class="token function">setNeutralButton</span><span class="token punctuation">(</span>text<span class="token punctuation">,</span> listener<span class="token punctuation">)</span>
<span class="token function">setPositiveButton</span><span class="token punctuation">(</span>text<span class="token punctuation">,</span> listener<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div></div></div><p>设置列表数据</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token function">setItems</span><span class="token punctuation">(</span>items<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><p>设置单选列表数据</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token function">setSingleChoiceItems</span><span class="token punctuation">(</span>items<span class="token punctuation">,</span> checkedItem<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><p>设置多选列表数据</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token function">setMultiChoiceItems</span><span class="token punctuation">(</span>items<span class="token punctuation">,</span> checkedItems<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><p>设置列表适配器</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token function">setAdapter</span><span class="token punctuation">(</span>adp<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div><p>设置列表点击事件</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token function">setOnItemClickListener</span><span class="token punctuation">(</span>listener<span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div></div></div>`,39),l=[i];function u(c,p){return n(),s("div",null,l)}const o=a(t,[["render",u],["__file","15.3.html.vue"]]);export{o as default};