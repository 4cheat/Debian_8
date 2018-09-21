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
  
  #open the main configuration file and put in bottom Servername your ip
  #or localhost, for figure out your ip 

  echo "
  
  
  ###### TIP ######
  open file vim /etc/apache2/apache2.conf 
  and put there in the bottom this line
  ServerName your_ip
  ran command 'hostname -I' = `hostname -I`
  return to vim fg
  ###### END TIP ######"

  sudo vim /etc/apache2/apache2.conf
  
  #restart apache2
  sudo systemctl restart apache2.service
  
  #allow in ufw apache2
  sudo ufw app info "Apache Full"
  sudo ufw allow in "Apache Full"
  sudo ufw status
  

  read -p "do you want to add your own user instead www-data[y/n]: " answer
  if [ $answer == "y" ] ; then
    #output tip
    echo "
    
    
    ###### TIP ######
    we must edit this file /etc/apache2/envvars
    and put there this two varialbes:
    export APACHE_RUN_USER=www-data
    export APACHE_RUN_GROUP=www-data
    and change on
    export APACHE_RUN_USER=neo
    export APACHE_RUN_GROUP=neo
    ###### END TIP #####"

    #run editor
    sudo vim /etc/apache2/envvars
  fi

  #finish installetion
  echo "
  
  
  ###### FINISH ######
  Apache2 has been successfuly installed
  now you could go to the your browser and put there ip server
  for test your server.
  Document root is /var/www/html
  your ip is `hostname -I`"  
fi




###############
# Install MySQL
###############
read -p "Do you want to install MYSQL and configure?[y/n]: " answer

if [ $answer == "y" ] ; then
  #install mysql-server
  sudo apt-get install mysql-server
  echo "### MYSQ is successfully installed ###";
  read -p "do you want to install the mysql_secure_installation [y/n]: " answer

  if [ $answer == "y" ] ; then
    #set up mysql sequre
    mysql_secure_installation
    echo "#### Congratulate #####"
    echo "mysql_secure_installation has been successfully installed"
  fi

  echo "MySQL has been successfully installed"
fi





###########################
# Install php5.6 and php7.0
###########################
read -p "Do you want to install php5.6 and php 7.0? [y/n]: " answer

if [ $answer == "y" ] ; then
  #install php from official repository
  sudo apt-get install php libapache2-mod-php php-mcrypt php-mysql

  #put index.php first in this file
  echo "$EMPTY$TITLE"
  echo "### TIP ###"
  echo "you have to put index.php on the first place in"
  echo "this file: '/etc/apache2/mods-enabled/dir.conf'"
  echo "### TIP ###"
  sudo vim /etc/apache2/mods-enabled/dir.conf
  #resart apache2
  sudo systemctl restart apache2.service

  echo "php7.0 has been successfully installed"

  #install php5.6 from not official repository
  echo "#*** We can install php5.6 from not official repository"
  read -p "Do you want? [y/n]: " answer
  
  if [ $answer == "y" ] ; then
    #add private repository
    sudo add-apt-repository ppa:ondrej/php
    #update cash
    sudo apt-get update
    #install php and needed libs
    sudo apt-get install php7.0 php5.6 php5.6-mysql php-gettext php5.6-mbstring php-mbstring php7.0-mbstring php-xdebug libapache2-mod-php5.6 libapache2-mod-php7.0
    #install zip lib
    sudo apt-get php7.0-zip

    #set up php5.6 by default
    sudo a2dismod php7.0
    sudo a2enmod php5.6
    sudo systemctl restart apache2.servise
    sudo update-alternatives --set php /usr/bin/php5.6
    
    echo "php5.6 has been successfully installed"
  fi

  echo "$EMPTY$TITLE"
  echo "------ InFormation about installation -----"
  echo "current php version:"
  echo "`php -v`"
  echo "for test php on your server you must create"
  echo "php file assume it could be info.php"
  echo "and put there function phpinfo();"
  echo "go to your server and make test!"

fi



#########################
# Install PhpMyAdmin
########################
read -p "Do you want to install phpmyadmin? [y/n]: " answer
if [ $answer == "y" ] ; then
  #install needed libs
  sudo apt-get install phpmyadmin php-mbstring php-gettext
  sudo apt install php5.6-mcrypt
  sudo apt install php5.6-mbstring
  sudo phpenmod mcrypt
  sudo phpenmod mbstring
  #restart apache2
  sudo systemctl restart apache2.service
  echo "$EMPTY$TITLE"
  echo "Now we could go to php my admin input"
  echo "in browser your_id/phpmyadmin"
  echo "if site doesn't accessbile follow instruction below"
  read -p "Can you access phpmyadmin? [y/n]:" answer
  if [ $answer == "n" ] ; then
    echo "$EMPTY$TITLE"
    echo "if we doesn’t see our site go to this file"
    echo "go to this file /etc/apache2/apache2.conf"
    echo "and add in the bottom"
    echo "Include /etc/phpmyadmin/apache.conf"
    sudo vim /etc/phpmyadmin/apache.conf
    #restart apache2
    sudo systemctl restart apache2.service
  fi

  echo "$EMPTY$TITLE";
  echo "phpmyadmin have had to be installed and availabel"
  echo "if everything is right, you can secure your phpmyadmin"
  read -p "Do you want to secure phpmyadmin? [y/n]: " answer
  
  if [ $answer == "y" ] ; then
    #edit file /etc/apache2/conf-available/phpmyadmin.conf
    echo "$EMPTY$TITLE"
    echo "you have to configure apache2 to allow .htaccess"
    echo "edit this file /etc/apache2/conf-available/phpmyadmin.conf"
    echo "add to this file AllowOverride All within"
    echo "<Directory /usr/share/phpmyadmin>"
    echo "AllowOverride All"
    sudo vim /etc/apache2/conf-available/phpmyadmin.conf
    #restart apache2
    sudo systemctl restart apache2
    #edit file /usr/share/phpmyadmin/.htaccess
    echo "$EMPTY$TITLE"
    echo "now we should add to this file"
    echo "/usr/share/phpmyadmin/.htaccess"
    echo "put there this text:"
    echo "AuthType Basic"
    echo "AuthName \"Restricted Files\""
    echo "AuthUserFile /etc/phpmyadmin/.htpasswd"
    echo "Require valid-user"
    sudo vim /usr/share/phpmyadmin/.htaccess
    #create an .htpasswd file for authentication
    #set an additional package
    sudo apt-get install apache2-utils
    #ask user his username for protect phpmyadmin
    read -p "Input your username for additional secure for phpmyadmin: " username
    #run command
    sudo htpasswd -c /etc/phpmyadmin/.htpasswd $username
    
    echo "protection has been set up"
  fi

 echo "$EMPTY$TITLE"
 echo "Congratulation, phpmyadmin has been installed"
 echo "to access it go here http://`hostname -I`/phpmyadmin"

fi





#################
# Install node.js
#################
read -p "Do you want to install NVM for node.js? [y/n]: " answer
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
  echo "for start using nvm you need reopen terminal"
  echo "you can open in new tab new terminal and follow command bellow"
  echo "set up needed node.js version"
  echo "//to find out versions node.js that are available" 
  echo "nvm ls-remote"
  echo "//you can install version by typing"
  echo "nvm install 6.0.0"
  echo "//tell nvm to use this version"
  echo "nvm use 6.0.0"
  echo "//check version by the shell by typing"
  echo "node -v"

fi
















