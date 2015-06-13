:snail: `VCS`相关脚本
====================================

:beer: [swtrunk.sh](../swtrunk.sh)
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

:beer: [svn-merge-stop-on-copy.sh](../svn-merge-stop-on-copy.sh)
----------------------

把指定的远程分支从刚新建分支以来的修改合并到本地`svn`目录或是另一个远程分支。

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

:beer: [cp-svn-url.sh](../cp-svn-url.sh)
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
