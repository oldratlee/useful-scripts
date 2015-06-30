:snail: useful-scripts
====================================

把平时有用的手动操作做成脚本，这样可以便捷的使用。 :sparkles:

有自己用的好的脚本 或是 平时常用但没有写成脚本的功能，欢迎提供（[提交Issue](https://github.com/oldratlee/useful-scripts/issues))和分享（[Fork后提交代码](https://github.com/oldratlee/useful-scripts/fork)）！ :sparkling_heart:

:beginner: 快速下载&使用
----------------------

```bash
source <(curl -fsSL https://raw.githubusercontent.com/oldratlee/useful-scripts/master/test-cases/self-installer.sh)
```

更多下载&使用方式，参见[下载使用](docs/install.md)。

:books: 使用文档
----------------------

### :coffee: [`Java`相关脚本](docs/java.md)

1. [show-busy-java-threads.sh](docs/java.md#beer-show-busy-java-threadssh)  
    打印出在运行的`Java`进程中，消耗`CPU`最多的线程栈。用于快速排查`Java`的性能问题。
1. [show-duplicate-java-classes](docs/java.md#beer-show-duplicate-java-classes)  
    找出`jar`文件和`class`目录中的重复类。用于排查`Java`类冲突问题。
1. [find-in-jars.sh](docs/java.md#beer-find-in-jarssh)  
    在目录下所有`jar`文件里，查找类或资源文件。

### :watch: [`VCS`相关脚本](docs/vcs.md)

1. [swtrunk.sh](docs/vcs.md#beer-swtrunksh)  
    自动`svn`工作目录从分支（`branches`）切换到主干（`trunk`）。
1. [svn-merge-stop-on-copy.sh](docs/vcs.md#beer-svn-merge-stop-on-copysh)    
    把指定的远程分支从刚新建分支以来的修改合并到本地`svn`目录或是另一个远程分支。
1. [cp-svn-url.sh](docs/vcs.md#beer-cp-svn-urlsh)  
    拷贝当前`svn`目录对应的远程分支到系统的粘贴板，省去`CTRL+C`操作。

### :shell: [`Shell`相关脚本](docs/shell.md)

包含`Shell`使用或命令加强的脚本。

1. [c](docs/shell.md#beer-c)  
    原样命令行输出，并拷贝标准输出到系统剪贴板，省去`CTRL+C`，`CTRL+V`操作。
1. [colines](docs/shell.md#beer-colines)  
    彩色`cat`出文件行，方便人眼区分不同的行。
1. [a2l](docs/shell.md#beer-a2l)  
    按行彩色输出参数，方便人眼查看。
1. [echo-args.sh](docs/shell.md#beer-echo-argssh)    
    输出脚本收到的参数，在控制台运行时，把参数值括起的括号显示成 **红色**，方便人眼查看。用于调试脚本参数输入。
1. [console-text-color-themes.sh](docs/shell.md#beer-console-text-color-themessh)  
    显示`Terminator`的全部文字彩色组合的效果及其打印方式。
1. [tcp-connection-state-counter.sh](docs/shell.md#beer-tcp-connection-state-countersh)   
    统计各个`TCP`连接状态的个数。用于方便排查系统连接负荷问题。
1. [parseOpts.sh](docs/shell.md#beer-parseoptssh)   
    提供命令行选项解析函数`parseOpts`，支持选项的值有多个值（即数组）。
1. [xpl and xpf](docs/shell.md#beer-xpl-and-xpf)    
    在文件浏览器中 打开/选中 指定的文件或文件夹。
