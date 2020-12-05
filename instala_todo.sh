# Instala JDK
sudo apt-get install -y default-jdk
# Instala tomcat9
sudo apt-get install -y tomcat9 tomcat9-docs tomcat9-examples tomcat9-admin
# Instala mariadb
sudo apt-get install -y mariadb-server
# Instala apache2
sudo apt-get install apache2 apache2-utils
# Instalo unzip
sudo apt-get install -y unzip

#Inicio y activo los servicios
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo systemctl start tomcat9
sudo systemctl enable tomcat9

#Creo la base de datos en mariadb
sudo mysql  -e "CREATE DATABASE opencms;"
sudo mysql  -e "CREATE USER 'opencms'@'localhost' identified by 'opencms';"
sudo mysql  -e "grant all privileges on opencms.* to 'opencms'@'localhost';"
sudo mysql  -e "flush privileges;"

#Descargo opencms
sudo wget http://www.opencms.org/downloads/opencms/opencms-11.0.2.zip

#Lo descomprimo
sudo unzip opencms-11.0.2.zip

#Lo muevo a la carpeta de tomcat9
sudo mv opencms.war /var/lib/tomcat9/webapps/
sudo rm -r /var/lib/tomcat9/webapps/ROOT
sudo mv /var/lib/tomcat9/webapps/opencms.war /var/lib/tomcat9/webapps/ROOT.war

#Reinicio tomcat9
sudo systemctl restart tomcat9

#Establezco la contraseña de root para mysql
printf "\n Y\n root\n root\n n\n n\n n\n n\n" | mysql_secure_installation


