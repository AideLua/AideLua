import{_ as n,p as s,q as a,a1 as t}from"./framework-ea2a9e6e.js";const o={},p=t(`<h1 id="import-模块" tabindex="-1"><a class="header-anchor" href="#import-模块" aria-hidden="true">#</a> import 模块</h1><div class="language-lua line-numbers-mode" data-ext="lua"><pre class="language-lua"><code>require <span class="token string">&quot;import&quot;</span>
import <span class="token string">&quot;android.widget.*&quot;</span>
import <span class="token string">&quot;android.view.*&quot;</span>
layout<span class="token operator">=</span><span class="token punctuation">{</span>
    LinearLayout<span class="token punctuation">,</span>
    orientation<span class="token operator">=</span><span class="token string">&quot;vertical&quot;</span><span class="token punctuation">,</span>
    <span class="token punctuation">{</span>
        EditText<span class="token punctuation">,</span>
        id<span class="token operator">=</span><span class="token string">&quot;edit&quot;</span><span class="token punctuation">,</span>
        layout_width<span class="token operator">=</span><span class="token string">&quot;fill&quot;</span>
    <span class="token punctuation">}</span><span class="token punctuation">,</span>
    <span class="token punctuation">{</span>
        Button<span class="token punctuation">,</span>
        text<span class="token operator">=</span><span class="token string">&quot;按钮&quot;</span><span class="token punctuation">,</span>
        layout_width<span class="token operator">=</span><span class="token string">&quot;fill&quot;</span><span class="token punctuation">,</span>
        onClick<span class="token operator">=</span><span class="token string">&quot;click&quot;</span>
    <span class="token punctuation">}</span>
<span class="token punctuation">}</span>

<span class="token keyword">function</span> <span class="token function">click</span><span class="token punctuation">(</span><span class="token punctuation">)</span>
    Toast<span class="token punctuation">.</span><span class="token function">makeText</span><span class="token punctuation">(</span>activity<span class="token punctuation">,</span> edit<span class="token punctuation">.</span><span class="token function">getText</span><span class="token punctuation">(</span><span class="token punctuation">)</span><span class="token punctuation">.</span><span class="token function">toString</span><span class="token punctuation">(</span><span class="token punctuation">)</span><span class="token punctuation">,</span> Toast<span class="token punctuation">.</span>LENGTH_SHORT<span class="token punctuation">)</span><span class="token punctuation">.</span><span class="token function">show</span><span class="token punctuation">(</span><span class="token punctuation">)</span>
<span class="token keyword">end</span>
activity<span class="token punctuation">.</span><span class="token function">setContentView</span><span class="token punctuation">(</span><span class="token function">loadlayout</span><span class="token punctuation">(</span>layout<span class="token punctuation">)</span><span class="token punctuation">)</span>
</code></pre><div class="line-numbers" aria-hidden="true"><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div><div class="line-number"></div></div></div>`,2),e=[p];function i(c,u){return s(),a("div",null,e)}const r=n(o,[["render",i],["__file","14.4.html.vue"]]);export{r as default};
