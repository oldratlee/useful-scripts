:snail: useful-scripts
====================================

把平时有用的手动操作做成脚本，这样可以便捷的使用。 :sparkles:

有自己用的好的脚本 或是 平时常用但没有写成脚本的功能，欢迎提供（[提交Issue](https://github.com/oldratlee/useful-scripts/issues))和分享（[Fork后提交代码](https://github.com/oldratlee/useful-scripts/fork)）！ :sparkling_heart:

:beginner: 快速下载&使用
----------------------

```bash
source <(curl -fsSL https://raw.githubusercontent.com/oldratlee/useful-scripts/master/test-cases/self-installer.sh)
```

更多下载&使用方式，参见[下载使用](#key-下载使用)一节。

:beer: [show-busy-java-threads.sh](show-busy-java-threads.sh)
----------------------

在排查`Java`的`CPU`性能问题时(`top us`值过高)，要找出`Java`进程中消耗`CPU`多的线程，并查看它的线程栈，从而找出导致性能问题的方法调用。

PS：如何操作可以参见[@bluedavy](http://weibo.com/bluedavy)的《分布式Java应用》的【5.1.1 cpu消耗分析】一节，说得很详细：`top`命令开启线程显示模式、按`CPU`使用率排序、记下`Java`进程里`CPU`高的线程号；手动转成十六进制（可以用`printf %x 1234`）；`jstack`，`grep`十六进制的线程`id`，找到线程栈。查问题时，会要多次这样操作，太繁琐。

这个脚本的功能是，打印出在运行的`Java`进程中，消耗`CPU`最多的线程栈（缺省是5个线程）。

### 用法

```bash
show-busy-java-threads.sh -c <要显示的线程栈数>
# 上面会从所有的Java进程中找出最消耗CPU的线程，这样用更方便。

show-busy-java-threads.sh -c <要显示的线程栈数> -p <指定的Java Process>
```

### 示例

```bash
$ show-busy-java-threads.sh 
The stack of busy(57.0%) thread(23355/0x5b3b) of java process(23269) of user(admin):
"pool-1-thread-1" prio=10 tid=0x000000005b5c5000 nid=0x5b3b runnable [0x000000004062c000]
   java.lang.Thread.State: RUNNABLE
	at java.text.DateFormat.format(DateFormat.java:316)
	at com.xxx.foo.services.common.DateFormatUtil.format(DateFormatUtil.java:41)
	at com.xxx.foo.shared.monitor.schedule.AppMonitorDataAvgScheduler.run(AppMonitorDataAvgScheduler.java:127)
	at com.xxx.foo.services.common.utils.AliTimer$2.run(AliTimer.java:128)
	at java.util.concurrent.ThreadPoolExecutor$Worker.runTask(ThreadPoolExecutor.java:886)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:908)
	at java.lang.Thread.run(Thread.java:662)

The stack of busy(26.1%) thread(24018/0x5dd2) of java process(23269) of user(admin):
"pool-1-thread-2" prio=10 tid=0x000000005a968800 nid=0x5dd2 runnable [0x00000000420e9000]
   java.lang.Thread.State: RUNNABLE
	at java.util.Arrays.copyOf(Arrays.java:2882)
	at java.lang.AbstractStringBuilder.expandCapacity(AbstractStringBuilder.java:100)
	at java.lang.AbstractStringBuilder.append(AbstractStringBuilder.java:572)
	at java.lang.StringBuffer.append(StringBuffer.java:320)
	- locked <0x00000007908d0030> (a java.lang.StringBuffer)
	at java.text.SimpleDateFormat.format(SimpleDateFormat.java:890)
	at java.text.SimpleDateFormat.format(SimpleDateFormat.java:869)
	at java.text.DateFormat.format(DateFormat.java:316)
	at com.xxx.foo.services.common.DateFormatUtil.format(DateFormatUtil.java:41)
	at com.xxx.foo.shared.monitor.schedule.AppMonitorDataAvgScheduler.run(AppMonitorDataAvgScheduler.java:126)
	at com.xxx.foo.services.common.utils.AliTimer$2.run(AliTimer.java:128)
	at java.util.concurrent.ThreadPoolExecutor$Worker.runTask(ThreadPoolExecutor.java:886)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:908)
...
```

上面的线程栈可以看出，`CPU`消耗最高的2个线程都在执行`java.text.DateFormat.format`，业务代码对应的方法是`shared.monitor.schedule.AppMonitorDataAvgScheduler.run`。可以基本确定：

- `AppMonitorDataAvgScheduler.run`调用`DateFormat.format`次数比较频繁。
- `DateFormat.format`比较慢。（这个可以由`DateFormat.format`的实现确定。）

多个执行几次`show-busy-java-threads.sh`，如果上面情况高概率出现，则可以确定上面的判定。  
\# 因为调用越少代码执行越快，则出现在线程栈的概率就越低。

分析`shared.monitor.schedule.AppMonitorDataAvgScheduler.run`实现逻辑和调用方式，以优化实现解决问题。

### 贡献者

[silentforce](https://github.com/silentforce)改进此脚本，增加对环境变量`JAVA_HOME`的判断。

:beer: [show-duplicate-java-classes.py](show-duplicate-java-classes.py)
----------------------

找出`java`库（即`jar`文件）中的重复类。

`java`开发的一个麻烦的问题是`jar`冲突（即多个版本的jar），或者说重复类。会出`NoSuchMethod`等的问题，还不见得当时出问题。

找出有重复类的`jar`，可以防患未然。

### 用法

```bash
# 查找当前目录下所有Jar中的重复类的jar
show-duplicate-java-classes.py

# 查找当前目录下所有Jar中的重复类的Jar
show-duplicate-java-classes.py -v

# 查找当前目录及其子目录下所有Jar中的重复类
show-duplicate-java-classes.py -r

# 查找当前目录下所有Jar中的重复类，排除指定的一些Jar，使用glob匹配
show-duplicate-java-classes.py -e '*spring*.jar' --excludes '*apache*.jar'

# 查找当前目录下所有Jar中的重复类，结果到html文件中，包含Jar中重复类的明细
show-duplicate-java-classes.py --html
```

### 示例

```bash
$ show-duplicate-java-classes.py
['./ace4j-servicemgr-inner-api-0.0.1-20141223.031744-27.jar', './ace4j-servicemgr-inner-impl-0.0.1-20141223.031744-27.jar']
['./ace4j-servicemgr-impl-0.0.1-SNAPSHOT.jar', './ace4j-servicemgr-inner-impl-0.0.1-20141223.031744-27.jar']
......

$ show-duplicate-java-classes.py --html > result.html
```

### 贡献者

[tgic](https://github.com/tg123)提供此脚本。友情贡献者的链接[commandlinefu.cn](http://commandlinefu.cn/)|[微博linux命令行精选](http://weibo.com/u/2674868673)

:beer: [find-in-jars.sh](find-in-jars.sh)
----------------------

在当前目录下所有`Jar`文件里，查找文件名。

### 用法

```bash
find-in-jars.sh 'log4j\.properties'
find-in-jars.sh 'log4j\.xml$' -d /path/to/find/directory
find-in-jars.sh log4j\\.xml
find-in-jars.sh 'log4j\.properties|log4j\.xml'
```

注意，后面Pattern是`grep`的 **扩展**正则表达式。

### 示例

```bash
$ ./find-in-jars 'Service.class$'
./WEB-INF/libs/spring-2.5.6.SEC03.jar!org/springframework/stereotype/Service.class
./rpc-benchmark-0.0.1-SNAPSHOT.jar!com/taobao/rpc/benchmark/service/HelloService.class
```

### 参考资料

[在多个Jar(Zip)文件查找Log4J配置文件的Shell命令行](http://oldratlee.com/458/tech/shell/find-file-in-jar-zip-files.html)

:beer: [swtrunk.sh](swtrunk.sh)
----------------------

`svn`工作目录从分支（`branches`）切换到主干（`trunk`）。

命令以`SVN`的标准目录命名约定来识别分支和主干。
即，分支在目录`branches`下，主干在目录`trunk`下。
示例：
- 分支： http://www.foo.com/project1/branches/feature1
- 主干： http://www.foo.com/project1/trunk

### 用法

```bash
swtrunk.sh # 缺省使用当前目录作为SVN工作目录
cp-svn-url.sh /path/to/svn/work/directory
cp-svn-url.sh /path/to/svn/work/directory1 /path/to/svn/work/directory2 # SVN工作目录个数不限制
```

### 示例

```bash
$ swtrunk.sh
# <svn sw output...>
svn work dir . switch from http://www.foo.com/project1/branches/feature1 to http://www.foo.com/project1/trunk !

$ swtrunk.sh /path/to/svn/work/dir
# <svn sw output...>
svn work dir /path/to/svn/work/dir switch from http://www.foo.com/project1/branches/feature1 to http://www.foo.com/project1/trunk !

$ swtrunk.sh /path/to/svn/work/dir1 /path/to/svn/work/dir2
# <svn sw output...>
svn work dir /path/to/svn/work/dir1 switch from http://www.foo.com/project1/branches/feature1 to http://www.foo.com/project1/trunk !
# <svn sw output...>
svn work dir /path/to/svn/work/dir2 switch from http://www.foo.com/project2/branches/feature1 to http://www.foo.com/project2/trunk !
```

:beer: [svn-merge-stop-on-copy.sh](svn-merge-stop-on-copy.sh)
----------------------

把指定的远程分支从刚新建分支以来的修改合并到本地SVN目录或是另一个远程分支。

### 用法

```bash
svn-merge-stop-on-copy.sh <来源的远程分支> # 合并当前本地svn目录
svn-merge-stop-on-copy.sh <来源的远程分支> <目标本地svn目录>
svn-merge-stop-on-copy.sh <来源的远程分支> <目标远程分支>
```

### 示例

```bash
svn-merge-stop-on-copy.sh http://www.foo.com/project1/branches/feature1 # 缺省使用当前目录作为SVN工作目录
svn-merge-stop-on-copy.sh http://www.foo.com/project1/branches/feature1 /path/to/svn/work/directory
svn-merge-stop-on-copy.sh http://www.foo.com/project1/branches/feature1 http://www.foo.com/project1/branches/feature2
```

### 贡献者

[姜太公](https://github.com/jiangjizhong)提供此脚本。

:beer: [cp-svn-url.sh](cp-svn-url.sh)
----------------------

拷贝当前`svn`目录对应的远程分支到系统的粘贴板，省去`CTRL+C`操作。

### 用法

```bash
cp-svn-url.sh # 缺省使用当前目录作为SVN工作目录
cp-svn-url.sh /path/to/svn/work/directory
```

### 示例

```bash
$ cp-svn-url.sh
http://www.foo.com/project1/branches/feature1 copied!
```

### 贡献者

[ivanzhangwb](https://github.com/ivanzhangwb)提供此脚本。

### 参考资料

[拷贝复制命令行输出放在系统剪贴板上](http://oldratlee.com/post/2012-12-23/command-output-to-clip)，给出了不同系统可用命令。

:beer: [console-text-color-themes.sh](console-text-color-themes.sh)
----------------------

显示`Terminator`的全部文字彩色组合的效果。

脚本中，也给出了`colorEcho`和`colorEchoWithoutNewLine`函数更方便输出彩色文本，用法：

```bash
colorEcho <颜色样式> <要输出的文本>...
colorEchoWithoutNewLine  <颜色样式> <要输出的文本>...
```

```bash
# 输出红色文本
colorEcho "0;31;40" "Hello world!"
# 输出黄色带下划线的文本
colorEchoWithoutNewLine "4;33;40" "Hello world!" "Hello Hell!"
```

`console-text-color-themes.sh`的运行效果图如下：   
![console-text-color-themes.sh的运行效果图](https://raw.github.com/wiki/oldratlee/useful-scripts/console-colorful-text.png)

### 贡献者

[姜太公](https://github.com/jiangjizhong)提供循环输出彩色组合的脚本。

### 参考资料

- [utensil](https://github.com/utensil)的[在Bash下输出彩色的文本](http://utensil.github.io/tech/2007/09/10/colorful-bash.html)，这是篇很有信息量很钻研的文章！

:beer: [colorful-lines](colorful-lines)
----------------------

彩色`cat`出文件行，方便人眼区分不同的行。

### 示例

```bash
$ echo a | colorful-lines
a
$ echo -e 'a\nb' | colorful-lines
a
b
$ echo -e 'a\nb' | nl | colorful-lines
1   a
2   b
$ colorful-lines file1 file2
==== file1 ====
file1 line1
file1 line2
==== file2 ====
file2 line1
file2 line2
```

注：上面显示中，没有彩色，在控制台上运行可以看出彩色效果。

:beer: [echo-args.sh](echo-args.sh)
----------------------

在编写脚本时，常常要确认输入参数是否是期望的：参数个数，参数值（可能包含有人眼不容易发现的空格问题）。

这个脚本输出脚本收到的参数。在控制台运行时，把参数值括起的括号显示成 **红色**，方便人眼查看。

### 示例

```bash
$ ./echo-args.sh 1 "  2 foo  " "3        3"
0/3: [./echo-args.sh]
1/3: [1]
2/3: [  2 foo  ]
3/3: [3        3]
```

### 使用方式

需要查看某个脚本（实际上也可以是其它的可执行程序）输出参数时，可以这么做：

* 把要查看脚本重命名。
* 建一个`echo-args.sh`脚本的符号链接到要查看参数的脚本的位置，名字和查看脚本一样。

这样可以不改其它的程序，查看到输入参数的信息。

:beer: [tcp-connection-state-counter.sh](tcp-connection-state-counter.sh)
----------------------

统计各个`TCP`连接状态的个数。

像`Nginx`、`Apache`的机器上需要查看，`TCP`连接的个数，以判定

- 连接数、负荷
- 是否有攻击，查看`SYN_RECV`数（`SYN`攻击）
- `TIME_WAIT`数，太多会导致`TCP: time wait bucket table overflow`。

### 用法

```bash
tcp-connection-state-counter.sh
```

### 示例

```bash
$ tcp-connection-state-counter.sh
ESTABLISHED	290
TIME_WAIT	212
SYN_SENT	17
```

:beer: [parseOpts.sh](parseOpts.sh)
----------------------

提供命令行选项解析函数`parseOpts`，支持选项的值有多个值（即数组）。  
\# 自己写一个命令行选项解析函数，是因为[`bash`](http://linux.die.net/man/1/bash)的`buildin`命令[`getopts`](http://linux.die.net/man/1/getopts)和加强版本命令[`getopt`](http://linux.die.net/man/1/getopt)都不支持数组的值。

指定选项的多个值（即数组）的风格模仿[`find`](http://linux.die.net/man/1/find)命令的`-exec`选项：

```bash
$ find . -name \*.txt -exec echo "find file: " {} \;
find file: foo.txt
find file: bar.txt
...
```

### 用法

`parseOpts`函数的第一个参数是要解析的选项说明，后面跟实际要解析的输入参数。

选项说明可以长选项和短选项，用逗号分隔，如`a,a-long`。不同选项的说明间用竖号分隔，如`a,a-long|b,b-long:`。

选项说明最后可以有选项类型说明：

- `-`： 无参数的选项。即有选项则把值设置成`true`。这是 ***缺省*** 的类型。
- `:`： 有参数的选项，值只有一个。
- `+`： 有多个参数值的选项。值列表要以`;`表示结束。   
注意，`;`是`Bash`的元字符（用于一行中多个命令分隔），所以加上转义写成`\;`（当然也可以按你的喜好写成`";"`或`';'`）。

实际要解析的输入参数往往是你的脚本参数，这样`parseOpts`函数调用一般是：

```bash
parseOpts "a,a-long|b,b-long:|c,c-long+" "$@"
# "$@" 即是回放你的脚本参数
```

通过约定的全局变量来获取选项和参数：

* 选项名为`a`，通过全局变量`_OPT_VALUE_a`来获取选项的值。
* 选项名为`a-long`，通过全局变量`_OPT_VALUE_a_long`来获取选项的值。  
即，把选项名的`-`转`_`，再加上前缀`_OPT_VALUE_`对应的全局变量来获得选项值。
* 除了选项剩下的参数，通过全局变量`_OPT_ARGS`来获取。

按照惯例，输入参数中如果有`--`表示之后参数中不再有选项，即之后都是参数。

### 示例

```bash
# 导入parseOpts.sh
source /path/to/parseOpts.sh

parseOpts "a,a-long|b,b-long:|c,c-long+" -a -b bv --c-long c.sh -p pv -q qv arg1 \; aa bb cc
# 可以通过下面全局变量来获得解析的参数值：
#	_OPT_VALUE_a = true
#	_OPT_VALUE_a_long = true
#	_OPT_VALUE_b = bv
#	_OPT_VALUE_b_long = bv
#	_OPT_VALUE_c = (c.sh -p pv -q qv arg1) ，数组类型
#	_OPT_VALUE_c_long = (c.sh -p pv -q qv arg1) ，数组类型
#	_OPT_ARGS = (aa bb cc) ，数组类型
```

`--`的使用效果示例：

```bash
# 导入parseOpts.sh
source /path/to/parseOpts.sh

parseOpts "a,a-long|b,b-long:|c,c-long+" -a -b bv -- --c-long c.sh -p pv -q qv arg1 \; aa bb cc
# 可以通过下面全局变量来获得解析的参数值：
#	_OPT_VALUE_a = true
#	_OPT_VALUE_a_long = true
#	_OPT_VALUE_b = bv
#	_OPT_VALUE_b_long = bv
#	_OPT_VALUE_c 没有设置过
#	_OPT_VALUE_c_long 没有设置过
#	_OPT_ARGS = (--c-long c.sh -p pv -q qv arg1 ';' aa bb cc) ，数组类型
```

### 兼容性

这个脚本比较复杂，测试过的环境有：

1. `bash --version`  
`GNU bash, version 4.1.5(1)-release (x86_64-pc-linux-gnu)`  
`uname -a`  
`Linux foo-host 2.6.32-41-generic #94-Ubuntu SMP Fri Jul 6 18:00:34 UTC 2012 x86_64 GNU/Linux`
1. `bash --version`  
`GNU bash, version 3.2.53(1)-release (x86_64-apple-darwin14)`  
`uname -a`   
`Darwin foo-host 14.0.0 Darwin Kernel Version 14.0.0: Fri Sep 19 00:26:44 PDT 2014; root:xnu-2782.1.97~2/RELEASE_X86_64 x86_64 i386 MacBookPro10,1 Darwin`
1. `bash --version`  
`GNU bash, version 3.00.15(1)-release (i386-redhat-linux-gnu)`  
`uname -a`   
`Linux foo-host 2.6.9-103.ELxenU #1 SMP Wed Mar 14 16:31:15 CST 2012 i686 i686 i386 GNU/Linux`

### 贡献者

[Khotyn Huang](https://github.com/khotyn)指出`bash` `3.0`下使用有问题，并提供`bash` `3.0`的测试机器。

:beer: [xpl](xpl) and [xpf](xpf)
----------------------

* `xpl`：在文件浏览器中打开指定的文件或文件夹。  
\# `xpl`是`explorer`的缩写。
* `xpf`: 在文件浏览器中打开指定的文件或文件夹，并选中。   
\# `xpf`是`explorer and select file`的缩写。

### 用法

```bash
xpl
# 缺省打开当前目录
xpl <文件或是目录>...
# 打开多个文件或目录

xpf
# 缺省打开当前目录
xpf <文件或是目录>...
# 打开多个文件或目录
```

### 示例

```bash
xpl /path/to/dir
xpl /path/to/foo.txt
xpl /path/to/dir1 /path/to/foo1.txt
xpf /path/to/foo1.txt
xpf /path/to/dir1 /path/to/foo1.txt
```

### 贡献者

[Linhua Tan](https://github.com/toolchainX)修复Linux的选定Bug。

:key: 下载使用
----------------------

### 下载整个工程的脚本

#### 直接clone工程

使用简单、方便更新，不过要安装有`git`。

```bash
git clone git://github.com/oldratlee/useful-scripts.git

cd useful-scripts

# 使用Release分支的内容
git checkout release

# 更新脚本
git pull
```

包含2个分支：

- `master`：开发分支
- `release`：发布分支，功能稳定的脚本

当然如果你不想安装`git`,`github`是支持`svn`的：

```bash
svn co https://github.com/oldratlee/useful-scripts/branches/release

cd useful-scripts

# 更新脚本
svn up
```

PS：     
我的做法是把`useful-scripts` checkout到`$HOME/bin/useful-scripts`目录下，再把`$HOME/bin/useful-scripts`配置到`PATH`变量上，这样方便我本地使用所有的脚本。

#### 打包下载

下载文件[release.zip](https://github.com/oldratlee/useful-scripts/archive/release.zip)：

```bash
wget --no-check-certificate https://github.com/oldratlee/useful-scripts/archive/release.zip

unzip release.zip
```

### 下载和运行单个文件

以[`show-busy-java-threads.sh`](https://raw.github.com/oldratlee/useful-scripts/release/show-busy-java-threads.sh)为例。

#### `curl`文件直接用`bash`运行

```bash
curl -sLk 'https://raw.github.com/oldratlee/useful-scripts/release/show-busy-java-threads.sh' | bash
```

#### 下载单个文件

```bash
wget --no-check-certificate https://raw.github.com/oldratlee/useful-scripts/release/show-busy-java-threads.sh
chmod +x show-busy-java-threads.sh

./show-busy-java-threads.sh
```
