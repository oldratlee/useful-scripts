:snail: `Java`相关脚本
====================================

:beer: [show-busy-java-threads.sh](../show-busy-java-threads.sh)
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

:beer: [show-duplicate-java-classes](../show-duplicate-java-classes)
----------------------

找出`java`库（即`jar`文件）或`class`目录中的重复类。

`java`开发的一个麻烦的问题是`jar`冲突（即多个版本的`jar`），或者说重复类。会出`NoSuchMethod`等的问题，还不见得当时出问题。

找出有重复类的`jar`，可以防患未然。

### 用法

```bash
# 查找当前目录下所有Jar中的重复类
show-duplicate-java-classes

# 查找多个指定目录下所有Jar中的重复类
show-duplicate-java-classes path/to/lib_dir1 /path/to/lib_dir2

# 查找多个指定Class目录下的重复类。 Class目录 通过 -c 选项指定
show-duplicate-java-classes -c path/to/class_dir1 -c /path/to/class_dir2

# 查找指定Class目录和指定目录下所有Jar中的重复类的jar
show-duplicate-java-classes path/to/lib_dir1 /path/to/lib_dir2 -c path/to/class_dir1 -c path/to/class_dir2
```

### 示例

```bash
$ show-duplicate-java-classes WEB-INF/lib
COOL! No duplicate classes found!

================================================================================
class paths to find:
================================================================================
1  : WEB-INF/lib/sourceforge.spring.modules.context-2.5.6.SEC02.jar
2  : WEB-INF/lib/misc.htmlparser-0.0.0.jar
3  : WEB-INF/lib/normandy.client-1.0.2.jar
...

$ show-duplicate-java-classes -c WEB-INF/classes WEB-INF/lib
Found duplicate classes in below class path:
1  (293@2): WEB-INF/lib/sourceforge.spring-2.5.6.SEC02.jar WEB-INF/lib/sourceforge.spring.modules.orm-2.5.6.SEC02.jar
2  (2@3): WEB-INF/lib/servlet-api-3.0-alpha-1.jar WEB-INF/lib/jsp-api-2.1-rev-1.jar WEB-INF/lib/jstl-api-1.2-rev-1.jar
3  (104@2): WEB-INF/lib/commons-io-2.2.jar WEB-INF/lib/jakarta.commons.io-2.0.jar
4  (6@3): WEB-INF/lib/jakarta.commons.logging-1.1.jar WEB-INF/lib/commons-logging-1.1.1.jar WEB-INF/lib/org.slf4j.jcl104-over-slf4j-1.5.6.jar
5  (344@2): WEB-INF/lib/sourceforge.spring-2.5.6.SEC02.jar WEB-INF/lib/sourceforge.spring.modules.context-2.5.6.SEC02.jar
...

================================================================================
Duplicate classes detail info:
================================================================================
1  (293@2): WEB-INF/lib/sourceforge.spring-2.5.6.SEC02.jar WEB-INF/lib/sourceforge.spring.modules.orm-2.5.6.SEC02.jar
    1   org/springframework/orm/toplink/TopLinkTemplate$13.class
    2   org/springframework/orm/hibernate3/HibernateTemplate$24.class
    3   org/springframework/orm/jpa/vendor/HibernateJpaDialect.class
    4   org/springframework/orm/hibernate3/TypeDefinitionBean.class
    5   org/springframework/orm/hibernate3/SessionHolder.class
    ...
2  (2@3): WEB-INF/lib/servlet-api-3.0-alpha-1.jar WEB-INF/lib/jsp-api-2.1-rev-1.jar WEB-INF/lib/jstl-api-1.2-rev-1.jar
    1   javax/servlet/ServletException.class
    2   javax/servlet/ServletContext.class
3  (104@2): WEB-INF/lib/commons-io-2.2.jar WEB-INF/lib/jakarta.commons.io-2.0.jar
    1   org/apache/commons/io/input/ProxyReader.class
    2   org/apache/commons/io/output/FileWriterWithEncoding.class
    3   org/apache/commons/io/output/TaggedOutputStream.class
    4   org/apache/commons/io/filefilter/NotFileFilter.class
    5   org/apache/commons/io/filefilter/TrueFileFilter.class
    ...
...

================================================================================
class paths to find:
================================================================================
1  : WEB-INF/lib/sourceforge.spring.modules.context-2.5.6.SEC02.jar
2  : WEB-INF/lib/misc.htmlparser-0.0.0.jar
3  : WEB-INF/lib/normandy.client-1.0.2.jar
4  : WEB-INF/lib/xml.xmlgraphics__batik-css-1.7.jar-1.7.jar
5  : WEB-INF/lib/jakarta.ecs-1.4.2.jar
...
```

### 贡献者

[tgic](https://github.com/tg123)提供此脚本。友情贡献者的链接[commandlinefu.cn](http://commandlinefu.cn/)|[微博linux命令行精选](http://weibo.com/u/2674868673)

:beer: [find-in-jars.sh](../find-in-jars.sh)
----------------------

在当前目录下所有`jar`文件里，查找类或资源文件。

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
