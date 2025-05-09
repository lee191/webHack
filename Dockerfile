FROM tomcat:9.0


# Copy the WAR file to the webapps directory
COPY /tomcat/webapps /usr/local/tomcat/webapps/
COPY /tomcat/lib /usr/local/tomcat/lib/


# 포트 설정
EXPOSE 8080

# Tomcat 실행
CMD ["catalina.sh", "run"]

