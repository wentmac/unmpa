#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# check root  #
if [ $(id -u) != "0" ]; then
	echo "Error:please use root to install lnmpa"
	exit 1
fi

clear
echo "========================================================================="
echo "LNMPA V1.0 for Ubuntu VPS ,  Written by Licess "
echo "========================================================================="
echo "A tool to auto-compile & install Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://www.t-mac.org/"
echo "========================================================================="
#current directory#
current_dir=$(pwd)
#input mysql root passwd#
	mysql_root_pwd="root"
	echo "please input the root password of mysql:"
	read -p "(Default password: root):" mysql_root_pwd
	if [ "$mysql_root_pwd" = "" ]; then
		mysql_root_pwd="root"
	fi
	echo "================================="
	echo "mysql root passwd=$mysql_root_pwd"
	echo "================================="

#which nginx port do you want use?#
echo "================================="
	nginx_port="80"
	echo "please choose nginx port"
	read -p "(Default 80    1:80,2:8080):" nginx_port
	
	case $nginx_port in
	1)
		nginx_port="80"
		echo "you will use port 80 for nginx"
	;;
	2)
		nginx_port="8080"
		echo "you will use port 8080 for nginx"
	;;
	*)
        nginx_port="80"
		echo "input error,nigix will use port 80"
	esac

function ChooseApachePort()
{
#which apache2 port do you want use?#
echo "================================="
        echo "please choose apache port"
        read -p "(Default 8080    1:80,2:8080,3:8081):" apache_port

        case $apache_port in
        1)
                apache_port="80"
        ;;
        2)
                apache_port="8080"
        ;;
        3)
                apache_port="8081"
        ;;
        *)
                apache_port="8080"
                echo "input error,apache will use port 8080"
        esac
}

#do you want install apache2?
echo "================================="
	apache_install="y"
	echo "do you want install apache2?"
	read -p "(please input y or n):" apache_install

	case $apache_install in
	y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
		echo "You will install apache2"
		apache_install="y"			        
		ChooseApachePort
	;;
	n|N|No|NO|no|nO)
		echo "You will without install apache2"
		apache_install="n"
	;;
	*)
		echo "INPUT error,You will install apache2"
		apache_install="y"	        
		ChooseApachePort
	esac

echo "================================="
	mysql_install="y"
	echo "do you want install mysql?"
	read -p "(please input y or n or mysql_dir):" mysql_install

	case $mysql_install in
	y|Y|Yes|YES|yes|yES|yEs|YeS|yeS|"")
		echo "You will install mysql"
		mysql_install="y"		
	;;   
	n|N|No|NO|no|nO)
		echo "You will without install mysql"
		mysql_install="n"
	;;	
	*)
		echo "You will not use mysql ${mysql_install}"
		mysql_prefix=${mysql_install}
        if [ ! -s ${mysql_prefix} ]; then
            echo "${mysql_prefix}安装目录不存在"
            exit 1
        fi
        mysql_install="n"        
	esac
    
function CheckFileExist()
{
if [ -s $1 ]; then
	return 0 
else
	wget $2 -O $1
fi

if [ ! -s $1 ]; then
	echo "Error: $1 not found!!!"
	exit 1
else
	return 0
fi
}

