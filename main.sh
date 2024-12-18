# récupération des variables
source variables.sh

clear

echo "Script d'installation de Nextcloud"
echo -e "
                       __
  ___  __ _ ___ _   _ / _| ___  _ __ _ __ ___   ___ _ __
 / _ \/ _` / __| | | | |_ / _ \| '__| '_ ` _ \ / _ \ '__|
|  __/ (_| \__ \ |_| |  _| (_) | |  | | | | | |  __/ |
 \___|\__,_|___/\__, |_|  \___/|_|  |_| |_| |_|\___|_|
                |___/
"

# mise a jour du cache
echo "Script d'installation de Nextcloud"
apt-get update > /dev/null 2>&1
apt-get upgrade -y > /dev/null 2>&1

# installation des dépendances
echo "Script d'installation de Nextcloud"
apt-get install -y sudo wget unzip apache2 mariadb-server > /dev/null 2>&1
apt-get install -y php$php_version libapache2-mod-php$php_version php$php_version-gd php$php_version-curl php$php_version-zip php$php_version-dom php$php_version-xml php$php_version-simplexml php$php_version-mbstring php$php_version-intl php$php_version-bcmath php$php_version-gmp php$php_version-imagick php$php_version-mysql php$php_version-fpm > /dev/null 2>&1

# configuration de la base de donnée
echo "Script d'installation de Nextcloud"
sudo mysql -e "CREATE DATABASE $bdd_name;"
sudo mysql -e "CREATE USER '$bdd_user'@'localhost' IDENTIFIED BY '$bdd_password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $bdd_name.* TO '$bdd_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# configuration de apache2 et installation de nextcloud
echo "Script d'installation de Nextcloud"
sudo bash -c "cat > /etc/apache2/sites-available/$domain.conf << EOL
<VirtualHost *:80>
    ServerName $domain
    DocumentRoot /var/www/$domain/nextcloud/

    <Directory /var/www/$domain/nextcloud>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$domain-error.log
    CustomLog \${APACHE_LOG_DIR}/$domain-access.log combined
</VirtualHost>
EOL
"
echo "Script d'installation de Nextcloud"
mkdir -p /var/www/$domain

echo "Script d'installation de Nextcloud"
sudo a2ensite $domain.conf > /dev/null 2>&1
sudo a2enmod rewrite headers env dir mime setenvif ssl > /dev/null 2>&1

echo "Script d'installation de Nextcloud"
wget https://download.nextcloud.com/server/releases/nextcloud-$nextcloud_version.zip > /dev/null 2>&1
unzip nextcloud-$nextcloud_version.zip > /dev/null 2>&1
mv nextcloud /var/www/$domain/

echo "Script d'installation de Nextcloud"
sudo chown www-data:www-data /var/www/$domain/nextcloud -R
sudo chmod 755 /var/www/$domain/nextcloud -R

echo "Script d'installation de Nextcloud"
sudo systemctl restart apache2

echo "Script d'installation de Nextcloud"
sudo -u www-data php /var/www/${domain}/nextcloud/occ maintenance:install \
    --database "mysql" \
    --database-name "${bdd_name}" \
    --database-user "${bdd_user}" \
    --database-pass "${bdd_password}" \
    --admin-user "${nextcloud_admin_user}" \
    --admin-pass "${nextcloud_admin_password}"
sudo -u www-data php /var/www/${domain}/nextcloud/occ config:system:set trusted_domains 0 --value="${domain}"

echo "Nextcloud installé avec succes"
echo "==> Nom de la base de donnée $bdd_name"
echo "==> Nom d'utilisateur de la base de donnée $bdd_user"
echo "==> Nom de passe de la base de donnée $bdd_password"
echo "==> Nom d'utilisateur de Nextcloud $nextcloud_admin_user"
echo "==> Nom de passe de nextcoud $nextcloud_admin_password"
echo "==> version de nextcloud $nextcloud_version"
echo "==> Pour accéder a Nextcloud Redez-vous sur http://$domain"