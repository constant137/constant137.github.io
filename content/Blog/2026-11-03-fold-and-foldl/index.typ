#import "../../defs/vscwriting.typ": * //--- debug mode ---

#import "../../defs/webpage.typ":*
#show: template.with(title: "Fold 与 Foldl")

#set text(lang: "zh",font: "Songti TC")
= Fold
== 简介
最近在学习haskell，这是一门函数式编程语言。在haskell中没有for可用，所以为了实现循环就要使用递归。对列表元素的求和，就是一个非常典型的循环模型。在c中对一个整数列表的元素求和可以使用类似的结构完成：
```c
int N = 3;
int* list = {1,2,3};
int sum = 0;
for(i = 0, i<N , i++){
  sum += list[i];
}
```
而在haskell中同样的效果可以用这个函数实现

```hs
sum :: [a] -> a
sum [] = 0
sum x:xs = x + sum xs
```

从代码中我们可以看出 sum 是个从 a 类型数据的列表到一个a类型数据的映射#footnote([当然前提是这个a类型的数据得*定义加法操作*同时*得包含0*。])，记作

```hs 
sum :: [a] -> a
``` 

函数的类型签名，说明了这一点。第二行表示对一个空列表求和的情况下`sum`的行为，结果显然是返回0。第三行对不熟悉haskell语法的人来说可能有点迷惑，这里涉及到haskell的*模式匹配*机制，当`sum`看见一个长得像 x:xs这样的东西的时候，就采用右侧的定义得到 ` sum x:xs ` 的结果。这里的*冒号*代表把 `x` 给贴到列表 `xs` 前面形成新的列表，即冒号是一个吃进某个数据类型的数据和该数据对应的列表返回一个该数据列表的函数。所以这里即使我们没有规定`xs`是一个列表，编译器也会猜到这里的`xs`应该是一个列表，否则冒号操作符就没法应用#footnote([这也代表着，`:`函数定死了是元素在左列表在右，元素从左贴到列表首位。想要从右侧将元素贴到列表上使用冒号会报错，得重新定义新的函数])。一个非空列表 `[1,2,3]==1:[2,3]==1:2:[3]=1:2:3:[]`，所以运行时程序会进行如下操作

```hs
sum 1:2:3:[] = 1 + sum 2:3:[]
             = 1 + (2 + sum 3:[])
             = 1 + (2 + (3 + sum []))
             = 1 + (2 + (3 + 0))
             = 6
```

最终返回给我们需要的求和结果。这里已经可以看到*Fold*的结构了，也就是本文将主要探讨的内容。

== Fold 的基本结构
让我们先从代码中回来，回到符号语言中，当我们说fold的时候我们是在表达什么事情呢？首先我们手里有一些变量
$  x in X,\ X={x_1,x_2,...,x_n},\ n in NN,  X subset XX  $
然后我们要依次对这个列表中的每一个元素运用一个函数$f(\_,\_)$，这是一个二元函数，返回值和列表中的元素是同一类型，即
$ f: (XX,XX) |-> XX $
最终得到的结果res是:
$ "res" = "fold"(f,x_0,{x_1,x_2,...,x_n}) = f(...f(f(f(x_0,x_1),x_2),x_3)...,x_n)  $
这里有两个细节，第一是我们又指定了一个$x_0$作为初始两个变量中的一个#footnote[当然这里默认$x_0 in XX$.]。我们当然可以把最内层改成 $f(x_1,x_2)$ 然后外面循环套用 $f$，这也是一种fold的结构。但是如果我们回头看我们求和的代码，会发现这里$x_0$起到了类似基底的作用，对于求和来说，它是0，对于乘法来说它是1。这是我们希望求和这个操作终止于空列表，而不是终止于单元素列表，如果没有补上这个 $x_0$，列表的长度就必须大于等于2才能对其使用fold，显然这对求和操作来说约束过大了。

