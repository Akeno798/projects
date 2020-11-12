  #!/bin/bash

  clear; echo -e "\e[34;1m######################     Скрипт для смены версии PHP    ######################\e[0m
\e[34;1m#\e[0m                                                                              \e[34;1m#\e[0m
\e[34;1m#\e[0m \e[33;1mДоступные дистрибутивы для установки:\e[0m Ubuntu 18/16, Debian 9, CentOS 7/6.    \e[34;1m#\e[0m
\e[34;1m#\e[0m \e[33;1mUbuntu 18/16:\e[0m 5.6, 7.0, 7.1, 7.2, 7.3, 7.4                                   \e[34;1m#\e[0m
\e[34;1m#\e[0m \e[33;1mDebian 9:\e[0m 5.6, 7.0, 7.1, 7.2, 7.3, 7.4                                       \e[34;1m#\e[0m
\e[34;1m#\e[0m \e[33;1mCentOS 7/6:\e[0m 5.4, 5.5, 5.6, 7.0, 7.1, 7.2, 7.3, 7.4                             \e[34;1m#\e[0m
\e[34;1m#\e[0m                                                                              \e[34;1m#\e[0m
\e[34;1m################################################################################\e[0m\n"

  ip_server=$(ip route get 1 | awk '{print $NF;exit}') # переменная для выведенния IP-адреса сервера
  
  OS=$(head -n 1 /etc/issue | awk '{print $1;exit}') # определение дистрибутива

  versions=('5.4' '5.5' '5.6' '7.0' '7.1' '7.2' '7.3' '7.4') # Массив для ввода версии PHP

  repolist_php=( # Массив repolist для yum-config-manager
    'remi-php54' 'remi-php55' 'remi-php56' 'remi-php70' 'remi-php71' 'remi-php72' 'remi-php73' 'remi-php74' 'remi-php80' 'remi-test'
    'remi-php54-debuginfo' 'remi-php55-debuginfo' 'remi-php56-debuginfo' 'remi-php70-debuginfo' 'remi-php71-debuginfo' 'remi-php72-debuginfo' 'remi-php73-debuginfo' 'remi-php74-debuginfo' 'remi-php80-debuginfo'
    'remi-php54-test' 'remi-php55-test' 'remi-php56-test' 'remi-php70-test' 'remi-php71-test' 'remi-php72-test' 'remi-php73-test' 'remi-php74-test' 'remi-php80-test'
    'remi-php54-test-debuginfo' 'remi-php55-test-debuginfo' 'remi-php56-test-debuginfo' 'remi-php70-test-debuginfo' 'remi-php71-test-debuginfo' 'remi-php72-test-debuginfo' 'remi-php73-test-debuginfo' 'remi-php74-test-debuginfo' 'remi-php80-test-debuginfo'
  )

  function install_php_centos (){ # установка PHP для CentOS

    echo "Отключаю репозитории и устанавливаю вспомогательные утилиты."

    if [[ "$OS" == "\S" ]];then
      yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm >/dev/null 2>>/var/log/change_php_error.log
    else
      yum install http://rpms.remirepo.net/enterprise/remi-release-6.rpm >/dev/null 2>>/var/log/change_php_error.log
    fi

    yum install -y yum-utils epel-release http://rpms.remirepo.net/enterprise/remi-release-7.rpm >/dev/null 2>>/var/log/change_php_error.log

    for repo in "${repolist_php[@]}"; do
          yum-config-manager --disable "$repo" >/dev/null 2>>/var/log/change_php_error.log
    done

    echo "Готово. Приступаю к установке PHP $php_v"
      yum remove php php-common -y >/dev/null 2>>/var/log/change_php_error.log
      yum-config-manager --enable remi-php"${php_v//.}" >/dev/null 2>>/var/log/change_php_error.log
      yum install php php-{common,pspell,xml,xmlrpc,pdo,ldap,pecl,mcrypt,mysqlnd,gmp,mbstring,gd,tidy,pecl-memcache,pecl-memcached} -y >/dev/null 2>>/var/log/change_php_error.log

      find /etc/httpd/conf/ -name httpd.conf -exec sed -i "s/Listen 80/Listen 8080/g" {} \;

    if [[ "$i" < "7" ]]; then
          install_roundcube 2>>/var/log/change_php_error.log && install_phpMyAdmin_5 2>>/var/log/change_php_error.log
  else
          install_roundcube 2>>/var/log/change_php_error.log && install_phpMyAdmin_7 2>>/var/log/change_php_error.log
  fi

  change_of_parameters_php;
  apachectl restart; check_webmail_pma; wget https://scripts.had.su/lnl/ioncube && chmod +x ioncube && ./ioncube > /dev/null 2>>/var/log/change_php_error.log && rm -f ioncube* ; php -v 

  }

  function install_php_ubuntu(){

    if [[ $php_v == "5.4" || $php_v == "5.5" ]]; then
      echo "Версия PHP 5.4 и 5.5 недоступны для установки."
      exit 0;
    fi
    if [[ -e /usr/bin/php$php_v ]]; then
      echo -e "Версия PHP $php_v уже установлена."
      a2dismod php$(php -v | head -n 1 | cut -b 5-7) >/dev/null 2>>/var/log/change_php_error.log && a2enmod php$php_v >/dev/null 2>>/var/log/change_php_error.log
      update-alternatives --set php /usr/bin/php$php_v >/dev/null 2>>/var/log/change_php_error.log
      change_of_parameters_php;
      apachectl restart; wget https://scripts.had.su/lnl/ioncube && chmod +x ioncube && ./ioncube > /dev/null 2>>/var/log/change_php_error.log && rm -f ioncube* ; php -v
      exit 0;
    else
      echo "Обновляю систему и подключаю репозиторий."
      apt update >/dev/null 2>>/var/log/change_php_error.log
      apt-get install -y software-properties-common >/dev/null 2>>/var/log/change_php_error.log
      echo "\n" | apt-get install python-software-properties >/dev/null 2>>/var/log/change_php_error.log
      echo "\n" | add-apt-repository ppa:ondrej/php >/dev/null 2>>/var/log/change_php_error.log
      apt update >/dev/null 2>>/var/log/change_php_error.log
      echo "Приступаю к установке PHP $php_v"
      apt-get install php$php_v php$php_v-{pspell,xml,xmlrpc,ldap,mysql,gmp,mbstring,gd,tidy,memcache,memcached} -y >/dev/null 2>>/var/log/change_php_error.log
      a2dismod php$(php -v | head -n 1 | cut -b 5-7) >/dev/null 2>>/var/log/change_php_error.log && a2enmod php$php_v >/dev/null 2>>/var/log/change_php_error.log

      update-alternatives --set php /usr/bin/php$php_v >/dev/null 2>>/var/log/change_php_error.log

      change_of_parameters_php;

      apachectl restart; wget https://scripts.had.su/lnl/ioncube && chmod +x ioncube && ./ioncube > /dev/null 2>>/var/log/change_php_error.log && rm -f ioncube* ; php -v
    fi

  }

  function install_php_debian(){
    
    if [[ $php_v == "5.4" || $php_v == "5.5" ]]; then
      echo "Версия PHP 5.4 и 5.5 недоступны для установки."
      exit 0;
    fi
    if [[ -e /usr/bin/php$php_v ]]; then
      echo -e "Версия PHP $php_v уже установлена."
      a2dismod php$(php -v | head -n 1 | cut -b 5-7) >/dev/null 2>>/var/log/change_php_error.log && a2enmod php$php_v >/dev/null 2>>/var/log/change_php_error.log
      update-alternatives --set php /usr/bin/php$php_v >/dev/null 2>>/var/log/change_php_error.log
      change_of_parameters_php;
      apachectl restart; wget https://scripts.had.su/lnl/ioncube && chmod +x ioncube && ./ioncube > /dev/null 2>>/var/log/change_php_error.log && rm -f ioncube* ; php -v
      exit 0;
    else
      echo "Обновляю систему и подключаю репозиторий."
      apt update >/dev/null 2>>/var/log/change_php_error.log
      apt-get install -y software-properties-common ca-certificates apt-transport-https >/dev/null 2>>/var/log/change_php_error.log
      echo "\n" | apt-get install python-software-properties >/dev/null 2>>/var/log/change_php_error.log
      apt install ca-certificates apt-transport-https >/dev/null 2>>/var/log/change_php_error.log
      wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add - >/dev/null 2>>/var/log/change_php_error.log
      echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list >/dev/null 2>>/var/log/change_php_error.log
      apt-get update >/dev/null 2>>/var/log/change_php_error.log
      echo "Приступаю к установке PHP $php_v"
      apt-get install php$php_v php$php_v-{pspell,xml,xmlrpc,ldap,mysql,gmp,mbstring,gd,tidy,memcache,memcached} -y >/dev/null 2>>/var/log/change_php_error.log
      a2dismod php$(php -v | head -n 1 | cut -b 5-7) >/dev/null 2>>/var/log/change_php_error.log && a2enmod php$php_v >/dev/null 2>>/var/log/change_php_error.log

      update-alternatives --set php /usr/bin/php$php_v >/dev/null 2>>/var/log/change_php_error.log

      change_of_parameters_php;

      apachectl restart; wget https://scripts.had.su/lnl/ioncube && chmod +x ioncube && ./ioncube > /dev/null 2>>/var/log/change_php_error.log && rm -f ioncube* ; php -v
    fi

  }

  function change_of_parameters_php() {
    
    if [[ "$OS" == "Ubuntu" || "$OS" == "Debian" ]]; then
      find /etc/php/$php_v/*/ -name php.ini -exec sed -i "s%.*post_max_size = .*%post_max_size = 256M%" {} \;
      find /etc/php/$php_v/*/ -name php.ini -exec sed -i "s%.*upload_max_filesize = .*%upload_max_filesize = 256M%" {} \;
      find /etc/php/$php_v/*/ -name php.ini -exec sed -i "s%.*max_execution_time = .*%max_execution_time = 300%" {} \;
      find /etc/php/$php_v/*/ -name php.ini -exec sed -i "s%.*memory_limit = .*%memory_limit = 512M%" {} \;
      find /etc/php/$php_v/*/ -name php.ini -exec sed -i "s%.*session.gc_probability = .*%session.gc_probability = 1%" {} \;
    else
      find /etc -name php.ini -exec sed -i "s%.*post_max_size = .*%post_max_size = 256M%" {} \;
      find /etc -name php.ini -exec sed -i "s%.*upload_max_filesize = .*%upload_max_filesize = 256M%" {} \;
      find /etc -name php.ini -exec sed -i "s%.*max_execution_time = .*%max_execution_time = 300%" {} \;
      find /etc -name php.ini -exec sed -i "s%.*memory_limit = .*%memory_limit = 512M%" {} \;
      find /etc -name php.ini -exec sed -i "s%.*session.gc_probability = .*%session.gc_probability = 1%" {} \;
    fi
    chmod 777 /var/lib/php/session

  }

  function install_roundcube(){ # установка roundcube из исходных файлов для CentOS 7

    vesta_rhel7_path="/usr/local/vesta/install/rhel/7"
    pass_roundcube=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32})

    cd /tmp && rm -rf roundcubemail* && wget -O roundcubemail-1.3.13.tar.gz https://github.com/roundcube/roundcubemail/releases/download/1.3.13/roundcubemail-1.3.13-complete.tar.gz

    if [[ $(pwd) == "/tmp" && -e roundcubemail-1.3.13.tar.gz ]]; then
      tar -xzvf roundcubemail-1.3.13.tar.gz >/dev/null 2>>/var/log/change_php_error.log
      rm -rf /usr/share/roundcubemail/*
      cp -Rf roundcubemail-1.3.13/* /usr/share/roundcubemail/
      cp -f $vesta_rhel7_path/roundcube/main.inc.php /usr/share/roundcubemail/config/config.inc.php
      cd /usr/share/roundcubemail/plugins/password
      cp -f $vesta_rhel7_path/roundcube/vesta.php drivers/vesta.php
      cp -f $vesta_rhel7_path/roundcube/config.inc.php config.inc.php
      sed -i "s/localhost/$(hostname)/g" config.inc.php
      chown -R root:apache /usr/share/roundcubemail/
      chmod a+r /usr/share/roundcubemail/ && chmod -R 644 /usr/share/roundcubemail/config/config.inc.php && chmod 777 /var/log/roundcubemail/
      sed -i "s/%password%/$pass_roundcube/g" /usr/share/roundcubemail/config/config.inc.php
      mysql -e "GRANT ALL ON roundcube.* TO roundcube@localhost IDENTIFIED BY '$pass_roundcube'"
      wget http://c.vestacp.com/0.9.8/rhel/httpd-webmail.conf -O /etc/httpd/conf.d/roundcubemail.conf
      rm -rf /tmp/roundcubemail*
    else
      return 1
    fi
  }


  function install_phpMyAdmin_7(){ # установка phpmyadmin ранней версии из исходных файлов для CentOS 7

    cd /tmp && rm -rf phpMyAdmin* && wget https://files.phpmyadmin.net/phpMyAdmin/4.9.5/phpMyAdmin-4.9.5-all-languages.zip -O phpMyAdmin-4.9.5.zip

    if [[ $(pwd) == "/tmp" && -e phpMyAdmin-4.9.5.zip ]]; then
      unzip -q phpMyAdmin-4.9.5.zip
        if [ ! -d /usr/share/phpMyAdmin ]; then
          mkdir /usr/share/phpMyAdmin
        fi
      rm -rf /usr/share/phpMyAdmin/*
      cp -Rf phpMyAdmin-4.9.5-all-languages/* /usr/share/phpMyAdmin/
      wget http://c.vestacp.com/0.9.8/rhel/httpd-pma.conf -O /etc/httpd/conf.d/phpMyAdmin.conf
      rm -rf /tmp/phpMyAdmin*
    else
      echo "Произошла непредвиденная ошибка во время установки phpMyAdmin, что-то пошло не так."
    fi
  }

  function install_phpMyAdmin_5(){ # установка phpmyadmin поздней из исходных файлов для CentOS 7

    cd /tmp && rm -rf phpMyAdmin* && wget https://files.phpmyadmin.net/phpMyAdmin/4.4.15.10/phpMyAdmin-4.4.15.10-all-languages.zip -O phpMyAdmin-4.4.15.10.zip

    if [[ $(pwd) == "/tmp" && -e phpMyAdmin-4.4.15.10.zip ]]; then
      unzip -q phpMyAdmin-4.4.15.10.zip
        if [ ! -d /usr/share/phpMyAdmin ]; then
          mkdir /usr/share/phpMyAdmin
        fi
      rm -rf /usr/share/phpMyAdmin/*
      cp -Rf phpMyAdmin-4.4.15.10-all-languages/* /usr/share/phpMyAdmin/
      wget http://c.vestacp.com/0.9.8/rhel/httpd-pma.conf -O /etc/httpd/conf.d/phpMyAdmin.conf
      rm -rf /tmp/phpMyAdmin*
    else
      echo "Произошла непредвиденная ошибка во время установки phpMyAdmin, что-то пошло не так."
    fi
  }

  function check_webmail_pma(){ # проверка работоспособности phpmyadmin и roundcube после смены PHP на CentOS

    if [ $(curl -I -L http://$ip_server/webmail/ 2>/dev/null | head -n 1 | cut -d$' ' -f2) == 200 ]; then
    echo "[OK] Установка roundcubemail http://$ip_server/roundcubemail/ или http://$ip_server/webmail/"
  else
    echo "[FALSE] Установка roundcubemail, что-то пошло не так."
  fi

  if [ $(curl -I -L http://$ip_server/phpMyAdmin/ 2>/dev/null | head -n 1 | cut -d$' ' -f2) == 200 ]; then
    echo "[OK] Установка phpMyAdmin http://$ip_server/phpMyAdmin/ или http://$ip_server/phpmyadmin/"
  else
    echo "[FALSE] Установка phpMyAdmin, что-то пошло не так."
  fi

  }

  function check_version_php (){ # Функция для проверки наличия введенной версии из массива versions

    for i in "${versions[@]}"; do
      if [[ "$i" == "$php_v" ]]; then
        check_distribution 2>>/var/log/change_php_error.log; break
    fi
    done
  # В случае, если нет совпадений из массива versions
  while [[ "$i" != "$php_v" ]]
    do
    echo -n "Введенно неверное значение $php_v . Попробуйте снова: " && read php_v && check_version_php;
    done

  }

function check_distribution { # функция для проверки дистрибутива

  if [[ "$OS" == "\S" || "$OS" == "CentOS" ]]; then
    install_php_centos 2>>/var/log/change_php_error.log;
  elif [[ $(head -n 1 /etc/issue | cut -b 1-9) == "Ubuntu 18" || $(head -n 1 /etc/issue | cut -b 1-9) == "Ubuntu 16" ]]; then
    install_php_ubuntu 2>>/var/log/change_php_error.log;
  elif [[ $(head -n 1 /etc/issue | awk '{print$1" "$3}') == "Debian 9" ]]; then
    install_php_debian 2>>/var/log/change_php_error.log;
  else
    echo "Установленный дистрибутив не поддерживается."; exit 0;
  fi

}

echo -n "Укажите версию PHP для установки (5.6): " && read php_v && check_version_php;

  exit 0
