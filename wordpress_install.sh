# Wordpress Install script
# created and maintained from Luannt/Wordpress-Install
#!/bin/bashsudo apt update

##### Check if sudo
if [[ "$EUID" -ne 0 ]]
  then echo "Please run as root"
  exit
fi

echo "############################################"
echo "This script will install New Wordpress using Apache webserver, PHP-7.4, developed for Ubuntu 22.04 LTS"
echo "The script will perform apt install and update commands."
echo "Use at your own risk"
echo "############################################"
read -p "Please [Enter] to continue..." ignore

##### Install Apache web service #################
sudo apt install apache2 -y

##### Install PHP services ########################
sudo apt install -y php libapache2-mod-php php-mysql \
php-curl php-gd php-mbstring php-xml php-xmlrpc \
php-soap php-intl php-zip
##### Install Mysql Service #######################
sudo apt install mysql-server -y

echo "##### Config Mysql For Wordpress ############"
echo "##### Create New Mysql Passowrd #############"
read DATABASE_PASS
echo "##### Create WORDPRESS DATABASE #############"
read DATABASE_NAME
echo "##### Create WORDPRESS DB_USER ##############"
read DATABASE_USERNAME
echo "#####  DB_USER PASSWORD #####################"
read DATABASE_USERNAME_PASS

echo "##############################################################"
echo "##  Your Mysql root pass is $DATABASE_PASS                 ###"
echo "##  Your Wordpress DB is $DATABASE_NAME                    ###"
echo "##  Your Wordpress DB_USER is $DATABASE_USERNAME           ###"
echo "##  Your Wordpress DB_USER_PASS is $DATABASE_USERNAME_PASS ###"
echo "##############################################################"
sleep 3

##### Create WORDPRESS DATABASE ###################
sudo mysql -e "CREATE DATABASE $DATABASE_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
##### Create WORDPRESS DB_USER ###################
sudo mysql -e "CREATE USER '$DATABASE_USERNAME'@'%' IDENTIFIED WITH mysql_native_password BY '$DATABASE_USERNAME_PASS';"
sudo mysql -e "GRANT ALL ON $DATABASE_NAME.* TO '$DATABASE_USERNAME'@'%';"

##### Mysql Secure installation ###################
echo "##### AUTOMATE Mysql Secure installation ####"
sudo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DROP DATABASE IF EXISTS test;"
sudo mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
sudo mysql -e "FLUSH PRIVILEGES;"
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DATABASE_PASS';"


##### Config Virutal Host #########################
echo "##### Config Virutal Host ###################"
echo "##### Input Virtual Host Name ##############"
read your_domain
sudo mkdir /var/www/$your_domain
sudo chown -R $USER:$USER /var/www/$your_domain
sudo echo '<VirtualHost *:80>' >  /etc/apache2/sites-available/$your_domain.conf
sudo echo ' ServerName $your_domain' >> /etc/apache2/sites-available/$your_domain.conf
sudo echo ' ServerAlias www.$your_domain' >> /etc/apache2/sites-available/$your_domain.conf
sudo echo ' ServerAdmin webmaster@localhost' >> /etc/apache2/sites-available/$your_domain.conf
sudo echo ' DocumentRoot /var/www/$your_domain' >> /etc/apache2/sites-available/$your_domain.conf
sudo echo ' ErrorLog ${APACHE_LOG_DIR}/error.log' >> /etc/apache2/sites-available/$your_domain.conf
sudo echo ' CustomLog ${APACHE_LOG_DIR}/access.log combined' >> /etc/apache2/sites-available/$your_domain.conf
sudo echo '</VirtualHost>' >> /etc/apache2/sites-available/$your_domain.conf

##### Enable the new virtual host #################
echo "##### Enable the new virtual host ###########"
sudo a2ensite $your_domain
sudo a2dissite 000-default
sudo apache2ctl configtest
sudo systemctl reload apache2
