useful-shells
==================

把平时有用的手动操作做成脚本，这样可以便捷的使用。

有好的脚本 或是 平时常用但没有写成脚本的操作，欢迎[提供](https://github.com/oldratlee/useful-shells/issues)和分享！

下载使用
========================

### 直接clone工程

简单方便，不过要安装有`git`。

```bash
git clone git://github.com/oldratlee/useful-shells.git
# 使用Release分支的内容
git checkout release

# 更新
git pull
```

### 下载单个文件

以[`show-busy-java-threads.sh`](https://raw.github.com/oldratlee/useful-shells/release/show-busy-java-threads.sh)为例：

```bash
wget --no-check-certificate https://raw.github.com/oldratlee/useful-shells/release/show-busy-java-threads.sh
chmod +x show-busy-java-threads.sh
```

### 打包下载

下载文件[release.zip](https://github.com/oldratlee/useful-shells/archive/release.zip)：

```bash
wget --no-check-certificate https://github.com/oldratlee/useful-shells/archive/release.zip
```

show-busy-java-threads.sh
==========================

在排查`Java`的`CPU`性能问题时(`top us`值过高)，要找出`Java`进程中消耗`CPU`多的线程，并查看它的线程栈，从而找出导致性能问题的方法调用。

PS：如何操作可以参见[@bluedavy](http://weibo.com/bluedavy)的《分布式Java应用》的【5.1.1 cpu消耗分析】一节，说得很详细：`top`命令开启线程显示模式、按`CPU`使用率排序、记下Java进程里`CPU`高的线程号；手动转成十六进制（可以用`printf %x 1234`）；jstack，grep十六进制的线程id，找到线程栈。查问题时，会要多次这样操作，太繁琐。

这个脚本的功能是，打印出在运行的`Java`进程中，消耗`CPU`最多的线程栈（缺省是5个线程）。

用法：

```bash
show-busy-java-threads.sh -c <要显示的线程栈数>
# 上面会从所有的Java进程中找出最消耗CPU的线程，这样用更方便。

show-busy-java-threads.sh -c <要显示的线程栈数> -p <指定的Java Process>
```

示例：

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

[silentforce](https://github.com/silentforce)改进此脚本，增加对环境变量`JAVA_HOME`的判断。

cp-svn-url.sh
==========================

拷贝当前`svn`目录对应的远程分支。

用法：

```bash
cp-svn-url.sh # 缺省使用当前目录作为SVN工作目录
cp-svn-url.sh /path/to/svn/work/directory
```

示例：

```bash
$ cp-svn-url.sh
http://www.foo.com/project1/branches/feature1 copied!
```

此脚本由[ivanzhangwb](https://github.com/ivanzhangwb)提供。

参考资料：[拷贝复制命令行输出放在系统剪贴板上](http://oldratlee.com/post/2012-12-23/command-output-to-clip)，给出了不同系统可用命令。

find-in-jars.sh
==========================

在当前目录下所有`Jar`文件里，查找文件名。

用法：

```bash
find-in-jars.sh 'log4j\.properties'
find-in-jars.sh 'log4j\.xml$' -d /path/to/find/directory
find-in-jars.sh log4j\\.xml
find-in-jars.sh 'log4j\.properties|log4j\.xml'
```

注意，后面Pattern是`grep`的扩展正则表达式。

示例：

```bash
$ ./find-in-jars 'Service.class$'
./WEB-INF/libs/spring-2.5.6.SEC03.jar!org/springframework/stereotype/Service.class
./rpc-benchmark-0.0.1-SNAPSHOT.jar!com/taobao/rpc/benchmark/service/HelloService.class
```

参考资料：[在多个Jar(Zip)文件查找Log4J配置文件的Shell命令行](http://oldratlee.com/458/tech/shell/find-file-in-jar-zip-files.html)

echo-args.sh
==============================

在编写脚本时，常常要确认输入参数是否是期望的：参数个数，参数值（可能包含有人眼不容易发现的空格问题）。

这个脚本输出脚本收到的参数。在控制台运行时，把参数值括起的括号显示成 **红色**，方便人眼查看。

示例：

```bash
$ ./echo-args.sh 1 "  2 foo  " "3        3"
0/3: [./echo-args.sh]
1/3: [1]
2/3: [  2 foo  ]
3/3: [3        3]
```

使用方式：

需要查看某个脚本（实际上也可以是其它的可执行程序）输出参数时，可以这么做：

* 把要查看脚本重命名。
* 建一个`echo-args.sh`脚本的符号链接到要查看参数的脚本的位置，名字和查看脚本一样。

这样可以不改其它的程序，查看到输入参数的信息。

xpl and xpf
==============================

* xpl：在文件浏览器中打开指定的文件或文件夹。  
\# xpl是`explorer`的缩写。
* xpf: 在文件浏览器中打开指定的文件或文件夹，并选中。   
\# xpf是`explorer and select file`的缩写。

用法：

```bash
xpl /path/to/dir
xpl /path/to/foo.txt
xpl /path/to/dir1 /path/to/foo1.txt
xpf /path/to/foo1.txt
xpf /path/to/dir1 /path/to/foo1.txt
```