第二个细节是，如何将上一步的结果代入到下一步的函数中以及从哪个方向进行迭代都会对最后的结果产生影响。仔细的读者会发现上面对fold的定义中，如果取$f$为加法，$x_0 =0$,列表为${1,2,3}$的话，得出的结果虽然和代码中的结果相同但是结构却是不一样的。而如果这里的函数是幂$"Pow"(x,y)=x^y$的话，结构的不同会更加明显（当然结果也完全不一样了）。
$
"fold"(+,0,{1,2,3})=((0+1)+2)+3\
"fold"("Pow",x,{a,b,c})=((x^a)^b)^c eq.not a^(b^(c^x))
$
这一节中的fold，把基底和上一步的结果代入函数左侧，然后从左侧开始迭代，所以重新给它一个名字foldl；而上一节中的fold将基底和上一步的结果代入函数右侧，然后从右侧开始迭代，则称为foldr。
$
  "foldl"(f,x_0,{x_1,x_2,...,x_n}) = f(...f(f(f(x_0,x_1),x_2),x_3)...,x_n)\
  "foldr"(f,x_0,{x_1,x_2,...,x_n}) = f(x_0,...,f(x_(n-2),f(x_(n-1),f(x_n,x_0)))...)
$
让我们先短暂地回到haskell，在haskell中它们对应的定义方式为:
#align(center)[```hs
foldr :: (a -> b -> b) -> b -> [a] -> b
foldr step zero (x:xs) = step x (foldr step zero xs)
foldr _ zero []        = zero

foldl :: (a -> b -> a) -> a -> [b] -> a
foldl step zero (x:xs) = foldl step (step zero x) xs
foldl _ zero []        = zero
```]
#link("https://rwh.readthedocs.io/en/latest/chp/4.html")[Real World Haskell]在介绍完了两个fold的基本性质以后，轻飘飘地来了一句：
#image("./imgs/fig1.png",width: 55%)
就好像这是已经非常显然的事情#footnote[显然并不是。]。我不是说这两个可以互相表示不显然，它们具有类似的结构，能够互相表示这件事不让人意外，令人意外的是在haskell中的构造方式并没有这句话看起来这么显然。

第一个问题，*TMD 这里的参数怎么多了一个！！* foldr右侧居然跟着四个参数#footnote[本应该只有三个 ```hs foldr f zero xs```]，多出来的这个全等函数id是怎么回事？

第二个问题，step 函数的定义为什么长这样，这明显也和后面的参数对不上啊，第一行step后面跟着的是一个函数一个列表一个列表元素，而第二行可以推测出g应该是一个函数才对，为什么它出现在了第二个位置？这个问题在我向ai提问后甚至变得更加费解了，ai告诉我应该将代码改成
```hs
myFoldl f acc xs = foldr step id xs acc  
    where step x id'  acc' = id' (f acc' x)
```
以消除变量的模糊性，可以看到下面的g代表的就是全等函数id，只是给它换了个名字。所以从第二行看step却是是将函数id放在了第二个变量的位置，这和第一行看起来是冲突的。这个问题主要是由于haskell中函数的结合性在没有括号时候的约定和我们想当然的不同而导致的，

  ```hs
   foldr step id xs acc = ((foldr step) id) xs acc
                       /= folder (step id xs acc)   --/=是haskell中的“不等于”
  ```

所以实际上是 foldr step id 这三个函数的结合体，这个结合体在 step 按照第二行那样定义的前提下，形成的函数是类似于 foldl f \_ \_ 的东西。

第三个问题，这个构造方式是怎么想到的？笔者比较熟悉Mathematica和它的语法，但是mathematica中提供的Fold只有Foldl，用其构造foldr的方式可以利用两个反向实现——反向函数的自变量顺序以及反向输入的列表。


  #figure(image("./imgs/foldl.png",width: 50%),
    caption:[Mathematica中的Fold是foldl])

  #figure(image("./imgs/foldr.png",width: 100%),
            caption: [使用mathematica内置函数实现用Fold表示foldr])
虽然mathematica标榜自己是一个函数式编程为主的语言，但这样的构造方式显然有很多过程式编程的思维存在其中。虽然这个方法非常直白易懂，但是并没有很好的帮助我理解上面这段haskell代码。
我产生了一些微妙的感受，全等函数 `id`的出现意味着确实复用了函数`step`，函数的变量的颠倒从两行代码中元素和列表的位置关系中能感觉到它们似乎真的被调换了。只是这种调换方式很隐蔽，以一种比较撩拨的方式引起了人的注意但是又不给你看见什么东西。

到目前为止聊感受的东西比较多，下面来点真实的数学。

== 利用foldr的性质构造各种递归函数
不加证明地给出 foldr 的 universal property#footnote[其实证明也非常简单就是直接根据定义算两步，直接去看参考文献吧。]


  #block(fill: luma(230),outset: 3pt,width: 54%,
    [
    $
    &g space \[space\] &&= v quad&  <=> quad g= "foldr" f space v\
    &g space (x:x s)   &&= f space x space (g space x s) &\
    $
    ]
  )

意思是，所有满足左侧递推关系的列表的函数 $g$ 都可以等效成右侧用foldr构造出来的形式，这是一个当且仅当的关系，所以反之也一样。

利用 universal property 可以构造出递归函数且证明的过程不再需要使用归纳法。是直接一步到位的证明（当然还是有必要的代数操作的）。现在我们利用这个性质来试试构造从左往右加的函数 `suml` 它同上面的 `sum = foldr (+) 0` 比起来更接近我们平时计算的顺序
```hs
    suml [] = v
