FROM tomcat:9.0


# Copy the WAR file to the webapps directory
COPY /tomcat/ /usr/local/tomcat/
RUN apt update && apt install -y mariadb-client

# 포트 설정
EXPOSE 8080

# Tomcat 실행
CMD ["catalina.sh", "run"]

