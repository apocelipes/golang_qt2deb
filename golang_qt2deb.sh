#!/bin/bash
# 用于生成golang-Qt项目的deb包（github.com/therecipe/qt）
# 目前只适用于linux
# 欢迎PR
# usage：bash makedeb.sh [path/to/your/project] [INSTALL/PATH]
# project需要在gopath中
# install path是程序安装的目录，默认为/usr/local/bin

appname=`basename $1`
appbin=${appname}_bin
prefix=${2:-usr/local/bin}
# target system
system=linux
targetpath=deploy/$system

echo ../$targetpath/$appname

function copy2deb {
	mkdir build
	cd build
	mkdir DEBIAN
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
	cat >> DEBIAN/control <<EOF
Package: ${package}
Version: ${version:-1.0}
Section: ${section:-x11}
Depends: ${depends:-}
Suggests: ${suggests:-}
Architecture: ${architecture:-amd64}
Maintainer: ${maintainer:-${USER}}
Description: ${description:-}
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

if cd $1; then
	copy2deb
	setcontrol
	genscript
	genpackage
else
	echo "无法进入目录 ${1}"
	exit 1
fi

