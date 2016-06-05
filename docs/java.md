:snail: `Java`相关脚本
====================================

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [:beer: show-busy-java-threads.sh](#beer-show-busy-java-threadssh)
    - [用法](#%E7%94%A8%E6%B3%95)
    - [示例](#%E7%A4%BA%E4%BE%8B)
    - [贡献者](#%E8%B4%A1%E7%8C%AE%E8%80%85)
- [:beer: show-duplicate-java-classes](#beer-show-duplicate-java-classes)
    - [用法](#%E7%94%A8%E6%B3%95-1)
        - [`JDK`开发场景使用说明](#jdk%E5%BC%80%E5%8F%91%E5%9C%BA%E6%99%AF%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)
            - [对于一般的工程](#%E5%AF%B9%E4%BA%8E%E4%B8%80%E8%88%AC%E7%9A%84%E5%B7%A5%E7%A8%8B)
            - [对于`Web`工程](#%E5%AF%B9%E4%BA%8Eweb%E5%B7%A5%E7%A8%8B)
        - [`Android`开发场景使用说明](#android%E5%BC%80%E5%8F%91%E5%9C%BA%E6%99%AF%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)
    - [示例](#%E7%A4%BA%E4%BE%8B-1)
    - [贡献者](#%E8%B4%A1%E7%8C%AE%E8%80%85-1)
- [:beer: find-in-jars.sh](#beer-find-in-jarssh)
    - [用法](#%E7%94%A8%E6%B3%95-2)
    - [示例](#%E7%A4%BA%E4%BE%8B-2)
    - [参考资料](#%E5%8F%82%E8%80%83%E8%B5%84%E6%96%99)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

:beer: [show-busy-java-threads.sh](../show-busy-java-threads.sh)
----------------------

用于快速排查`Java`的`CPU`性能问题(`top us`值过高)，自动查出运行的`Java`进程中消耗`CPU`多的线程，并打印出其线程栈，从而确定导致性能问题的方法调用。

PS，如何操作可以参见[@bluedavy](http://weibo.com/bluedavy)的《分布式Java应用》的【5.1.1 cpu消耗分析】一节，说得很详细：

1. `top`命令找出有问题`Java`进程及线程`id`：
    1. 开启线程显示模式
    1. 按`CPU`使用率排序
    1. 记下`Java`进程`id`及其`CPU`高的线程`id`
1. 用进程`id`作为参数，`jstack`有问题的`Java`进程
1. 手动转换线程`id`成十六进制（可以用`printf %x 1234`）
1. 查找十六进制的线程`id`（可以用`grep`）
1. 查看对应的线程栈

查问题时，会要多次这样操作以确定问题，上面过程**太繁琐太慢了**。

### 用法

```bash
show-busy-java-threads.sh
# 从 所有的 Java进程中找出最消耗CPU的线程（缺省5个），打印出其线程栈。

show-busy-java-threads.sh -c <要显示的线程栈数>

show-busy-java-threads.sh -c <要显示的线程栈数> -p <指定的Java Process>

##############################
# 注意：
##############################
# 如果Java进程的用户 与 执行脚本的当前用户 不同，则jstack不了这个Java进程。
# 为了能切换到Java进程的用户，需要加sudo来执行，即可以解决：
sudo show-busy-java-threads.sh
```

### 示例

```bash
$ show-busy-java-threads.sh
[1] Busy(57.0%) thread(23355/0x5b3b) stack of java process(23269) under user(admin):
"pool-1-thread-1" prio=10 tid=0x000000005b5c5000 nid=0x5b3b runnable [0x000000004062c000]
   java.lang.Thread.State: RUNNABLE
    at java.text.DateFormat.format(DateFormat.java:316)
    at com.xxx.foo.services.common.DateFormatUtil.format(DateFormatUtil.java:41)
    at com.xxx.foo.shared.monitor.schedule.AppMonitorDataAvgScheduler.run(AppMonitorDataAvgScheduler.java:127)
    at com.xxx.foo.services.common.utils.AliTimer$2.run(AliTimer.java:128)
    at java.util.concurrent.ThreadPoolExecutor$Worker.runTask(ThreadPoolExecutor.java:886)
    at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:908)
    at java.lang.Thread.run(Thread.java:662)

[2] Busy(26.1%) thread(24018/0x5dd2) stack of java process(23269) under user(admin):
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

- [silentforce](https://github.com/silentforce)改进此脚本，增加对环境变量`JAVA_HOME`的判断。 #15
- [liuyangc3](https://github.com/liuyangc3)
    - 优化性能，通过`read -a`简化反复的`awk`操作 #51
    - 发现并解决`jstack`非当前用户`Java`进程的问题 #50

:beer: [show-duplicate-java-classes](../show-duplicate-java-classes)
----------------------

找出`Java Lib`（`Java`库，即`Jar`文件）或`Class`目录（类目录）中的重复类。

`Java`开发的一个麻烦的问题是`Jar`冲突（即多个版本的`Jar`），或者说重复类。会出`NoSuchMethod`等的问题，还不见得当时出问题。找出有重复类的`Jar`，可以防患未然。

### 用法

- 通过脚本参数指定`Libs`目录，查找目录下`Jar`文件，收集`Jar`文件中`Class`文件以分析重复类。可以指定多个`Libs`目录。  
    注意，只会查找这个目录下`Jar`文件，不会查找子目录下`Jar`文件。因为`Libs`目录一般不会用子目录再放`Jar`，这样也避免把去查找不期望`Jar`。
- 通过`-c`选项指定`Class`目录，直接收集这个目录下的`Class`文件以分析重复类。可以指定多个`Class`目录。

```bash
# 查找当前目录下所有Jar中的重复类
show-duplicate-java-classes

# 查找多个指定目录下所有Jar中的重复类
show-duplicate-java-classes path/to/lib_dir1 /path/to/lib_dir2

# 查找多个指定Class目录下的重复类。 Class目录 通过 -c 选项指定
show-duplicate-java-classes -c path/to/class_dir1 -c /path/to/class_dir2

# 查找指定Class目录和指定目录下所有Jar中的重复类的Jar
show-duplicate-java-classes path/to/lib_dir1 /path/to/lib_dir2 -c path/to/class_dir1 -c path/to/class_dir2
```

#### `JDK`开发场景使用说明

以`Maven`作为构建工程示意过程。

##### 对于一般的工程

```sh
# 在项目模块目录下执行，拷贝依赖Jar到目录target/dependency下
$ mvn dependency:copy-dependencies -DincludeScope=runtime
...
# 检查重复类
$ show-duplicate-java-classes target/dependency
...
```

##### 对于`Web`工程

对于`Web`工程，即`war` `maven`模块，会打包生成`war`文件。

```sh
# 在war模块目录下执行，生成war文件
$ mvn install
...
# 解压war文件，war文件中包含了应用的依赖的Jar文件
$ unzip target/*.war -d target/war
...
# 检查重复类
$ show-duplicate-java-classes -c target/war/WEB-INF/classes target/war/WEB-INF/lib
...
```

#### `Android`开发场景使用说明

`Android`开发，有重复类在编译打包时会报`[Dex Loader] Unable to execute dex: Multiple dex files define Lorg/foo/xxx/Yyy`。

但只会给出一个重复类名，如果重复类比较多时，上面打包/报错/排查会要进行多次，而`Android`的打包比较费时，这个过程比较麻烦，希望可以一次把所有重复类都列出来，一起排查掉。

以`Gradle`作为构建工程示意过程。

在`App`的`build.gradle`中添加拷贝库到目录`build/dependencies`下。

```java
task copyDependencies(type: Copy) {
    def dest = new File(buildDir, "dependencies")

    // clean dir
    dest.deleteDir()
    dest.mkdirs()

    // fill dir with dependencies
    from configurations.compile into dest
}
```

```sh
# 拷贝依赖
$ ./gradlew app:copyDependencies
...
# 检查重复类
$ show-duplicate-java-classes app/build/dependencies
...
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
