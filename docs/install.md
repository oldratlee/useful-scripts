🐌 下载使用
====================================

> ❗️ `master`是 不再开发的老版本`1.x`的分支 ❗️
>
> 请切到 [新版本的开发分支](https://github.com/oldratlee/useful-scripts/blob/dev-2.x/docs/install.md)。

----------------------

下载整个工程的脚本
-------------------

### 直接clone工程

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

### 打包下载

下载文件[release.zip](https://github.com/oldratlee/useful-scripts/archive/release.zip)：

```bash
wget --no-check-certificate https://github.com/oldratlee/useful-scripts/archive/release.zip

unzip release.zip
```

下载和运行单个文件
-------------------

以[`show-busy-java-threads`](https://raw.github.com/oldratlee/useful-scripts/release/show-busy-java-threads)为例。

### `curl`文件直接用`bash`运行

```bash
curl -sLk 'https://raw.github.com/oldratlee/useful-scripts/release/show-busy-java-threads' | bash
```

### 下载单个文件

```bash
wget --no-check-certificate https://raw.github.com/oldratlee/useful-scripts/release/show-busy-java-threads
chmod +x show-busy-java-threads

./show-busy-java-threads
```
