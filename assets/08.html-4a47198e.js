import{_ as n,p as s,q as a,a1 as e}from"./framework-ea2a9e6e.js";const t={},o=e(`<h1 id="按键与触控" tabindex="-1"><a class="header-anchor" href="#按键与触控" aria-hidden="true">#</a> 按键与触控</h1><p>支持 <code>onKeyDown</code> , <code>onKeyUp</code> , <code>onKeyLongPress</code> , <code>onTouchEvent</code><br> 函数必须返布尔值</p><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code><span class="token keyword">function</span> <span class="token function">onKeyDown</span><span class="token punctuation">(</span>code<span class="token punctuation">,</span>event<span class="token punctuation">)</span>
    <span class="token function">print</span><span class="token punctuation">(</span>code<span class="token punctuation">,</span>event<span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onKeyUp</span><span class="token punctuation">(</span>code<span class="token punctuation">,</span>event<span class="token punctuation">)</span>
    <span class="token function">print</span><span class="token punctuation">(</span>code<span class="token punctuation">,</span>event<span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onKeyLongPress</span><span class="token punctuation">(</span>code<span class="token punctuation">,</span>event<span class="token punctuation">)</span>
    <span class="token function">print</span><span class="token punctuation">(</span>code<span class="token punctuation">,</span>event<span class="token punctuation">)</span>
<span class="token keyword">end</span>

<span class="token keyword">function</span> <span class="token function">onTouchEvent</span><span class="token punctuation">(</span>event<span class="token punctuation">)</span>
    <span class="token function">print</span><span class="token punctuation">(</span>event<span class="token punctuation">)</span>
<span class="token keyword">end</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div></div></div>`,3),c=[o];function p(i,l){return s(),a("div",null,c)}const d=n(t,[["render",p],["__file","08.html.vue"]]);export{d as default};
