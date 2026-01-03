#import "../config.typ": template, tufted
#show: template

// tufted.margin-note 可以让你在边栏中放置内容
// 宽大的边栏是 tufte 样式的特点，将注释放于其中并与正文并排，便于对照
#tufted.margin-note({
  image("imgs/icon.png",height: 25%)
})
#tufted.margin-note[自绘的头像，来自于我的手机壳图案]
= Constant137 的个人网站 / Constant137's Personal Website 

这是一个基于 #link("https://typst.app/")[Typst] 和 #link("https://github.com/vsheg/tufted")[Tufted] 的静态网站构建模板的个人博客。中文版模版来自于 #link("https://little-yousa-mirage.github.io/")[Yousa-Mirage], 我在此基础上做了一些修改以适应我的需求。

#figure[#image("imgs/devices.webp")]

#link("https://edwardtufte.github.io/tufte-css/")[*The Tufte style*] originates from the design philosophy of data visualization master _Edward Tufte_#footnote[Edward Rolf Tufte (/ˈtʌfti/; born March 14, 1942), sometimes known as "ET", is an American statistician and professor emeritus of political science, statistics, and computer science at Yale University. He is noted for his writings on information design and as a pioneer in the field of data visualization.], advocating for a "content-first" approach and minimalism while striving to eliminate all visual noise that distracts from the information.

