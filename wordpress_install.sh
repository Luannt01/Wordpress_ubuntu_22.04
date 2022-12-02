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
read -p "Mysql Passowrd: " DATABASE_PASS
echo "##### Create WORDPRESS DATABASE #############"
read -p "Wordpress database name: " DATABASE_NAME
echo "##### Create WORDPRESS DB_USER ##############"
read -p "Wordpress database username: " DATABASE_USERNAME
echo "#####  DB_USER PASSWORD #####################"
read -p "Wordpress database password: " DATABASE_USERNAME_PASS
clear 
echo ""
echo ""
echo ""
echo "##############################################################"
echo "###  Your Mysql root pass is $DATABASE_PASS "                 
echo "###  Your Wordpress DB is $DATABASE_NAME "               
echo "###  Your Wordpress DB_USER is $DATABASE_USERNAME "           
echo "###  Your Wordpress DB_USER_PASS is $DATABASE_USERNAME_PASS " 
echo "##############################################################"
echo ""
echo ""
echo ""
read -p "Please [Enter] to continue..." ignore

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
echo "##### Input Virtual Host Name ( IP address or Hostname )##############"
read -p "Wordpress virtual hostname: " your_domain
sudo mkdir -p /var/www/$your_domain
sudo chown -R $USER:$USER /var/www/$your_domain
sudo echo '<VirtualHost *:80>' >  /etc/apache2/sites-available/$your_domain.conf
sudo echo " ServerName $your_domain" >> /etc/apache2/sites-available/$your_domain.conf
sudo echo " ServerAlias www.$your_domain" >> /etc/apache2/sites-available/$your_domain.conf
sudo echo ' ServerAdmin webmaster@localhost' >> /etc/apache2/sites-available/$your_domain.conf
sudo echo " DocumentRoot /var/www/$your_domain" >> /etc/apache2/sites-available/$your_domain.conf
sudo echo ' ErrorLog ${APACHE_LOG_DIR}/error.log' >> /etc/apache2/sites-available/$your_domain.conf
sudo echo ' CustomLog ${APACHE_LOG_DIR}/access.log combined' >> /etc/apache2/sites-available/$your_domain.conf
sudo echo " <Directory /var/www/$your_domain/>" >> /etc/apache2/sites-available/$your_domain.conf
sudo echo '          AllowOverride All' >> /etc/apache2/sites-available/$your_domain.conf
sudo echo ' </Directory>' >> /etc/apache2/sites-available/$your_domain.conf
sudo echo '</VirtualHost>' >> /etc/apache2/sites-available/$your_domain.conf


##### Enable the new virtual host #################
echo "##### Enable the new virtual host ###########"
sudo a2ensite $your_domain
sudo a2dissite 000-default
sudo a2enmod rewrite
sudo apache2ctl configtest
sudo systemctl reload apache2


##### Download and install wordpress #################
echo "##### Download and install wordpress ###########"
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
touch /tmp/wordpress/.htaccess
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
mkdir /tmp/wordpress/wp-content/upgrade
sudo cp -a /tmp/wordpress/. /var/www/$your_domain

# Adjusting the Ownership and Permissions wordpress  #
echo "# Adjusting the Ownership and Permissions wordpress # "
sudo chown -R www-data:www-data /var/www/$your_domain
sudo find /var/www/$your_domain/ -type d -exec chmod 750 {} \;
sudo find /var/www/$your_domain/ -type f -exec chmod 640 {} \;

######### WordPress Configuration File ##############
echo "##### WordPress Configuration File ###########"
#sed -i "40,60d" /var/www/$your_domain/wp-config.php
sed -i "s/database_name_here/$DATABASE_NAME/g" /var/www/$your_domain/wp-config.php
sed -i "s/username_here/$DATABASE_USERNAME/g" /var/www/$your_domain/wp-config.php
sed -i "s/password_here/$DATABASE_USERNAME_PASS/g" /var/www/$your_domain/wp-config.php
#echo "/**#@+" >> /var/www/$your_domain/wp-config.php
#echo " * Authentication unique keys and salts." >> /var/www/$your_domain/wp-config.php
#echo " *" >> /var/www/$your_domain/wp-config.php
#echo " * Change these to different unique phrases! You can generate these using" >> /var/www/$your_domain/wp-config.php
#echo " * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}." >> /var/www/$your_domain/wp-config.php
#echo " *" >> /var/www/$your_domain/wp-config.php
#echo " * You can change these at any point in time to invalidate all existing cookies." >> /var/www/$your_domain/wp-config.php
#echo " * This will force all users to have to log in again." >> /var/www/$your_domain/wp-config.php
#echo " *" >> /var/www/$your_domain/wp-config.php
#echo " * @since 2.6.0" >> /var/www/$your_domain/wp-config.php
#echo " */" >> /var/www/$your_domain/wp-config.php
#echo |curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> /var/www/$your_domain/wp-config.php
#echo "/**#@-*/" >> /var/www/$your_domain/wp-config.php
echo ""
echo ""
echo ""
echo "######################################################"
echo "##  WORDPRESS INSTALL FINISH, GO TO HTTP://YOUR_IP  ##"
echo "######################################################"