function DownloadSourceCode()
{
cd $source_dir
#download mysql source code#
##CheckFileExist mysql-5.5.34.tar.gz http://mysql.mirrors.pair.com/Downloads/MySQL-5.5/mysql-5.5.34.tar.gz
CheckFileExist mysql-5.5.34.tar.gz http://mirrors.weixinshow.com/unmpa_source/mysql-5.5.34.tar.gz
#php depend code#
##CheckFileExist libiconv-1.14.tar.gz http://ftp.gnu.org/gnu/libiconv/libiconv-1.14.tar.gz
CheckFileExist libiconv-1.14.tar.gz http://mirrors.weixinshow.com/unmpa_source/libiconv-1.14.tar.gz
##CheckFileExist libmcrypt-2.5.8.tar.gz http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
CheckFileExist libmcrypt-2.5.8.tar.gz http://mirrors.weixinshow.com/unmpa_source/libmcrypt-2.5.8.tar.gz
#CheckFileExist mhash-0.9.9.9.tar.gz http://downloads.sourceforge.net/project/mhash/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz
CheckFileExist mhash-0.9.9.9.tar.gz http://mirrors.weixinshow.com/unmpa_source/mhash-0.9.9.9.tar.gz
#CheckFileExist mcrypt-2.6.8.tar.gz http://downloads.sourceforge.net/project/mcrypt/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz
CheckFileExist mcrypt-2.6.8.tar.gz http://mirrors.weixinshow.com/unmpa_source/mcrypt-2.6.8.tar.gz
CheckFileExist freetype-2.4.0.tar.gz http://download.savannah.gnu.org/releases/freetype/freetype-2.4.0.tar.gz
#CheckFileExist php-5.4.20.tar.gz http://www.php.net/get/php-5.4.20.tar.gz/from/kr1.php.net/mirror
CheckFileExist php-5.4.20.tar.gz http://mirrors.weixinshow.com/unmpa_source/php-5.4.20.tar.gz
#php extend code#
##CheckFileExist autoconf-2.68.tar.gz http://ftp.gnu.org/gnu/autoconf/autoconf-2.68.tar.gz
CheckFileExist autoconf-2.68.tar.gz http://mirrors.weixinshow.com/unmpa_source/autoconf-2.68.tar.gz
##CheckFileExist memcache-3.0.8.tgz http://pecl.php.net/get/memcache-3.0.8.tgz
CheckFileExist memcache-3.0.8.tgz http://mirrors.weixinshow.com/unmpa_source/memcache-3.0.8.tgz
#CheckFileExist memcached-2.1.0.tgz http://pecl.php.net/get/memcached-2.1.0.tgz
CheckFileExist memcached-2.1.0.tgz http://mirrors.weixinshow.com/unmpa_source/memcached-2.1.0.tgz
#CheckFileExist libmemcached-1.0.17.tar.gz https://launchpad.net/libmemcached/1.0/1.0.17/+download/libmemcached-1.0.17.tar.gz
CheckFileExist libmemcached-1.0.16.tar.gz http://mirrors.weixinshow.com/unmpa_source/libmemcached-1.0.16.tar.gz
#CheckFileExist eaccelerator.tar.gz https://github.com/eaccelerator/eaccelerator/tarball/master
CheckFileExist eaccelerator.tar.gz http://mirrors.weixinshow.com/unmpa_source/eaccelerator.tar.gz
#CheckFileExist ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz http://downloads.zend.com/guard/6.0.0/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
CheckFileExist zendopcache-7.0.4.tgz http://pecl.php.net/get/zendopcache-7.0.4.tgz
#32位 http://downloads.zend.com/guard/6.0.0/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
    CheckFileExist ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz http://mirrors.weixinshow.com/unmpa_source/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
    ZendGuardLoader_name='ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64'
else
    CheckFileExist ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz http://mirrors.weixinshow.com/unmpa_source/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
    ZendGuardLoader_name='ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386'
fi
#CheckFileExist ImageMagick-6.8.7-6.tar.gz https://launchpad.net/imagemagick/main/6.8.7-6/+download/ImageMagick-6.8.7-6.tar.gz
CheckFileExist ImageMagick-6.8.7-6.tar.gz http://mirrors.weixinshow.com/unmpa_source/ImageMagick-6.8.7-6.tar.gz
#CheckFileExist imagick-3.1.2.tgz http://pecl.php.net/get/imagick-3.1.2.tgz
CheckFileExist imagick-3.1.2.tgz http://mirrors.weixinshow.com/unmpa_source/imagick-3.1.2.tgz

#nginx#
#CheckFileExist pcre-8.32.tar.gz http://downloads.sourceforge.net/project/pcre/pcre/8.32/pcre-8.32.tar.gz?r=&ts=1382697256&use_mirror=hivelocity
CheckFileExist pcre-8.32.tar.gz http://mirrors.weixinshow.com/unmpa_source/pcre-8.32.tar.gz
#CheckFileExist nginx-1.5.6.tar.gz http://nginx.org/download/nginx-1.5.6.tar.gz
CheckFileExist nginx-1.5.6.tar.gz http://mirrors.weixinshow.com/unmpa_source/nginx-1.5.6.tar.gz
CheckFileExist init.d.nginx http://mirrors.weixinshow.com/unmpa_source/init.d.nginx
#apache2#
#CheckFileExist apr-1.4.8.tar.gz http://mirror.esocc.com/apache/apr/apr-1.4.8.tar.gz
CheckFileExist apr-1.4.8.tar.gz http://mirrors.weixinshow.com/unmpa_source/apr-1.4.8.tar.gz
#CheckFileExist apr-util-1.5.2.tar.gz http://mirror.esocc.com/apache/apr/apr-util-1.5.2.tar.gz
CheckFileExist apr-util-1.5.2.tar.gz http://mirrors.weixinshow.com/unmpa_source/apr-util-1.5.2.tar.gz
#CheckFileExist httpd-2.4.6.tar.gz http://mirrors.cnnic.cn/apache//httpd/httpd-2.4.6.tar.gz
CheckFileExist httpd-2.4.6.tar.gz http://mirrors.weixinshow.com/unmpa_source/httpd-2.4.6.tar.gz
#CheckFileExist mod_fastcgi-2.4.6.tar.gz http://www.fastcgi.com/dist/mod_fastcgi-2.4.6.tar.gz
CheckFileExist mod_fastcgi-2.4.6.tar.gz http://mirrors.weixinshow.com/unmpa_source/mod_fastcgi-2.4.6.tar.gz
#CheckFileExist byte-compile-against-apache24.diff http://leeon.me/upload/other/byte-compile-against-apache24.diff
CheckFileExist byte-compile-against-apache24.diff http://mirrors.weixinshow.com/unmpa_source/byte-compile-against-apache24.diff
#php探针#
CheckFileExist p.tar.gz http://mirrors.weixinshow.com/unmpa_source/p.tar.gz

}

