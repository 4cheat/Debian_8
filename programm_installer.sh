#!/bin/bash
G
#this script will install:
#apache2,
#mysql
#php5.6 and php7

EMPTY="#
#
#
#"
TITLE="#######################"
apt-get update
apt-get install sudo
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak_by_script
echo "deb http://www.deb-multimedia.org jessie main non-free" | sudo tee -a /etc/apt/sources.list
echo "deb-src http://www.deb-multimedia.org jessie main non-free" | sudo tee -a /etc/apt/sources.list

#############################
# Установка часового пояса и синхронизации времени
#############################

read -p "Изменить часовой пояс и настроить синхронизацию времени?[y/n]: " answer
  if [ $answer == "y" ] ; then
    #output tip
    echo "
    
    
    ###### TIP ######
	Во время первоначальной установки Debian 
	будет сконфигурирован часовой пояс с помощью пакета tzdata.
    Выбираем географический район и в следующем окне выбираем часовой пояс
    Будет установлен сервер синхронизации времени NTP
    В целях безопасности, для доступа к Вашему серверу извне, 
	добавятся в файл /etc/ntp.conf следующие строки 
	(данные строки уже могут присутствовать):
    disable monitor
    restrict default kod nomodify notrap nopeer noquery
    restrict -6 default kod nomodify notrap nopeer noquery
    restrict 127.0.0.1
    restrict -6 ::1"

    #run
    dpkg-reconfigure tzdata
	apt-get install ntp ntpdate
	sudo cp /etc/ntp.conf /etc/ntp.conf.bak_by_script
	echo "disable monitor" | sudo tee -a /etc/ntp.conf
	echo "restrict default kod nomodify notrap nopeer noquery" | sudo tee -a /etc/ntp.conf
	echo "restrict -6 default kod nomodify notrap nopeer noquery" | sudo tee -a /etc/ntp.conf
	echo "restrict 127.0.0.1" | sudo tee -a /etc/ntp.conf
	echo "restrict -6 ::1" | sudo tee -a /etc/ntp.conf
	echo "server ntp1.stratum1.ru iburst" | sudo tee -a /etc/ntp.conf
	service ntp restart
	update-rc.d ntp defaults

	
  #finish installetion
  echo "
    
    
    ###### FINISH ######
  Чайсовой пояс и синхронизация настроены
  Сервис NTP добавлен в автозагрузку и будет
  вычислять насколько отстают ваши часы
  и постоянно подправлять их."  
fi


#############################
# Установка дополнительных пакетов
#############################

read -p "Установить дополнительные пакеты?[y/n]: " answer
  if [ $answer == "y" ] ; then
    #output tip
    echo "
    
    
    ###### TIP ######
	Будут установленны следующие пакеты: 
	cron
	libglib2.0-0
	bzip2
	unzip
	curl
	screen
	ca-certificates
	nano
	deb-multimedia-keyring"

    #run
    apt-get update
    apt-get install cron libglib2.0-0 bzip2 unzip curl screen ca-certificates nano deb-multimedia-keyring
    apt-get update && sudo apt-get upgrade -y
    apt-get dist-upgrade


	
  #finish installetion
  echo "
    
    
    ###### FINISH ######
    Дополнительные пакеты установленны."  
fi



#############################
# Install apache or other app
#############################
read -p "Хотите установить web-сервер apache2[y/n]: " answer;

if [ $answer == 'y' ] ; then
  #first of all update system
  sudo apt-get update
  sudo apt-get upgrade
  
  #here we should check whether apache2 is installed

  #install apache2
  sudo apt-get install apache2
  sudo apt-get install apache2-mpm-prefork

  #finish installetion
  echo "
  
  
  ###### FINISH ######
  
  Веб-сервер Apache2 установлен
  чтобы проверить работу веб-сервера наберите в браузере ip сервера
  Директория сайта /var/www/html
  Ваш ip - `hostname -I`
  
  "  
fi




###############
# Install MySQL
###############
read -p "Установить MYSQL и настроить?[y/n]: " answer

if [ $answer == "y" ] ; then
  #install mysql-server
  sudo apt-get install mysql-server mysql-client
  echo "### MYSQL сервер и клиент установлены ###";
  read -p "Запустить мастер настройки MYSQL сервера?[y/n]: " answer

  if [ $answer == "y" ] ; then
    #set up mysql sequre
    mysql_secure_installation
    echo "#### Congratulate #####"
    echo "MYSQL сервер настроен"
  fi

  echo "
  
  MySQL сервер успешно установлен!
  
  "
fi





###########################
# Install php5
###########################
read -p "Хотите установить php5? [y/n]: " answer

if [ $answer == "y" ] ; then
  #install php from official repository
  sudo apt-get install php5 libapache2-mod-php5 php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl
  sudo apt-get install perl libapache2-mod-perl2	
  sudo apt-get install python libapache2-mod-python  

  #put index.php first in this file
  echo "$EMPTY$TITLE"
  echo "### TIP ###"
  echo "Для проверки работы PHP будет создан файл, который выводит все параметры PHP."
  echo "<?php phpinfo(); ?>" > /var/www/html/info.php
  echo "этот файл нахдится: '/var/www/html/info.php'"
  echo "### TIP ###"
  #resart apache2
  sudo systemctl restart apache2.service

  echo "php5 успешно установлен"

  echo "$EMPTY$TITLE"
  echo "------ Информация об установке -----"
  echo "установленная версия php:"
  echo "`php -v`"
  echo "Для проверки PHP введите в браузере http://адрес_вашего_сервера/info.php должна открыться страница."

