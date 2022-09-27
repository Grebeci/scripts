# Bash Scripting Basics

### Assignment and Substitution

```bash
a=123
b=$a
```

### Variables

1. Butil-in Variables 

	`$HOME $PWD` for more info, see [environ(7)](https://link.zhihu.com/?target=https%3A//man7.org/linux/man-pages/man7/environ.7.html)

2. Positional Parameters

	`$0 $1 $2 $3 $4 $@ $* $#`

3. Special Parameters
	$? # exit status of a command, function, or the script itself

	$$ # 当前进程的pid

	$! # 后台运行的最后一个进程pid

4.env

​	defined :`export var='123'`

​    print:  env | grep 'HOME'



### array

##### indexed array

```bash
myArray=(item1 item2 item3) # create 

${myArray[0]}  #array in index
${myArray[@]}  # arrray all
${myArray[*]}  # arrray all "${myArray[*]}" 加双引号看成整体


myArray[0]=value # array set element

length=${#myArray[@]} # array length

${!array[@]}  or ${!array[@]} # 输出有值的index
${array[@]:position:length}  # slice
 arr=(a b);arr+=(c d) # add  (a b c d) 
```

##### Associative arrays 



Bash 的新版本支持关联数组。关联数组使用字符串而不是整数作为数组索引。

`declare -A`可以声明关联数组。

```bash

decalre -A wordcount
wordcount['aaa']=1
wordcount['bbb']=2

#reference
echo ${wordcount['name']}

```



### String

```bash
# 这些操作返回结果，不会改变字符串
${#varname} # string length

${varname:offset:length} # 返回变量$varname的子字符串，从位置offset开始（从0开始计算），长度为length. offset 为负值，负一个空格

#head pattern
${variable#pattern} # 非贪婪
${variable##pattern} # 贪婪

#tail pattern 
${variable%pattern}
${variable%pattern}

# replace 
${variable/pattern/string} # 贪婪匹配，只替换第一个
${variable//pattern/string}# 贪婪匹配，替换所有

# upper -lower transform
# 转为大写
${varname^^}
# 转为小写
${varname,,}
```



### IO

STDIN : 标准输入  0  /dev/stdin

STDOUT: 标准输出  1  /dev/stdout

STDERR: 标准错误  2  /dev/stderr

黑洞：  /dev/null

```shell
command < input-file > output-file # rewrite  

command  > output-file  2>&1  <=>  command &> output-file  # 合并标准输入和
command >output-file 2> err-output-file 

command >> output-file 			# appending



```

##### heredoc

[Heredoc 入门 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/93993398)



### Conditional Expressions

详见 [Bash Conditional Expressions (Bash Reference Manual) ~ Bash条件表达式(Bash参考手册) (gnu.org)](https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html#Bash-Conditional-Expressions)

file exsit

    ```bash
    [ -d /bin]  # dir exist
    [ -e filename ] # file exist
    [ -f filename ]  #是否存在，且为普通文件
    [ -s filename ]  #file 非空未真
    ```

file privilege

```bash
[ -r filename ] # read
[ -w filename ] # write
[ -x filename ] # run
```

file modified time

```bash
[ file1 -nt file2 ] # file1 new time
[ file1 -ot file2 ] # file old time
[ file1 -ef file2 ] # inode equal => softlink -> file
```



整数比较

-eq  -ne -gt -lt -ge -le 

字符串

```bash
-z -n == !=
```

 

[[  ]] 和 []



正则

```
[[ string =~ regex ]]
```



and or

```bash
[ condition1 -a condition2 ]
[ condition1 -o condition2 ]

[[ condition1 && condition2 ]]
[[ condition1 || condition2 ]]
```



### Branches

```bash
if [ condition1 ];then
    command_series1
elif [ condition2 ];then
    command_series2
else
    default_command_series3
fi
```

```bash
if [ condition1 ];then command_series1 ; fi
```



##### case  command

```bash
case $x in
	pattern1)
  		;;
  	pattern2)
  		;;
	*)
     statementn
esac
```



### Loops

#### vars-like for

```bash
for arg in arg1 arg2 arg3 do
  echo $arg
done
```

#### range for

```bash
for arg in `seq 10`; do
  echo $arg
done


seq 1 3 10   #generate sequence  ， 使用空格分开的序列字符串
echo {1..10..1} #  generate sequence  
array=($(seq 10)) # 转成 array
```



#### for in C-like syntax

```bash
LIMIT=10
for ((a=1; a<=LIMIT; a++)); do
  echo "$a "
done
```



#### **while**

```bash
LIMIT=10
a=1
while ((a<=LIMIT)); do
    echo "$a "
    ((a += 1))
done
```



#### **until**

```bash
LIMIT=10
a=1
util ((a > LIMIT)); do
    echo "$a "
    ((a += 1))
done
```



### Function

```bash
# define a function
function fun_name(){
    command...
}
## or
fun_name(){ # arg1 arg2 arg3
    command...
}


# apply a function
fun_name $arg1 $arg2 $arg3


# dereference
fun_name(){ # arg1
    eval "$1=hello"
}
fun_name arg1
## the above code block is equivalent to 
arg1=hello
```



### Debugging

1. take good use of sh(1)
	for example:
	sh -n script: checks for syntax
	sh -v script: echo each command before executing it
	sh -x script: echo the result of each command in an abbreviated manner
2. use echo
3. use trap

### Parallel

use GNU parallel

### Script with Style

1. Comment your code
2. Avoid using magic number
3. Use exit codes in a systematic and meaningful way
4. Use standardized parameter flags for script invocation





管道符

1. 命令失败判断

set -

管道会开启子shell





控制流

顺序  ll ; cd / ; ll

且    command && command 

或    command || command 



##### 字符串字面量

"" ''





##### 子shell （fork）

`` (反引号)，var=$(command)，(command)

1. (comand1;command2) 
2. () > log  : 括号里面的所有stdout都会打到log中
3. 子shell exit失效



##### {}

{ command1;command2;}

当前shell执行一串命令，开始空格，结尾分号







##### set

set ： 系统所有变量（env，user defined)

-u 引用未声明的变量报错

-x 

unset









Bash 常用的快捷键







数值运算

```
var=$(expr 1 + 2) # 加号必须有空格
let var=1+2 # 加号不能有空格
ff=$(( 1+2 )) # 双括号必须有空格
ff=$[ 1+2 ]
```