function InitInstall()
{
cat /etc/issue
uname -a
MemTotal=`free -m | grep Mem | awk '{print  $2}'`  
echo -e "\n Memory is: ${MemTotal} MB "

#Synchronization time
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

apt-get install -y ntpdate
ntpdate -u pool.ntp.org
date

#Disable SeLinux
if [ -s /etc/selinux/config ]; then
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi

if [ -s /etc/ld.so.conf.d/libc6-xen.conf ]; then
sed -i 's/hwcap 1 nosegneg/hwcap 0 nosegneg/g' /etc/ld.so.conf.d/libc6-xen.conf
fi

rm /var/cache/apt/archives/lock
rm /var/lib/dpkg/lock

apt-get update
apt-get autoremove -y
apt-get -fy install
apt-get install -y build-essential gcc gcc-c++ g++ make
for packages in gcc gcc-c++ g++ gcc44 gcc44-c++ libcloog-ppl0 autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers make cmake libncurses5-dev ncurses-devel;
do apt-get install -y $packages --force-yes;apt-get -fy install;apt-get -y autoremove; done

#mkdir#
source_dir=$current_dir'/source/'
mkdir -p $source_dir
chmod -R 755 $source_dir
mkdir -p $current_dir'/extra/'
chmod -R 755 $current_dir'/extra/'

config_dir='/usr/local/etc'
mkdir -p $config_dir
mkdir -p $config_dir'/php/'
mkdir -p $config_dir'/nginx/'
mkdir -p $config_dir'/mysql/'
mkdir -p $config_dir'/nginx/'
}	

function InstallMysql()
{
#apt-get remove#
apt-get remove -y mysql-client mysql-server mysql-common
dpkg -l |grep mysql 
dpkg -P libmysqlclient15off libmysqlclient15-dev mysql-common 

#创建mysql组和mysql系统用户#
groupadd mysql
useradd -s /usr/sbin/nologin -g mysql mysql
#进入源码目录#
cd $source_dir
tar zxvf mysql-5.5.34.tar.gz -C ../extra/
cd ../extra/mysql-5.5.34/

mysql_prefix='/usr/local/'$(basename `pwd`)

#configure#
cmake . \
-DCMAKE_INSTALL_PREFIX=${mysql_prefix} \
-DSYSCONFDIR=${config_dir}/mysql \
-DMYSQL_DATADIR=/var/lib/mysql/ \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_INNOBASE_STORAGE_ENGINE=1

make && make install

#给权限#
chown -R mysql:mysql $mysql_prefix
chmod +w $mysql_prefix

#配置文件#
cd $mysql_prefix/support-files
cp my-medium.cnf ${config_dir}/mysql/my.cnf
sed -i '/skip-external-locking/i\basedir = '"$mysql_prefix"'' ${config_dir}/mysql/my.cnf
sed -i '/skip-external-locking/i\datadir = /var/lib/mysql' ${config_dir}/mysql/my.cnf
sed -i '/skip-external-locking/i\default-storage-engine=INNODB' ${config_dir}/mysql/my.cnf


#配置文件权限及修改#
${mysql_prefix}/scripts/mysql_install_db \
--defaults-file=${config_dir}/mysql/my.cnf \
--basedir=${mysql_prefix} \
--datadir=/var/lib/mysql \
--user=mysql

#创建日志目录#
mkdir -p /var/log/mysql/binlog
chown -R mysql:mysql /var/log/mysql

cp mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql
#vim /etc/init.d/mysql （编辑此文件，查找并修改以下变量内容：）
#vim /etc/mysql/my.cnf
#basedir=/usr/local/mysql-5.5.34
#datadir=/var/lib/mysql

ln -s ${mysql_prefix}/bin/mysql /usr/bin/mysql
ln -s ${mysql_prefix}/bin/mysqldump /usr/bin/mysqldump
ln -s ${mysql_prefix}/bin/myisamchk /usr/bin/myisamchk
ln -s ${mysql_prefix}/bin/mysqld_safe /usr/bin/mysqld_safe

#启动mysql#
/etc/init.d/mysql start
${mysql_prefix}/bin/mysqladmin -u root password ${mysql_root_pwd}

cat > /tmp/mysql_sec_script<<EOF
use mysql;
update user set password=password('$mysql_root_pwd') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password=''; 
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

${mysql_prefix}/bin/mysql -u root -p${mysql_root_pwd} < /tmp/mysql_sec_script

rm -f /tmp/mysql_sec_script

#重启#
/etc/init.d/mysql restart
/etc/init.d/mysql stop
#开机自动启动#
update-rc.d -f mysql defaults
}

