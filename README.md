# <div align="center"><a href="#dummy"><img src="docs/logo.png" alt="🐌 useful-scripts"></a></div>

<img src="docs/script-logo.png" alt="repo-icon" width="20%" align="right" />

<p align="center">
<a href="https://travis-ci.com/github/oldratlee/useful-scripts"><img src="https://img.shields.io/travis/com/oldratlee/useful-scripts/dev-2.x?logo=travis-ci&logoColor=white" alt="Build Status"></a>
<a href="https://github.com/oldratlee/useful-scripts/releases"><img src="https://img.shields.io/github/release/oldratlee/useful-scripts.svg" alt="GitHub release"></a>
<a href="https://www.apache.org/licenses/LICENSE-2.0.html"><img src="https://img.shields.io/github/license/oldratlee/useful-scripts?color=4D7A97&logo=apache" alt="License"></a>
<a href="https://gitter.im/oldratlee/useful-scripts?utm_source=badge&amp;utm_medium=badge&amp;utm_campaign=pr-badge&utm_content=badge"><img src="https://img.shields.io/gitter/room/oldratlee/useful-scripts?color=46BC99&logo=gitter&logoColor=white" alt="Chat at gitter.im"></a>
<a href="https://github.com/oldratlee/useful-scripts/stargazers"><img src="https://img.shields.io/github/stars/oldratlee/useful-scripts" alt="GitHub Stars"></a>
<a href="https://github.com/oldratlee/useful-scripts/fork"><img src="https://img.shields.io/github/forks/oldratlee/useful-scripts" alt="GitHub Forks"></a>
<a href="https://github.com/oldratlee/useful-scripts/issues"><img src="https://img.shields.io/github/issues/oldratlee/useful-scripts" alt="GitHub issues"></a>
<a href="https://github.com/oldratlee/useful-scripts/graphs/contributors"><img src="https://img.shields.io/github/contributors/oldratlee/useful-scripts" alt="GitHub Contributors"></a>
<a href="https://github.com/oldratlee/useful-scripts"><img src="https://img.shields.io/github/repo-size/oldratlee/useful-scripts" alt="GitHub repo size"></a>
</p>

🐌 useful scripts for making developer's everyday life easier and happier, involved java, shell etc.  
👉 平时有用的手动操作做成脚本，以便捷地使用，让开发的日常生活更轻松些。 💕

欢迎 👏 💖

