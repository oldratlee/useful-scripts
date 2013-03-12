useful-shells
==================

把平时有用的手动操作做成脚本，这样可以便捷的使用。

show-busy-java-threads.sh
==========================

在排查`Java`的`CPU`性能问题时，需要找到消耗`CPU`的线程，查看它的线程栈。

这个脚本的功能是，打印出在运行的`Java`进程中，消耗`CPU`最多的那5个线程的线程栈。  

示例：

```bash
$ ./show-busy-java-threads.sh 
The stack of busy(0.0%) thread(30509/0x772d) of java process(29213) of user(foo):
"Attach Listener" daemon prio=10 tid=0x0000000042171800 nid=0x772d waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

The stack of busy(0.0%) thread(29230/0x722e) of java process(29213) of user(foo):
"GC Daemon" daemon prio=10 tid=0x00007f21340ec800 nid=0x722e in Object.wait() [0x00007f2133ae3000]
   java.lang.Thread.State: TIMED_WAITING (on object monitor)
	at java.lang.Object.wait(Native Method)
	- waiting on <0x00000000a0000120> (a sun.misc.GC$LatencyLock)
	at sun.misc.GC$Daemon.run(GC.java:100)
	- locked <0x00000000a0000120> (a sun.misc.GC$LatencyLock)
	
	...
```


find-in-jars.sh
==========================

在当前目录下所有`Jar`文件里，查找文件名。

用法：

```bash
find-in-jars.sh 'sofa\.properties'
find-in-jars.sh log4j\\.xml
find-in-jars.sh 'log4j\.properties|log4j\.xml'
```

注意，后面Pattern是`grep`的扩展正则表达式。

示例：

```bash
$ ./find-in-jars '*Service.class'
./spring-2.5.6.SEC03.jar!org/springframework/stereotype/Service.class
./rpc-benchmark-0.0.1-SNAPSHOT.jar!com/taobao/rpc/benchmark/service/HelloService.class
```

说明详见：[在多个Jar(Zip)文件查找Log4J配置文件的Shell命令行](http://oldratlee.com/458/tech/shell/find-file-in-jar-zip-files.html)