function InstallDependsOfPHP()
{
#libiconv#
cd $source_dir
tar zxvf libiconv-1.14.tar.gz -C ../extra/
cd ../extra/libiconv-1.14/
./configure --prefix=/usr/local
make && make install

#libmcrypt#
cd $source_dir
tar zxvf libmcrypt-2.5.8.tar.gz -C ../extra/
cd ../extra/libmcrypt-2.5.8/
./configure
make && make install

#mhash#
cd $source_dir
tar zxvf mhash-0.9.9.9.tar.gz -C ../extra/
cd ../extra/mhash-0.9.9.9/
./configure
make && make install

#mcrypt#
cd $source_dir
tar zxvf mcrypt-2.6.8.tar.gz -C ../extra/
cd ../extra/mcrypt-2.6.8/
LD_LIBRARY_PATH="/usr/local/lib" ./configure --prefix=/usr/local
make && make install

#freetype#
cd $source_dir
tar zxvf freetype-2.4.0.tar.gz -C ../extra/
cd ../extra/freetype-2.4.0/
./configure --prefix=/usr/local/freetype
make && make install
}

function InstallPHP()
{
groupadd www
useradd -s /usr/sbin/nologin -g www www

apt-get install -y libfreetype6 libfreetype6-dev libjpeg-dev libfreetype6 libfreetype6-dev openssl libcurl4-openssl-dev libssl-dev libxml2 libxml2-dev libpng12-dev    
cd $source_dir

######delete#######
#mysql_prefix=/usr/local/mysql-5.5.34
tar zxvf php-5.4.20.tar.gz -C ../extra/
cd ../extra/php-5.4.20/
php_prefix='/usr/local/'$(basename `pwd`)
php_source_dir=$(pwd)
./configure --prefix=${php_prefix} \
--with-config-file-path=${config_dir}/php \
--with-mysql \
--with-mysqli \
--with-iconv-dir=/usr/local \
--with-mhash=/usr/local \
--with-mcrypt=/usr/local \
--with-openssl \
--with-libxml-dir \
--with-curl \
--with-freetype-dir=/usr/local/freetype \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-gd \
--enable-gd-native-ttf \
--enable-sockets \
--enable-mbstring \
--enable-fpm \
--enable-exif \
--enable-bcmath \
--enable-zip \
--disable-fileinfo


make ZEND_EXTRA_LIBS='-liconv -L/usr/local/lib'
make install

rm -f /usr/bin/php
ln -s ${php_prefix}/bin/php /usr/bin/php
ln -s ${php_prefix}/bin/phpize /usr/bin/phpize

cp php.ini-production ${config_dir}/php/php.ini
cd ${php_prefix}
cp etc/php-fpm.conf.default ${config_dir}/php/php-fpm.conf
#php-fpm#
echo "Modify php-fpm.conf......"
sed -i 's:;pid = run/php-fpm.pid:pid = run/php-fpm.pid:g' ${config_dir}/php/php-fpm.conf
sed -i 's/user = nobody/user = www/g' ${config_dir}/php/php-fpm.conf
sed -i 's/group = nobody/group = www/g' ${config_dir}/php/php-fpm.conf
sed -i 's/listen = 127.0.0.1:9000/;listen = 127.0.0.1:9000/g' ${config_dir}/php/php-fpm.conf
sed -i '/;listen = 127.0.0.1:9000/i\listen = \/dev\/shm\/php-cgi.sock' ${config_dir}/php/php-fpm.conf

#max_child等优化#
#配置php-fpm开机自动启动#
cp ${php_source_dir}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
#vim /etc/init.d/php-fpm 
sed -i 's:php_fpm_CONF=${prefix}/etc/php-fpm.conf:php_fpm_CONF='${config_dir}'/php/php-fpm.conf:g' /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm

#vim php.ini#
echo "Modify php.ini......"
sed -i 's/;date.timezone =/date.timezone = PRC/g' ${config_dir}/php/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' ${config_dir}/php/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' ${config_dir}/php/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${config_dir}/php/php.ini

mkdir -p /var/log/php
chown -R nobody:www-data /var/log/php/

#开机自动启动#
update-rc.d php-fpm defaults
}