- 提问，[提交 Issue](https://github.com/oldratlee/useful-scripts/issues/new)
- 分享平时自己常用但没有写成脚本的功能（即需求、想法），[提交Issue](https://github.com/oldratlee/useful-scripts/issues/new)
- 优化改进，[Fork 后提通过 Pull Request 贡献代码](https://github.com/oldratlee/useful-scripts/fork)
- 提供的自己好用脚本实现，[Fork 后提通过 Pull Request 提供](https://github.com/oldratlee/useful-scripts/fork)

本仓库的脚本（如`Java`相关脚本）在阿里等公司（如随身云，见[`awesome-scripts`仓库](https://github.com/Suishenyun/awesome-scripts)说明）的线上生产环境部署使用。

如果你的公司有部署使用，欢迎使用通过 [Issue：who's using | 用户反馈收集](https://github.com/oldratlee/useful-scripts/issues/96) 告知，方便互相交流反馈～ 💘

----------------------

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [🔰 快速下载&使用](#-%E5%BF%AB%E9%80%9F%E4%B8%8B%E8%BD%BD%E4%BD%BF%E7%94%A8)
- [📚 使用文档](#-%E4%BD%BF%E7%94%A8%E6%96%87%E6%A1%A3)
    - [☕ `Java`相关脚本](#-java%E7%9B%B8%E5%85%B3%E8%84%9A%E6%9C%AC)
    - [🐚 `Shell`相关脚本](#-shell%E7%9B%B8%E5%85%B3%E8%84%9A%E6%9C%AC)
    - [⌚ `VCS`相关脚本](#-vcs%E7%9B%B8%E5%85%B3%E8%84%9A%E6%9C%AC)
- [🎓 Developer Guide](#-developer-guide)
    - [🎯 面向开发者的目标](#-%E9%9D%A2%E5%90%91%E5%BC%80%E5%8F%91%E8%80%85%E7%9A%84%E7%9B%AE%E6%A0%87)
        - [关于`Shell`脚本](#%E5%85%B3%E4%BA%8Eshell%E8%84%9A%E6%9C%AC)
    - [🚦 开发约定](#-%E5%BC%80%E5%8F%91%E7%BA%A6%E5%AE%9A)
    - [📚 `Shell`学习与开发的资料](#-shell%E5%AD%A6%E4%B9%A0%E4%B8%8E%E5%BC%80%E5%8F%91%E7%9A%84%E8%B5%84%E6%96%99)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

----------------------

🔰 快速下载&使用
----------------------

```bash
source <(curl -fsSL https://raw.githubusercontent.com/oldratlee/useful-scripts/release-2.x/test-cases/self-installer.sh)
```

更多下载&使用方式，参见[下载使用](docs/install.md)。

📚 使用文档
----------------------

### ☕ [`Java`相关脚本](docs/java.md)

1. [show-busy-java-threads](docs/java.md#-show-busy-java-threads)  
    用于快速排查`Java`的`CPU`性能问题(`top us`值过高)，自动查出运行的`Java`进程中消耗`CPU`多的线程，并打印出其线程栈，从而确定导致性能问题的方法调用。
1. [show-duplicate-java-classes](docs/java.md#-show-duplicate-java-classes)  
    找出`jar`文件和`class`目录中的重复类。用于排查`Java`类冲突问题。
1. [find-in-jars](docs/java.md#-find-in-jars)  
    在目录下所有`jar`文件里，查找类或资源文件。

### 🐚 [`Shell`相关脚本](docs/shell.md)

`Shell`使用加强：

1. [c](docs/shell.md#-c)  
    原样命令行输出，并拷贝标准输出到系统剪贴板，省去`CTRL+C`操作，优化命令行与其它应用之间的操作流。
1. [coat](docs/shell.md#-coat)  
    彩色`cat`出文件行，方便人眼区分不同的行。
1. [a2l](docs/shell.md#-a2l)  
    按行彩色输出参数，方便人眼查看。
1. [uq](docs/shell.md#-uq)  
    不重排序输入完成整个输入行的去重。相比系统的`uniq`命令加强的是可以跨行去重，不需要排序输入。
1. [ap and rp](docs/shell.md#-ap-and-rp)  
    批量转换文件路径为绝对路径/相对路径，会自动跟踪链接并规范化路径。
1. [cp-into-docker-run](docs/shell.md#-cp-into-docker-run)  
    一个`Docker`使用的便利脚本。拷贝本机的执行文件到指定的`docker container`中并在`docker container`中执行。
1. [tcp-connection-state-counter](docs/shell.md#-tcp-connection-state-counter)  
    统计各个`TCP`连接状态的个数。用于方便排查系统连接负荷问题。
1. [xpl and xpf](docs/shell.md#-xpl-and-xpf)  
    在命令行中快速完成 在文件浏览器中 打开/选中 指定的文件或文件夹的操作，优化命令行与其它应用之间的操作流。

`Shell`开发/测试加强：

1. [echo-args](docs/shell.md#-echo-args)  
    输出脚本收到的参数，在控制台运行时，把参数值括起的括号显示成 **红色**，方便人眼查看。用于调试脚本参数输入。
1. [console-text-color-themes.sh](docs/shell.md#-console-text-color-themessh)  
    显示`Terminator`的全部文字彩色组合的效果及其打印方式，用于开发`Shell`的彩色输出。
1. [parseOpts.sh](docs/shell.md#-parseoptssh)  
    命令行选项解析库，加强支持选项有多个值（即数组）。

### ⌚ [`VCS`相关脚本](docs/vcs.md)

目前`VCS`的脚本都是`svn`分支相关的操作。使用更现代的`Git`吧！ 💥

因为不推荐使用`svn`，这里不再列出有哪些脚本了，如果你有兴趣可以点上面链接去看。

## 🎓 Developer Guide

为用户提供有用的功能，当然是这个库的首要的价值体现和存在理由。

但作为一个**开源**项目，每个人都可以看到源码实现，这个库或许能做得更多。

### 🎯 面向开发者的目标

- 将`Shell/Bash`作为线上生产环境使用的专业编程语言。
- 期望体现`Shell/Bash`脚本 生产环境级的严谨开发方式与最佳实践，进而有可能示例与改善在生产环境中`Shell`脚本的质量状况。

PS：

- 虽然上面是自己期望的目标，但自己在`Shell`语言上一定会有很多理解和使用上的问题、在这些实现脚本中也会很多需要的改进，可以一起学习、讨论与实践～ 💕
- 这个库中脚本的实现也有使用`Python`。

#### 关于`Shell`脚本

命令行（`CLI`）几乎是每个程序员每天都在使用的工具。相比图形界面工具（`GUI`），命令行有着自己不可替代的便利性和优越性。

命令行里写出来其实就是`Shell`脚本，可以说每个开发者会写`Shell`脚本（或多或少）。在生产环境的功能实现中，也常会看到`Shell`脚本（虽然不如主流语言那么常见）。

可能正因为上面所说的`Shell`脚本的便利性和大众性：

- `Shell`脚本有不少是顺手实现的（包括生产环境用的`Shell`脚本）；
- `Shell`脚本的实现常常可能质量不高，会引发线上严重的故障。

### 🚦 开发约定

在这个库中的`Shell`脚本：

- 统一使用`Bash 3+`；
- 面向生产环境，尽可能使用严谨安全的开发方式。

`Shell`用`Bash`的原因是：

- 目前仍然是主流的`Shell`，并且在不同环境基本上都缺省部署了。
- 在[`Google`的`Shell`风格指南](https://zh-google-styleguide.readthedocs.io/en/latest/google-shell-styleguide/background/)中，明确说明了：`Bash`是**唯一**被允许执行的`shell`脚本语言。
    - 有大量的`Shell`实现，`sh`、`bash`、`zsh`、`fish`、`csh`、`tcsh`、`ksh`、`ash`、`dash`……
    - 不同的`Shell`有各种差异，深坑勿入。
    - 统一用`Bash`，可以避免差异带来的风险与没有收益的复杂性。
- 个人系统学习过的是`Bash`，比较理解熟悉。

PS: 虽然交互`Shell`个人已经使用`Zsh` + [`oh-my-zsh`](https://ohmyz.sh/)，但在严谨的`Shell`脚本开发时还是使用`Bash`。

### 📚 `Shell`学习与开发的资料

> 更多资料参见 [子文档](docs/developer-guide.md)。

- 👷 **`Bash/Shell`最佳实践与安全编程**
    - [**_`Google Shell Style Guide`_**](https://google.github.io/styleguide/shell.xml) | [中文版](https://zh-google-styleguide.readthedocs.io/en/latest/google-shell-styleguide/background/)
    - [`koalaman/shellcheck`](https://github.com/koalaman/shellcheck): ShellCheck, a static analysis tool for shell scripts
    - [Use the Unofficial Bash Strict Mode (Unless You Looove Debugging)](http://redsymbol.net/articles/unofficial-bash-strict-mode/)
    - Bash Pitfalls: 编程易犯的错误 - 团子的小窝：[Part 1](http://kodango.com/bash-pitfalls-part-1) | [Part 2](http://kodango.com/bash-pitfalls-part-2) | [Part 3](http://kodango.com/bash-pitfalls-part-3) | [Part 4](http://kodango.com/bash-pitfalls-part-4)
    - [不要自己去指定sh的方式去执行脚本](https://github.com/oldratlee/useful-scripts/issues/57#issuecomment-326485965)
- 🎶 **Tips**
    - [让你提升命令行效率的 Bash 快捷键 【完整版】](https://linuxtoy.org/archives/bash-shortcuts.html)  
        补充：`ctrl + x, ctrl + e` 就地打开文本编辑器来编辑当前命令行，对于复杂命令行特别有用
    - [应该知道的Linux技巧 | 酷 壳 - CoolShell](https://coolshell.cn/articles/8883.html)
    - 简洁的 Bash Programming 技巧 - 团子的小窝：[Part 1](http://kodango.com/simple-bash-programming-skills) | [Part 2](http://kodango.com/simple-bash-programming-skills-2) | [Part 3](http://kodango.com/simple-bash-programming-skills-3)
- 💎 **系统学习**  
    看文章、了解Tips完全不能替代系统学习才能真正理解并专业开发！
    - [《Bash Pocket Reference》](https://book.douban.com/subject/26738258/)  
        力荐！说明简单直接结构体系的佳作，专业`Bash`编程必备！且16年的第二版更新到了新版的`Bash 4`
    - [《学习bash》](https://book.douban.com/subject/1241361/) 上面那本的展开版
    - 官方资料
        - [`bash man`](https://linux.die.net/man/1/bash) | [中文版](http://ahei.info/chinese-bash-man.htm)
        - [Bash Reference Manual - gnu.org](http://www.gnu.org/software/bash/manual/) | [中文版](https://yiyibooks.cn/Phiix/bash_reference_manual/bash%E5%8F%82%E8%80%83%E6%96%87%E6%A1%A3.html)  
        Bash参考手册，讲得全面且有深度，比如会全面地讲解不同转义的区别、命令的解析过程，这有助统一深入的方式认识Bash整个执行方式和过程。这些内容在其它书中往往不会讲（因为复杂难于深入浅出的讲解），但却一通百通的关键。
    - [命令行的艺术 - `jlevy/the-art-of-command-line`](https://github.com/jlevy/the-art-of-command-line/blob/master/README-zh.md)
    - [`alebcay/awesome-shell`](https://github.com/alebcay/awesome-shell): A curated list of awesome command-line frameworks, toolkits, guides and gizmos.
    - 更多书籍参见个人整理的[书籍豆列 **_`Bash/Shell`_**](https://www.douban.com/doulist/1779379/)
