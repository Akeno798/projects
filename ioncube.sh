#!/bin/bash

clear
put=$(pwd)
echo -e "\\033[1;34m#### \\033[1;33m     IonCube Авто установка        \\033[1;34m #### \\033[0;39m"
echo "Run script ..."
if ! [ -d /usr/local/mgr5 ]; then

####Ioncube install and tar
echo -ne '[In progress]\033[33m Установка архива и его распаковка... \e[0m \n'
mkdir /tmp/TempFolderIoncube
cd /tmp/TempFolderIoncube
uname -m | grep "i" && i='1' || i='2'; if [[ $i == "2" ]]; then
wget -q "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz"
tar zxf ioncube_loaders_lin_x86-64.tar.gz
rm -rf ioncube_loaders_lin_x86-64.tar.gz
else
wget -q "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz"
tar zxf ioncube_loaders_lin_x86.tar.gz
rm -rf ioncube_loaders_lin_x86.tar.gz
fi
echo -ne "\r\e[0;32m[OK]\033[33m Установка архива и его распаковка \e[0m \n"
mkdir /usr/local/ioncube/ 2>'/dev/null'

####PHP version
echo -ne '[In progress]\033[33m Поиск PHP версии ... \e[0m \n'
VER_PHP="$(command php --version 2>'/dev/null' \
    | command head -n 1 \
    | command cut --characters=5-7)"
echo -ne "\r\e[0;32m[OK]\e[0m \033[33m Поиск PHP версии  : $VER_PHP  \e[0m \n"

