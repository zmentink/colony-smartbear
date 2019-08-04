#!/usr/bin/env bash

echo "==> deploy war file artifact"
mv /root/smartbear-servicev/artifacts/*.war /usr/local/apache-tomcat9/webapps

echo "==> start tomcat"
/usr/local/apache-tomcat9/bin/startup.sh
