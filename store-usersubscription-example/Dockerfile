FROM maven:3.9.6-eclipse-temurin-21
EXPOSE 8090
ADD /target/usersubscription.jar usersubscription.jar
ENTRYPOINT ["java", "-jar", "usersubscription.jar"]