function InstallPHPExtend()
{
###delete###
#php_prefix=/usr/local/php-5.4.20
cd ${source_dir}
tar zxvf autoconf-2.68.tar.gz -C ../extra/
cd ../extra/autoconf-2.68/
autoconfig_dir='/usr/local/'$(basename `pwd`)
./configure --prefix=${autoconfig_dir}
make && make install
export PHP_AUTOCONF=${autoconfig_dir}/bin/autoconf
export PHP_AUTOHEADER=${autoconfig_dir}/bin/autoheader

#安装ZendOpcache加速PHP Zend Opcache 原生支持模式 在 PHP 5.5.12 编译参数里加入 –enable-opcache 即可#
cd ${source_dir}
tar zxvf zendopcache-7.0.4.tgz -C ../extra/
cd ../extra/zendopcache-7.0.4/
${php_prefix}/bin/phpize
./configure --with-php-config=${php_prefix}/bin/php-config
make && make install

echo "Write ZendOpcache to php.ini......"
cat >>${config_dir}/php/php.ini<<EOF
[ZendOpcache]
zend_extension="${php_prefix}/lib/php/extensions/no-debug-non-zts-20100525/opcache.so"
opcache.enable_cli=1
opcache.memory_consumption=128      //共享内存大小, 这个根据你们的需求可调
opcache.interned_strings_buffer=8   //interned string的内存大小, 也可调
opcache.max_accelerated_files=4000  //最大缓存的文件数目
opcache.revalidate_freq=60          //60s检查一次文件更新
opcache.fast_shutdown=1             //打开快速关闭, 打开这个在PHP Request Shutdown的时候
                                    //会收内存的速度会提高
opcache.save_comments=0             //不保存文件/函数的注释
EOF

#安装Zend Guard Loader扩展优化php代码#
cd ${source_dir}
tar zxvf ${ZendGuardLoader_name}.tar.gz -C ../extra/
cd ../extra/${ZendGuardLoader_name}/
cp php-5.4.x/ZendGuardLoader.so ${php_prefix}/lib/php/extensions/no-debug-non-zts-20100525/
echo "Write ZendGuardLoader to php.ini......"
cat >>${config_dir}/php/php.ini<<EOF

[Zend Guard]
zend_extension=${php_prefix}/lib/php/extensions/no-debug-non-zts-20100525/ZendGuardLoader.so
; Enables loading encoded scripts. The default value is On
zend_loader.enable=1
; Optional: following lines can be added your php.ini file for ZendGuardLoader configuration
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path=
EOF

echo -e "\nextension_dir = \"${php_prefix}/lib/php/extensions/no-debug-non-zts-20100525/\"">>${config_dir}/php/php.ini
#memcache#
cd ${source_dir}
tar zxvf memcache-3.0.8.tgz -C ../extra/
cd ../extra/memcache-3.0.8/
${php_prefix}/bin/phpize
./configure --with-php-config=${php_prefix}/bin/php-config
make && make install
echo "extension = memcache.so" >>${config_dir}/php/php.ini

#
#为什么要装memcached扩展
#memcached的1.2.4及以上增加了CAS(Check and #Set)协议,对于同一key的多进行程的并发处理问题。这种情况其实根数据库很像，如果同时有几个进程对同一个表的同一数据进行更新的话，那会不会打架呢，哈哈。数据库里面可以锁定整张表，也可以锁定表#里面一 行的功能，其实memcached加入的CAS根这个差不多。
#php的扩展memcache，不支持cas，所以我们要装memcached扩展，memcached扩展是基于libmemcached，所以要先安装libmemcached
#
#安装libmemcached#
cd ${source_dir}
tar zxvf libmemcached-1.0.16.tar.gz -C ../extra/
cd ../extra/libmemcached-1.0.16/
./configure --prefix=/usr/local/libmemcached  --with-memcached
make && make install

#安装memcached扩展#
cd ${source_dir}
tar zxvf memcached-2.1.0.tgz -C ../extra/
cd ../extra/memcached-2.1.0/
${php_prefix}/bin/phpize
./configure --prefix=/usr/local/phpmemcached --with-php-config=${php_prefix}/bin/php-config --with-libmemcached-dir=/usr/local/libmemcached --enable-memcached
make && make install
echo "extension = memcached.so" >>${config_dir}/php/php.ini

#安装pdo_mysql扩展#
#进入php源码安装
####delete####
#php_source_dir=/usr/local/src/lnmpa/extra/php-5.4.20
#mysql_prefix=/user/local/mysql-5.5.34
cd ${php_source_dir}/ext/pdo_mysql
${php_prefix}/bin/phpize
if [ "$mysql_install" = "y" ]
  then 
./configure --with-php-config=${php_prefix}/bin/php-config --with-pdo-mysql=${mysql_prefix}
  else
./configure --with-php-config=${php_prefix}/bin/php-config --with-pdo-mysql
fi
make && make install
echo "extension = pdo_mysql.so" >>${config_dir}/php/php.ini

#安装ImageMagick服务#
cd ${source_dir}
tar zxvf ImageMagick-6.8.7-6.tar.gz -C ../extra/
cd ../extra/ImageMagick-6.8.7-6/
ImageMagick_dir='/usr/local/'$(basename `pwd`)
./configure --prefix=${ImageMagick_dir}
make && make install

#安装php imagick扩展#
cd ${source_dir}
tar zxvf imagick-3.1.2.tgz -C ../extra/
cd ../extra/imagick-3.1.2/
${php_prefix}/bin/phpize
./configure --with-php-config=${php_prefix}/bin/php-config --with-imagick=${ImageMagick_dir}
make && make install
echo "extension = imagick.so" >>${config_dir}/php/php.ini

echo "============================${php_prefix}  install completed======================"
}

