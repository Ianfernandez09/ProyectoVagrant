#Instala jdk
sudo yum -y install java-11-openjdk-devel

#Instala wget
sudo yum -y install wget

#Instala httpd
sudo yum -y install httpd

#Instala unzip
sudo yum -y install unzip

#Instala mysql
sudo dnf install mysql-server -y

#Descarga tomcat
sudo wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.40/bin/apache-tomcat-9.0.40.tar.gz

#Crea usuario y grupo tomcat
sudo groupadd --system tomcat
sudo useradd -d /usr/share/tomcat -r -s /bin/false -g tomcat tomcat

#Extrae el archivo descargado
sudo tar xvf apache-tomcat-9.0.40.tar.gz -C /usr/share/

#Crea un enlace simbólico para la ruta donde extraigo tomcat
sudo ln -s /usr/share/apache-tomcat-9.0.40/ /usr/share/tomcat

#Doy permisos al usuario tomcat
sudo chown -R tomcat:tomcat /usr/share/tomcat
sudo chown -R tomcat:tomcat /usr/share/apache-tomcat-9.0.40/

#Creo un servicio para tomcat
sudo touch /etc/systemd/system/tomcat.service
sudo echo "[Unit]" > /etc/systemd/system/tomcat.service
sudo echo "Description=Tomcat Server" >> /etc/systemd/system/tomcat.service
sudo echo "After=syslog.target network.target" >> /etc/systemd/system/tomcat.service
sudo echo " " >> /etc/systemd/system/tomcat.service
sudo echo "[Service]" >> /etc/systemd/system/tomcat.service
sudo echo "Type=forking" >> /etc/systemd/system/tomcat.service
sudo echo "User=tomcat" >> /etc/systemd/system/tomcat.service
sudo echo "Group=tomcat" >> /etc/systemd/system/tomcat.service
sudo echo " " >> /etc/systemd/system/tomcat.service
sudo echo "Environment=JAVA_HOME=/usr/lib/jvm/jre" >> /etc/systemd/system/tomcat.service
sudo echo "Environment='JAVA_OPTS=-Djava.awt.headless=true'" >> /etc/systemd/system/tomcat.service
sudo echo "Environment=CATALINA_HOME=/usr/share/tomcat" >> /etc/systemd/system/tomcat.service
sudo echo "Environment=CATALINA_BASE=/usr/share/tomcat" >> /etc/systemd/system/tomcat.service
sudo echo "Environment=CATALINA_PID=/usr/share/tomcat/temp/tomcat.pid" >> /etc/systemd/system/tomcat.service
sudo echo "Environment='CATALINA_OPTS=-Xms512M -Xmx1024M'" >> /etc/systemd/system/tomcat.service
sudo echo "ExecStart=/usr/share/tomcat/bin/catalina.sh start" >> /etc/systemd/system/tomcat.service
sudo echo "ExecStop=/usr/share/tomcat/bin/catalina.sh stop" >> /etc/systemd/system/tomcat.service
sudo echo " "
sudo echo "[Install]" >> /etc/systemd/system/tomcat.service
sudo echo "WantedBy=multi-user.target" >> /etc/systemd/system/tomcat.service

#Recargo servicios para que lea el de tomcat
sudo systemctl daemon-reload
#Inicio y activo el servicio de tomcat
sudo systemctl start tomcat
sudo systemctl enable tomcat

#Configurar httpd como proxy
sudo touch /etc/httpd/conf.d/tomcat_manager.conf
sudo echo "<VirtualHost *:80>" > /etc/httpd/conf.d/tomcat_manager.conf
sudo echo "  ServerAdmin root@localhost" >> /etc/httpd/conf.d/tomcat_manager.conf
sudo echo "  ServerName tomcat.example.com" >> /etc/httpd/conf.d/tomcat_manager.conf
sudo echo "  DefaultType text/html" >> /etc/httpd/conf.d/tomcat_manager.conf
sudo echo "  ProxyRequests off" >> /etc/httpd/conf.d/tomcat_manager.conf
sudo echo "  ProxyPreserveHost On" >> /etc/httpd/conf.d/tomcat_manager.conf
sudo echo "  ProxyPass / http://localhost:8080/" >> /etc/httpd/conf.d/tomcat_manager.com
sudo echo "  ProxyPassReverse / http://localhost:8080/" >> /etc/httpd/conf.d/tomcat_manager.conf
sudo echo "</VirtualHost>" >> /etc/httpd/conf.d/tomcat_manager.conf

#Configurar SELinux para que se pueda a acceder a tomcat a traves de apache
sudo setsebool -P httpd_can_network_connect 1
sudo setsebool -P httpd_can_network_relay 1
sudo setsebool -P httpd_graceful_shutdown 1
sudo setsebool -P nis_enabled 1

#Reinicio servicio httpd
sudo systemctl restart httpd && sudo systemctl enable httpd

#Inicio servicio mysql
sudo systemctl start mysqld.service
sudo systemctl enable mysqld

#Creo la base de datos en mysql
sudo mysql -e "CREATE DATABASE opencms;"
sudo mysql -e "CREATE USER 'opencms'@'localhost' identified by 'opencms';"
sudo mysql -e "GRANT ALL PRIVILEGES ON opencms.* to 'opencms'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

#Descargo opencms
sudo wget http://www.opencms.org/downloads/opencms/opencms-11.0.2.zip

#Lo descomprimo
sudo unzip opencms-11.0.2.zip

#Lo muevo a la carpeta de tomcat 9
sudo mv opencms.war /usr/share/tomcat/webapps/
sudo rm -r /usr/share/tomcat/webapps/ROOT
sudo mv /usr/share/tomcat/webapps/opencms.war /usr/share/tomcat/webapps/ROOT.war

#Reinicio Tomcat9
sudo systemctl restart tomcat