echo -ne '[In progress]\033[33m Добавление Ioncube к PHP'
mv ioncube/* /usr/local/ioncube/ && rm -rf ioncube/

PHP_PATH=`echo '<?php phpinfo(); ?>' | php | grep "Loaded Configuration File" | awk '{ print $5 }'`
a2PHP_PATH=`echo ${PHP_PATH/cli/apache2}`
cgiPHP_PATH=`echo ${PHP_PATH/cli/cgi}`
fpmPHP_PATH=`echo ${PHP_PATH/cli/fpm}`

#############
#php.ini
#############    etc/php.ini
sed -i /ioncube_loader_lin_/d $PHP_PATH 2>'/dev/null'
sed -i "2izend_extension=/usr/local/ioncube/ioncube_loader_lin_${VER_PHP}.so" $PHP_PATH 2>'/dev/null'
sed -i "3izend_extension_ts=/usr/local/ioncube/ioncube_loader_lin_${VER_PHP}_ts.so" $PHP_PATH 2>'/dev/null'
#apache
sed -i /ioncube_loader_lin_/d $a2PHP_PATH 2>'/dev/null'
sed -i "2izend_extension=/usr/local/ioncube/ioncube_loader_lin_${VER_PHP}.so" $a2PHP_PATH 2>'/dev/null'
sed -i "3izend_extension_ts=/usr/local/ioncube/ioncube_loader_lin_${VER_PHP}_ts.so" $a2PHP_PATH 2>'/dev/null'
#cgi
sed -i /ioncube_loader_lin_/d $cgiPHP_PATH 2>'/dev/null'
sed -i "2izend_extension=/usr/local/ioncube/ioncube_loader_lin_${VER_PHP}.so" $cgiPHP_PATH 2>'/dev/null'
sed -i "3izend_extension_ts=/usr/local/ioncube/ioncube_loader_lin_${VER_PHP}_ts.so" $cgiPHP_PATH 2>'/dev/null'
#fpm
sed -i /ioncube_loader_lin_/d $fpmPHP_PATH 2>'/dev/null'
sed -i "2izend_extension=/usr/local/ioncube/ioncube_loader_lin_${VER_PHP}.so" $fpmPHP_PATH 2>'/dev/null'
sed -i "3izend_extension_ts=/usr/local/ioncube/ioncube_loader_lin_${VER_PHP}_ts.so" $fpmPHP_PATH 2>'/dev/null'


################
#Finish php.ini
################
echo -ne "\r\e[0;32m[OK]\033[33m Добавление Ioncube к PHP          \e[0m \n"

service httpd restart 2>'/dev/null'
service apache2 restart 2>'/dev/null'
php -v
rm -rf $put/ioncub
rm -rf /tmp/TempFolderIoncube

echo -e "### Contact with the developer ###"
echo -e "####### https://scripts.gq #######"
echo -e "### angelvengeance32@gmail.com ###"

else 
#echo "Installed ISP. I can not"
echo -ne '[In progress]\033[33m Установка архива и его распаковка... \e[0m \n'
mkdir /tmp/TempFolderIoncube
cd /tmp/TempFolderIoncube
wget -q "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz"
tar zxf ioncube_loaders_lin_x86-64.tar.gz
rm -rf ioncube_loaders_lin_x86-64.tar.gz
echo -ne "\r\e[0;32m[OK]\033[33m Установка архива и его распаковка \e[0m \n"
echo -ne '[In progress]\033[33m Ставлю Ioncube... \e[0m \n'

if [ -d /usr/lib/php/ioncube/ ]; then
cp -rpa ioncube/* /usr/lib/php/ioncube/
fi
if [ -d /usr/lib64/php/modules/ioncube/ ]; then
cp -rpa ioncube/* /usr/lib64/php/modules/ioncube/
fi
if [ -d /usr/lib64/php/ioncube/ ]; then
cp -rpa ioncube/* /usr/lib64/php/ioncube/
fi
if [ -d /usr/lib/php5/ioncube/ ]; then
cp -rpa ioncube/* /usr/lib/php5/ioncube/
fi
if [ -d /usr/lib/php7/ioncube/ ]; then
cp -rpa ioncube/* /usr/lib/php7/ioncube/
fi
if [ -d /usr/lib/php/php64/ioncube/ ]; then
cp -rpa ioncube/* /usr/lib/php/php64/ioncube/
fi
if [ -d /opt/php70/lib/php/modules/ ]; then
cp -rpa ioncube/ioncube_loader_lin_7.0* /opt/php70/lib/php/modules/
fi
if [ -d /opt/php71/lib/php/modules/ ]; then
cp -rpa ioncube/ioncube_loader_lin_7.1* /opt/php71/lib/php/modules/
fi
if [ -d /opt/php72/lib/php/modules/ ]; then
cp -rpa ioncube/ioncube_loader_lin_7.2* /opt/php72/lib/php/modules/
fi
if [ -d /opt/php56/lib/php/modules/ ]; then
cp -rpa ioncube/ioncube_loader_lin_5.6* /opt/php56/lib/php/modules/
fi
if [ -d /opt/php55/lib/php/modules/ ]; then
cp -rpa ioncube/ioncube_loader_lin_5.5* /opt/php55/lib/php/modules/
fi
if [ -d /opt/php54/lib/php/modules/ ]; then
cp -rpa ioncube/ioncube_loader_lin_5.4* /opt/php54/lib/php/modules/
fi
if [ -d /opt/php53/lib/php/modules/ ]; then
cp -rpa ioncube/ioncube_loader_lin_5.3* /opt/php53/lib/php/modules/
fi
if [ -d /opt/php52/lib/php/modules/ ]; then
cp -rpa ioncube/ioncube_loader_lin_5.2* /opt/php52/lib/php/modules/
fi
if [ -d /opt/php5/lib/php/modules/ ]; then
cp -rpa ioncube/* /opt/php5/lib/php/modules/
fi
rm -rf ioncube/

service httpd restart 2>'/dev/null'
service apache2 restart 2>'/dev/null'
php -v
rm -rf $put/ioncub
rm -rf /tmp/TempFolderIoncube
echo -ne "\r\e[0;32m[OK]\033[33m Всё готово!\e[0m \n"
echo -e "### Contact with the developer ###"
echo -e "####### https://scripts.gq #######"
echo -e "### angelvengeance32@gmail.com ###"
fi



#if grep "строка" <имя файла>; then
#echo "Эта строка есть в файле"
#else
#echo "Этой строки нету в файле"
#fi