function InstallNginx()
{
#pcre-8.32#
cd ${source_dir}
tar zxvf pcre-8.32.tar.gz -C ../extra/
cd ../extra/pcre-8.32/
pcre_source_dir=$(pwd)
pcre_dir='/usr/local/'$(basename `pwd`)
./configure --prefix=${pcre_dir}
make && make install

#nginx#
cd ${source_dir}
tar zxvf nginx-1.5.6.tar.gz -C ../extra/
cd ../extra/nginx-1.5.6/
nginx_dir='/usr/local/'$(basename `pwd`)
./configure --prefix=${nginx_dir} --user=www --group=www --with-http_stub_status_module --with-http_ssl_module --with-pcre=${pcre_source_dir} --conf-path=${config_dir}'/nginx/nginx.conf'
make && make install

#创建nginx日志目录#
mkdir -p /var/log/nginx/
chmod +w /var/log/nginx/
chown -R www:www /var/log/nginx/

#配置nginx开机自动启动#
cd ${source_dir}
sed -i 's:DAEMON=/usr/local/nginx/sbin/$NAME:DAEMON='"$nginx_dir"'/sbin/$NAME:g' ${source_dir}/init.d.nginx
sed -i 's:CONFIGFILE=/usr/local/nginx/conf:CONFIGFILE='"$config_dir"'/nginx:g' ${source_dir}/init.d.nginx
sed -i 's:PIDFILE=/usr/local/nginx/logs/$NAME.pid:PIDFILE='"$nginx_dir"'/logs/$NAME.pid:g' ${source_dir}/init.d.nginx
cp init.d.nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx
update-rc.d -f nginx defaults

#copy nginx.conf#
cd ${source_dir}
tar zxvf p.tar.gz -C ../extra
cd ../extra/conf
conf_dir=$(pwd)
cp nginx.conf ${config_dir}/nginx/nginx.conf
#修改nginx的port#
sed -i 's/listen       80;/listen       '"$nginx_port"';/g' ${config_dir}/nginx/nginx.conf
sed -i 's:root           html;:root           /var/www/default;:g' ${config_dir}/nginx/nginx.conf
sed -i 's/fastcgi_pass   127.0.0.1:9000;/fastcgi_pass   unix:\/dev\/shm\/php-cgi.sock;/g' ${config_dir}/nginx/nginx.conf
}