fi



#########################
# Install PhpMyAdmin
########################
read -p "Хотите установить phpmyadmin? [y/n]: " answer
if [ $answer == "y" ] ; then
  #install needed libs
  echo "в ходе установки:"
  echo "В первом вопросе требуется определиться с установленным web-сервером - Apache2"
  echo "В следующем шаге мастер попросит разрешения на создания новой базы - yes"
  echo "Далее нас попросят ввести пароль пользователя root MySQL-сервера - вводим и жмем Enter"
  echo "Затем нас попросят придумать пароль для доступа в phpMyAdmin - придумываем посложней и жмем Enter"
  sudo apt-get install phpmyadmin

  #restart apache2
  sudo systemctl restart apache2.service
  echo "$EMPTY$TITLE"
  echo "Теперь можно войти в панель управления phpmyadmin"
  echo "для этого наберите в браузере http://адрес_вашего_сервера/phpmyadmin"
  echo "Если страница недоступна то следуйте следующим инструкциям"
  read -p "Есть доступ к панели управления phpmyadmin? [y/n]:" answer
  if [ $answer == "n" ] ; then
  sudo cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.bak_by_script
  echo "Include /etc/phpmyadmin/apache.conf" | sudo tee -a /etc/apache2/apache2.conf

    #restart apache2
    sudo systemctl restart apache2.service
  fi

  echo "$EMPTY$TITLE";
  echo "phpmyadmin установлен и авторизован на уровне Apache"
  echo "если все в порядке вы можете настроить защиту phpmyadmin"
  read -p "Установить защиту phpmyadmin? [y/n]: " answer
  
  if [ $answer == "y" ] ; then
    #edit file /etc/phpmyadmin/apache.conf
    echo "$EMPTY$TITLE"
    echo "Настройка apache2 использовать .htaccess"
    echo "Будет создана копия файла /etc/phpmyadmin/apache.conf.bak_by_script"
	echo "в исполняемый файл /etc/phpmyadmin/apache.conf"
    echo "добавлена строка AllowOverride All"
    sudo cp /etc/phpmyadmin/apache.conf /etc/phpmyadmin/apache.conf.bak_by_script
    echo "<Directory /usr/share/phpmyadmin>" | sudo tee -a /etc/phpmyadmin/apache.conf
    echo "AllowOverride All" | sudo tee -a /etc/phpmyadmin/apache.conf
    echo "</Directory>" | sudo tee -a /etc/phpmyadmin/apache.conf
    #restart apache2
    sudo systemctl restart apache2
    #edit file /usr/share/phpmyadmin/.htaccess
    echo "$EMPTY$TITLE"
    echo "Автоматически создастся файл .htaccess в директории phpmyadmin /usr/share/phpmyadmin/:"
    echo "AuthType Basic" | sudo tee -a /usr/share/phpmyadmin/.htaccess
    echo "AuthName \"Restricted Files\"" | sudo tee -a /usr/share/phpmyadmin/.htaccess
    echo "AuthUserFile /home/.htpasswd" | sudo tee -a /usr/share/phpmyadmin/.htaccess
    echo "Require valid-user" | sudo tee -a /usr/share/phpmyadmin/.htaccess
	echo "Файл создан просмотреть его можно с помощью команды: nano /usr/share/phpmyadmin/.htaccess"

    #create an .htpasswd file for authentication
    #set an additional package
    sudo apt-get install apache2-utils
    #ask user his username for protect phpmyadmin
    read -p "Введите/Создайте пользователя для доступа к phpmyadmin: " username
    #run command
    sudo htpasswd -c /home/.htpasswd $username
    
    echo "Защита настроена данные о пользователе и пароле находятся в файле: /home/.htpasswd"
  fi

 echo "$EMPTY$TITLE"
 echo "Поздравляем, установка и защита phpMyadmin закончена"
 echo "Для доступа к панели управления пройдите по ссылке http://`hostname -I`/phpmyadmin"

fi





#################
# Install node.js
#################
read -p "Хотите установить NVM для node.js? [y/n]: " answer
if [ $answer == "y" ] ; then
  #get additional package
  sudo apt-get install build-essential libssl-dev
  #put down the nvm installation script
  curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh -o install_nvm.sh
  #run the script with bash
  bash install_nvm.sh
  #source the profile file
  source ~/.profile
  echo "$EMPTY$TITLE"
  echo "для использования nvm вы должны перезапустить терминал"
  echo "вы можете открыть новый терминал в новой вкладке и следовать командам ниже"
  echo "установка необходимой версии node.js"
  echo "//для поиска доступных версий node.js введите:" 
  echo "nvm ls-remote"
  echo "//для установки нужной версии введите команду:"
  echo "nvm install 6.0.0"
  echo "//зайдате nvm использовать именно эту версию"
  echo "nvm use 6.0.0"
  echo "//проверить версию node.js"
  echo "node -v"

fi
















