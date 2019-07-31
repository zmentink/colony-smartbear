#!/usr/bin/env bash
echo "==> install java"
apt-get update
apt-get install default-jdk -y

echo "==> install tomcat 9"
wget http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.22/bin/apache-tomcat-9.0.22.tar.gz
tar xzf apache-tomcat-9.0.*.tar.gz
cd apache-tomcat-9.0.*
mkdir /usr/local/apache-tomcat9
mv ./* /usr/local/apache-tomcat9/

echo "==> set env vars"
echo "export CATALINA_HOME="/usr/local/apache-tomcat9"" >> ~/.bashrc
echo "export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"" >> ~/.bashrc
echo "export JRE_HOME="/usr/lib/jvm/java-8-openjdk-amd64"" >> ~/.bashrc
source ~/.bashrc

echo "==> deploy war file artifact"
mv /root/smartbear-servicev/artifacts/*.war /usr/local/apache-tomcat9/webapps

echo "==> start tomcat"
/usr/local/apache-tomcat9/bin/startup.sh 