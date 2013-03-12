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
	at java.lang.Thread.run(Thread.java:662)

The stack of busy(0.4%) thread(24021/0x5dd5) of java process(23269) of user(admin):
"pool-1-thread-5" prio=10 tid=0x000000005bc1c000 nid=0x5dd5 waiting on condition [0x000000004149e000]
   java.lang.Thread.State: WAITING (parking)
	at sun.misc.Unsafe.park(Native Method)
	- parking to wait for  <0x0000000793e77408> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)
	at java.util.concurrent.locks.LockSupport.park(LockSupport.java:158)
	at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:1987)
	at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:399)
	at java.util.concurrent.ThreadPoolExecutor.getTask(ThreadPoolExecutor.java:947)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:907)
	at java.lang.Thread.run(Thread.java:662)
	
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

PS
================

有好的脚本 或是 平时常用但没有写成脚本的操作 欢迎大家提供~ 可以放到一起来分享！