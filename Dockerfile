FROM openjdk:21
WORKDIR /app
COPY Justick-0.0.2.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
