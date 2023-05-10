# 主题测试页面

## Title 2

### Title 3

#### Title 4

##### Title 5

###### Title 6

- VuePress - <Badge type="tip" text="v2" vertical="top" />
- VuePress - <Badge type="warning" text="v2" vertical="middle" />
- VuePress - <Badge type="danger" text="v2" vertical="bottom" />

:::: code-group
::: code-group-item Lua

```lua{8}
local text = ""
for index1 = 1, 9 do
    for index2 = 1, index1 do
        text=text .. index1 .. "x" .. index2 .. "=" .. index1 * index2 .. (index2 ~= 9 and "\t" or "")
    end
    text=text .. (index1 ~= 9 and "\n" or "")
end
print(text)
```

:::
::: code-group-item Java

``` java ts{3}
class HelloJava{
    public static void main(String[] args){
        System.out.println("Hello Java!");
    }
}
```

:::
::: code-group-item Python

``` python{6}
text = ""
for index1 in range(1, 10):
    for index2 in range(1, index1 + 1):
        text = text + str(index1) + "x" + str(index2) + "=" + str(index1 * index2) + ("\t" if index2 != index1 else "")
    text = text + ("\n" if index1 != 9 else "")
print(text)
```

:::
::: code-group-item JavaScript

``` js{8}
let text = "";
for (let index1 = 1; index1<=9; index1++){
    for (let index2 = 1; index2<=index1; index2++){
        text=text + index1 + "x" + index2 + "=" + index1 * index2 + (index1 != index2? "\t": "");
    }
    text=text + (index1 != 9? "\n": "");
}
console.log(text);
```

:::
::: code-group-item C++

``` cpp
#include <iostream>
using namespace std;
int main() {
    for (int index1 = 1; index1<=9; index1++) {
        for (int index2 = 1; index2<=index1; index2++) {
            cout << index1 << 'x' << index2 << '=' << index2*index2 << (index1 != index2? "\t": "");
        }
        cout << (index1 != 9? "\n": "");
    }
    return 0;
}```

:::
::: code-group-item XML

``` xml
<manifest
    xmlns:android="http://schemas.android.com/apk/res/android"
    package="test.code">
    <application
        android:label="@string/app_name"
        android:icon="@mipmap/ic_launcher"
        android:theme="@style/Theme.TestCode">
        <activity
            android:label="@string/app_name"
            android:name="com.jesse205.superlua.LuaActivity"/>
    <application/>
</manifest>
```

:::

::::

这是独立的代码块：

``` lua
local text = ""
for index1 = 1, 9 do
    for index2 = 1, index1 do
      text=text .. index1 .. "x" .. index2 .. "=" .. index1 * index2 .. (index2 ~= 9 and " " or "")
    end
    text=text .. (index1 ~= 9 and "\n" or "")
end
print(text)
```

这是长代码块：

``` lua ts{112}
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
print("hello world")
```

``` ts:no-line-numbers
// 行号被禁用
const line2 = 'This is line 2'
const line3 = 'This is line 3'
```

``` lua
字体测试
--0123456789
--abcdefgABCDEFG
0123456789
abcdefgABCDEFG
-- --- == === != !== =!=
=:= =/= <= >= && &&& &= ++
+++ *** ;; !! ?? ??? ?: ?.
?= <: :< :> >: <:< <> <<< >>>
<< >> || -| _|_ |- ||- |= ||=
## ### #### #{ #[ ]# #( #? #_ #_(
#: #! #= ^= <$> <$ $> <+> <+ +>
<*> <* *> </ </> /> <!-- <#--
--> -> ->> <<- <- <=< =<< <<=
<== <=> <==> ==> => =>> >=> >>=
>>- >- -< -<< >-> <-< <-| <=|
|=> |-> <-> <~~ <~ <~> ~~ ~~>
~> ~- -~ ~@ [||] |] [| |} {|
[< >] |> <| ||> <|| |||> <|||
<|> ... .. .= ..< .? :: ::: :=
::= :? :?> // /// /* */ /= //=
/== @_ __
```

这是 `代码`

>我是引用

::: tip
这是一个 `提示`
> 这是 `提示` 里面的引用

:::

::: warning
这是一个 `警告`
> 这是 `警告` 里面的引用

:::

::: danger
这是一个 `危险警告`
> 这是 `危险警告` 里面的引用

:::

::: details
这是一个 `details 标签`
| 标题1 | 标题2 | 标题3 |
| ---- | ---- | ---- |
| 内容1 | 内容2 | 内容3 |
| 内容1 | 内容2 | 内容3 |
| 内容1 | 内容2 | 内容3 |
| 内容1 | 内容2 | 内容3 |

:::
