FROM maven:3.9.0-eclipse-temurin-17 as build
WORKDIR /app
CMD ["ls -la", "/app"]
COPY . .
CMD ["ls -la", "/app"]

FROM eclipse-temurin:17.0.6_10-jdk
WORKDIR /app
COPY --from=build /app/target/demoapp.jar /app/
CMD ["ls -la", "/app"]
EXPOSE 8080
CMD ["java", "-jar","demoapp.jar"]
