FROM tomcat:9.0



# Copy the WAR file to the webapps directory
COPY /tomcat/ /usr/local/tomcat/
RUN sed -i 's|http://archive.ubuntu.com/ubuntu|http://ftp.kaist.ac.kr/ubuntu|g' /etc/apt/sources.list.d/ubuntu.sources
RUN sed -i 's|http://security.ubuntu.com/ubuntu|http://ftp.kaist.ac.kr/ubuntu|g' /etc/apt/sources.list.d/ubuntu.sources

RUN apt update && apt install -y mariadb-client
# 포트 설정
EXPOSE 8080

# Tomcat 실행
CMD ["catalina.sh", "run"]

