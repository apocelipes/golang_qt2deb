# golang_qt2deb

+ 帮助使用therecipe/qt的golang项目将编译好的目标打包成为deb文件。
+ 支持将desktop files一同打包。
+ 目前配置文件等额外文件需要自行添加仅脚本生成的build目录里，同时需要给脚本加上--nobuild参数。
***
## Example

1. 将$GOPATH/qt_example打包，安装至/usr/bin
>
> ./golang_qt2deb.sh -t $GOPATH/qt_example --prefix /usr/bin
>

2. 将$GOPATH/qt_example打包，安装至默认路径，并一并打包desktop file文件至默认路径。
>
> ./golang_qt2deb.sh -t $GOPATH/qt_example --desktopfile
>

3. 将$GOPATH/qt_example打包，安装至默认路径，并一并打包desktop file文件至指定路径。
>
> ./golang_qt2deb.sh -t $GOPATH/qt_example --desktopfile --dfpath=/usr/local/share/applications
>

4. 将$GOPATH/qt_example打包，安装至默认路径，并一并打包desktop file文件至默认路径，但只生成deb配置和数据，不进行实际进行打包。
>
> ./golang_qt2deb.sh -t $GOPATH/qt_example --desktopfile --nobuild
>
***

## 参数

+ -t/--targer path 指定golang project所在的目录
+ --prefix [path] 指定文件将要安装的路径，默认在/usr/local/bin
+ --desktopfile/--df 一起打包target指定目录中和项目目录同名的.desktop文件
+ --dfpath path 指定.desktop文件将要安装的路径，默认为/usr/share/applications
+ --nobuild 让脚本复制需要的数据并生成control文件，但不进行打包，需要打包额外文件的可以使用此选项然后在现有配置上进行修改