function InstallApache()
{
apt-get remove -y apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker php5 php5-common php5-cgi php5-mysql php5-curl php5-gd
killall apache2
dpkg -l |grep apache 
dpkg -P apache2 apache2-doc apache2-mpm-prefork apache2-utils apache2.2-common
dpkg -l |grep php
dpkg -P php5 php5-common php5-cgi php5-mysql php5-curl php5-gd
apt-get purge apache2.2-common

apache2_dir=/usr/local/apache2
#安装apache2.2必须的apr#
cd ${source_dir}
tar zxvf apr-1.4.8.tar.gz -C ../extra/
cd ../extra/apr-1.4.8/
apr_dir='/usr/local/'$(basename `pwd`)
./configure --prefix=${apr_dir}
make && make install

#安装apache2.2必须的apr-util#
cd ${source_dir}
tar zxvf apr-util-1.5.2.tar.gz -C ../extra/
cd ../extra/apr-util-1.5.2/
apr_util_dir='/usr/local/'$(basename `pwd`)
./configure --prefix=${apr_util_dir} --with-apr=${apr_dir}
make && make install

#delete#
#pcre_dir=/usr/local/pcre-8.32
#安装mod_php模式方式运行#
cd ${source_dir}
tar zxvf httpd-2.4.6.tar.gz -C ../extra/
cd ../extra/httpd-2.4.6/
./configure --with-apr=${apr_dir} --with-apr-util=${apr_util_dir} --with-pcre=${pcre_dir} --enable-rewrite --enable-ssl --with-mpm=prefork --sysconfdir=${config_dir}/apache
make && make install

#apache2与php5结合 有mod_php和fastcgi两种模式，这里我们使用fastcgi模式#
cd ${source_dir}
tar zxvf mod_fastcgi-2.4.6.tar.gz -C ../extra/
cd ../extra/mod_fastcgi-2.4.6/
cp Makefile.AP2 Makefile
#打补丁#
patch -p1 < ${source_dir}/byte-compile-against-apache24.diff
make top_dir=${apache2_dir}
make install top_dir=${apache2_dir}

#创建fastcgi脚本目录#
mkdir ${apache2_dir}/htdocs/fcgi-bin
#delete#
#php_prefix=/usr/local/php-5.4.20
ln -s ${php_prefix}/bin/php-cgi  ${apache2_dir}/htdocs/fcgi-bin/php-cgi
chmod +x ${apache2_dir}/htdocs/fcgi-bin


#配置apache支持php文件解析#
sed -i '/#LoadModule rewrite_module modules\/mod_rewrite.so/a\LoadModule fastcgi_module modules\/mod_fastcgi.so' ${config_dir}/apache/httpd.conf
sed -i 's:#LoadModule actions_module modules/mod_actions.so:LoadModule actions_module modules/mod_actions.so:g' ${config_dir}/apache/httpd.conf


#修改apache的端口#
sed -i 's/Listen 80/Listen '"$apache_port"'/g' ${config_dir}/apache/httpd.conf

echo "Write fastcgi_module to httpd.conf......"
cat >>${config_dir}/apache/httpd.conf<<EOF
<IfModule fastcgi_module>
    ScriptAlias /fcgi-bin/ "${apache2_dir}/htdocs/fcgi-bin/"
    # 开启10个php进程
    #FastCgiServer ${apache2_dir}/htdocs/fcgi-bin/php-cgi -processes 10    
    #FastCgiExternalServer ${apache2_dir}/htdocs/fcgi-bin/php-cgi -host 127.0.0.1:9000
    FastCgiExternalServer ${apache2_dir}/htdocs/fcgi-bin/php-cgi -socket /dev/shm/php-cgi.sock
    AddType application/x-httpd-php .php
    AddHandler php-fastcgi .php
    Action php-fastcgi /fcgi-bin/php-cgi
    <Directory "${apache2_dir}/htdocs/fcgi-bin/">
        SetHandler fastcgi-script
        Options FollowSymLinks
        Order allow,deny
        Allow from all
    </Directory>
</IfModule>
EOF

# mkdir -p apache2/conf/vhost
# vim httpd.conf Include the virtual host configurations:
#DirectoryIndex index.php
#Include conf/vhost
echo "================Install apache2 completed!================"
}