suml (x:xs) = f x (suml xs)
```
我们要找到 `v f`的表达式。这里的`v`其实就是全等函数`id`，怎么得到这个结论呢？我们注意到理想中的 `suml`应该有两个参数，列表和求和基数 `n`,这个`n`通常为0然而实际上它可能非零。两边同时补上 `n`后发现
```hs
suml [] n = n
      v n = n
  --=>  v = id
```
那么 `f` 是什么？如法炮制先在两边添上`n`
```hs
suml (x:xs) n = f x (suml xs) n
--suml 的定义
suml xs (n+x) = f x (suml xs) n
--将 suml xs 看看作一个整体 g 
      g (n+x) = f x g n
```
到这里就结束了，不再需要继续求出f的表达式了！没反应过来的话可以看看在代码中`suml`该如何实现
```hs
suml xs n = foldr f id xs n
  where f x g n = g (n+x)
```
最后一行就是函数`f`的定义式，编译器会自动帮我们把`f`算出来放到第一行中。如果用语言描述的话`f`应该是一个满足依次放进 `x g n` 出来 `g (n+x)`的东西。
== foldl
绕了这么大一圈，我们最终回到 `foldl` 的构造。
```hs
foldl f acc xs = foldr step id xs acc  
    where step x id'  acc' = id' (f acc' x)
```
首先写出`foldl`的定义式
```hs
    foldl f v [] = v   
foldl f v (x:xs) = foldl f (f v x) xs
```
这里我们不能直接像前面那样非常直接地找出全等函数了。比如你会尝试说这样的东西是全等函数`foldl f _ [] = id`#footnote[这个挖空代表左边填v往这个洞里填但是右边填在右侧，这是一个我自创的用于表示的方法不要把它当成标准定义。]，或者填入一个任意函数 `v` 后回到原式。但这样的东西你在where中填进去以后相当于循环定义了。所以要换一种方式求解。

由于我们只是想证明用`foldr`定义出来的`foldl`和它原始定义等价，这里我们可以作弊。注意到 `acc xs` 在等式左右两侧交换了，所以我们可以构造这样一个函数`g`，它将 `foldl` 定义中的递归模式吸收到自身中去然后使得foldl可以以单行等式写出
```hs
foldl f v xs = g xs v
  where g [] v = v
      g (x:xs) v= g xs (f v x) 
```
所以我们有
```hs
      g [] = id
      g (x:xs) =\v -> g xs (f v x) 
```
末尾的记号`\x -> y`表示右侧代入`x`后得到`y`。假设二式右侧可以写成
```hs
 \v -> g xs (f v x) = k x (g xs)
 -- i.e.
 g xs (f v x) = k x (g xs) v
```
那么关于`g`的两个等式就完全满足 universal property 的结构了，也就是说会有如下关系
```hs
 g = foldr k id
 --i.e.
 foldl f v xs = g xs v = foldr k id xs v
  where k x (g xs) v = g xs (f v x)
```
以上还不是最终的代码，注意到 `k`的定义式中 `g xs` 是组合出现的，所以可以直接将其合并为一个函数,最终的代码为
```hs
 foldl f v xs = foldr k id xs v
  where k x g' v = g' (f v x)
```
这两种写法是完全等效的
```hs
foldl f acc xs = foldr step id xs acc  
    where step x id'  acc' = id' (f acc' x)
```
= 参考链接：
#link("https://people.cs.nott.ac.uk/pszgmh/fold.pdf")\
#link("https://www.zhihu.com/question/37817937/answer/73958515")