### shell 设计哲学

1.  一切（变量值）都是字符串
2.  对 空格（` `） 和 逗号 `;` 敏感， 且使用空格分隔参数，用都好分隔命令
3.  



##### shell 运行

1.

​    sh test.sh

2. 

	```bash
	 #!bin/bash
	 
	```

	chmod +x test.sh

	./test.sh

	/${absolutePath}/test.sh

3. 命令优先级

	显式调用脚本（绝对路径 / 相对路径 执行的路径

	别名（alias

	bash 内部命令

	PATH 的目录顺序查找



##### 配置文件

`/etc/profile `

`/etc/profile.d/*.sh`

`~/.bash_profile ` 

`~/.bashrc `

`/etc/bashrc`

```
/etc/profile 		-> 		 ~/bash_profile          ->         ~/.bashrc		->		/etc/bashrc      -> 命令提示符

   		|																					|
   		|                                                                                   |
  	    V																					|
  /etc/profile.d/*.sh              <-                   <-                 <-               |
  
   
```



新增环境变量

​	对所有用户生效： /etc/profile  或者 /etc/profile/my.sh

​	对某个用户有效： ~/bashrc  ~/bash_profile







# Xargs





# Sed

字符串替换

修改

s 模式 正则

y 模式 字符替换

```bash
sed 's/pattern/replace_string' file

cat file | sed 's/pattern/replace_string' 

-i #修改数据文件
sed -i 's/text/replace' file

g #全局替换 /#g 第N个
sed 's/text/replace/g' file
sed 's/text/replace/2g' file  # 替换第二个

# sed命令会将s之后的字符视为命令分隔符
sed 's:text:replace:g' file  # 等价于 sed -i 's/text/replace/g' file
# 分隔符出现在模式中，要进行转移
sed 's/\/\//#/g' file # 把文件的 \\ 替换成 #


```

删除

```bash
# 移除空行
sed 's/^$/d' file
```

插入

```bash
sed '/text/r ins.txt' file # 向 file text 下面一行插入ins.txt 的内容

#   a\   下面一行插入文本   i\ 上面一行插入
sed '/text/a\replace' file
```

剪切



```bash
 sed ‘/200[4-6]/w new.txt’ mysed.txt
```

# Awk



```bash
awk 'BEGIN{ print "start" } pattern { commands } END{ print "end" }' file
```



结构：

​	BEGIN{print "start"} : 读取输出流前执行，可选

​	pattern { commands } ： 公共语句块。patter可以是正则，条件语句，行范围。pattern 是可选的

​    END{ print "end" }   ： 读完输入流后执行。



awk 逐行处理文件 ，也就是说 ，输入多少行，语句块`pattern { commands }`触发多少次

```bash
awk '{print $1,$2}' /etc/passwd  # 打印文件的前两列
```

print 函数，参数使用逗号分隔， 打印参数时用空格(`OFS`)作为参数的分隔符



`-F` 字段分隔符

```bash
awk -F: '{ print $NF }' /etc/passwd 
```

嵌入shell命令

todo

build-in function 

```bash
tolower()：字符转为小写。
length()：返回字符串长度。
substr()：返回子字符串。

# substring 
index(string, search_string)：返回search_string在字符串string中出现的位置
split(string, array, delimiter)：以delimiter作为分隔符，分割字符串string， 将生成的字符串存入数组array
substr(string, start-position, end-position) ：返回字符串 string 中 以 start-position和end-position作为起止位置的子串。 posttion 从1 开始

# 正则替换
sub(regex, replacement_str, string)：将正则表达式regex匹配到的第一处内容
gsub(regex, replacement_str, string)：全局替换
match(regex, string)：正则匹配 找到返回非0，否则返回0

# math function
sin()：正弦。
cos()：余弦。
sqrt()：平方根。
rand()：随机数。
```



变量

`$0`：当前记录的文本内容。 

`$1`：当前记录第一个字段的文本内容

`$2`：当前记录第二个字段的文本内容

`NR`: 当前行号

`NF`：字段数量



`FILENAME`：当前文件名

`FS`：字段分隔符，默认是空格和制表符。

`OFS`：输出字段的分隔符，用于打印时分隔字段，默认为空格。

`RS`：行分隔符，用于分割每一行，默认是换行符。

`ORS`：输出记录的分隔符，用于打印时分隔记录，默认为换行符。

# tr

字符替换删除

[shell命令--tr - MineGi - 博客园 (cnblogs.com)](https://www.cnblogs.com/MineGi/p/12206943.html#:~:text=shell命令--tr 0、tr命令的专属图床 点此快速打开文章 【 图床_shell命令tr,】 1、tr命令的功能说明 tr 命令从标准输入中替换、缩减或者删除字符、并将结果写到标准输出， Linux 里严格区分大小写。)

```bash
tr '[set1]' '[set2]' # 把set1 替换成set2
tr -d '[set1]' #删除字符集 
tr -c '[set1]' '[set2]'  # 不在set1 中的都替换成set2
tr -d -c '[set1' '[set2]' # 如果-c与-d选项同时出现，你只能使用set1，其他所有的字符都会被删除   (删除不在set1 中的所有字符

tr -s '[需要被压缩的一组字符]' # 删除重复字符
```