function CreatePHPTools()
{
echo "Create PHP Info Tool..."
#新建站点目录#
mkdir -p /var/www/default
chmod +w /var/www/default
#新建探针文件#
echo "Copy PHP Prober..."
cd ${conf_dir}
cp p.php /var/www/default/p.php
#新建phpinfo文件#
cat >/var/www/default/phpinfo.php<<eof
<?php
phpinfo();
eof

if [ "$apache_install" = "y" ]; then
#delete#
#apache2_dir=/usr/local/apache2
echo "Create PHP Info Tool For Apache..."
#新建探针文件#
echo "Copy PHP Prober..."
cd ${conf_dir}
cp p.php ${apache2_dir}/htdocs/p.php
#新建phpinfo文件#
cat >${apache2_dir}/htdocs/phpinfo.php<<eof
<?php
phpinfo();
eof
fi

#优化内核#
cat >> /etc/security/limits.conf <<EOF
* soft nofile 65535
* hard nofile 65535
EOF

#TODO  /etc/sysctl.conf
}

function InstallCheck()
{
echo "Starting LNMPA..."
if [ "$mysql_install" = "y" ]; then 
/etc/init.d/mysql start
fi
/etc/init.d/php-fpm start
/etc/init.d/nginx start
if [ "$apache_install" = "y" ]; then
#delete#
#delete=apache2_dir=/usr/local/apache2
${apache2_dir}/bin/apachectl start
fi
echo "===================================== Check install ==================================="
clear
isnginx=""
ismysql=""
isphp=""
isapache=""
echo "Checking..."
if [ -s ${nginx_dir} ] && [ -s ${nginx_dir}/sbin/nginx ]; then
  echo "Nginx: OK"
  isnginx="ok"
  else
  echo "Error: ${nginx_dir} found!!!Nginx install failed."
fi

if [ -s ${php_prefix}/sbin/php-fpm ] && [ -s ${config_dir}/php/php.ini ] && [ -s ${php_prefix}/bin/php ]; then
  echo "PHP: OK"
  echo "PHP-FPM: OK"
  isphp="ok"
  else
  echo "Error: ${php_prefix} not found!!!PHP install failed."
fi

if [ "$mysql_install" = "y" ] && [ -s ${mysql_prefix} ] && [ -s ${mysql_prefix}/bin/mysql ]; then
  echo "MySQL: OK"
  ismysql="ok"
  else
    if [ "$mysql_install" = "y" ]; then
        echo "Error: ${mysql_prefix} not found!!!MySQL install failed."
		else
        ismysql="ok"
    fi    
fi

if [ "$apache_install" = "y" ]; then
    if [ -s ${apache2_dir}/bin/apachectl ] && [ -s ${apache2_dir}/bin/httpd ]; then
        echo "Apache: OK"
        isapache="ok"
        else
        echo "Error: ${apache2_dir} found!!!Apache install failed."    
    fi
fi

if [ "$isnginx" = "ok" ] && [ "$ismysql" = "ok" ] && [ "$isphp" = "ok" ]; then
echo "Install unmp 1.0 completed! enjoy it. <wentmac> zwt007@gmail.com"
echo ""
echo "default mysql root password:$mysql_root_pwd"
echo "phpinfo : http://yourIP/phpinfo.php"
echo "Prober : http://yourIP/p.php"
echo ""
echo "The path of some dirs:"
echo "mysql dir:   ${mysql_prefix}"
echo "php dir:     ${php_prefix}"
echo "nginx dir:   ${nginx_dir}"
echo "web dir :    /var/www/default"
echo ""
echo "========================================================================="
    if [ "$apache_install" = "y" ] && [ "$isapache" = "ok" ]; then        
		echo "Install apache completed! enjoy it."
		echo "apache dir :     ${apache2_dir}"
	elif [ "$apache_install" = "y" ]; then		
		echo "Install apache Failed."        
    fi
netstat -ntl
else
echo "Sorry,Failed to install LNMP!"
fi
}

InitInstall || exit
DownloadSourceCode || exit
if [ "$mysql_install" = "y" ]; then 
    InstallMysql || exit
fi
InstallDependsOfPHP ||exit
InstallPHP || exit
InstallPHPExtend || exit
InstallNginx || exit
if [ "$apache_install" = "y" ]; then
    InstallApache || exit
fi
CreatePHPTools || exit
InstallCheck || exit
