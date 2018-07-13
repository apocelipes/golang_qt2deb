#!/bin/bash
# 用于生成golang-Qt项目的deb包（github.com/therecipe/qt）
# 目前只适用于linux
# 欢迎PR
# usage：./golang_qt2deb.sh -t [path/to/your/project] --prefix=[INSTALL/PATH]
# ./golang_qt2deb.sh --target=[project] --prefix=[install path] --desktopfile [--dfpath=[path]]
# 详见README.md
# project需要在gopath中
# install path是程序安装的目录，默认为/usr/local/bin

# parses args
ARGS=`getopt -o t: --long nobuild,prefix::,desktopfile,df,dfpath:: -n 'golang_qt2deb.sh' -- "$@"`
if [[ $? != 0 ]]; then
	echo "参数解析错误"
	exit 1
fi
eval set -- "$ARGS"

prefix="usr/local/bin"
dfpath="usr/share/applications"
usedf=1
nobuild=0
# target system
system=linux
targetpath=deploy/$system

while true; do
	case $1 in
		-t|--target )
			project=$2
			appname=`basename $2`
			appbin=${appname}_bin
			shift 2
			;;
		--nobuild )
			nobuild=1
			shift
			;;
		--prefix )
			case $2 in
				"" )
					prefix="usr/local/bin"
					;;
				* )
					prefix=$2
					;;
			esac
			shift 2
			;;
		--desktopfile|--df )
			usedf=0
			shift
			;;
		--dfpath )
			case $2 in
				"" )
					dfpath="usr/share/applications"
					;;
				* )
					dfpath=$2
					;;
			esac
			shift 2
			;;
		-- )
			shift
			break
			;;
		* )
			echo "无效的参数"
			exit 1
			;;
	esac
done

function copy2deb {
	echo "复制需要的文件中..."
	mkdir build
	cd build
	mkdir DEBIAN
	if [[ $usedf != 1 ]] && [[ -e ../${appname}.desktop ]]; then
		mkdir -p $dfpath
		cp ../${appname}.desktop $dfpath/
	fi
	mkdir -p $prefix/$appbin
	if [ -e ../$targetpath ]; then
		cp -r ../$targetpath/lib $prefix/$appbin/lib
		cp -r ../$targetpath/plugins $prefix/$appbin/plugins
		cp -r ../$targetpath/qml $prefix/$appbin/qml
		cp ../$targetpath/$appname $prefix/$appbin/$appname
	else
		echo "找不到编译好的目标"
		exit 1
	fi
}

function setcontrol {
	# set some package's config
	read -p "package name (${appname}): " package
	# 用全局变量保存package，后续的genpackage会用到该变量
	package=${package:-${appname}}
	read -p 'version (1.0): ' version
	read -p 'section (x11): ' section
	read -p 'depends (none): ' depends
	read -p 'suggests (none): ' suggests
	read -p 'architecture (amd64): ' architecture
	read -p "maintainer (${USER}): " maintainer
	read -p 'description (none): ' description

	# gen control
	cat > DEBIAN/control <<EOF
Package: ${package}
Version: ${version:-1.0}
Section: ${section:-x11}
Depends: ${depends:-}
Suggests: ${suggests:-}
Architecture: ${architecture:-amd64}
Maintainer: ${maintainer:-${USER}}
Description: ${description:-' '}
EOF
}

function genscript {
	echo '#!/bin/bash' >> $prefix/$appname
	echo 'app=`basename $0`' >> $prefix/$appname
	echo 'appdir=`dirname $0`/${app}_bin' >> $prefix/$appname
	echo >> $prefix/$appname
	echo 'export LD_LIBRARY_PATH=$appdir/lib' >> $prefix/$appname
	echo 'export QT_PLUGIN_PATH=$appdir/plugins' >> $prefix/$appname
	echo 'export QML_IMPORT_PATH=$appdir/qml' >> $prefix/$appname
	echo 'export QML2_IMPORT_PATH=$appdir/qml' >> $prefix/$appname
	echo '$appdir/$app "$@"' >> $prefix/$appname

	chmod +x $prefix/$appname
}

function genpackage {
	sudo dpkg -b . ${package}.deb
}

if [[ -e ${project:-' '} ]] && cd $project; then
	copy2deb
	setcontrol
	genscript
	if [[ ${nobuild} != "1" ]]; then
		genpackage
	else
		echo "仅生成deb配置"
	fi
else
	echo "无法进入或目录不存在 ${1}"
	exit 1
fi
