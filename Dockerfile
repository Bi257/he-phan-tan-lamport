FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
COPY . .
# Maven sẽ tự quét các file .java ở thư mục hiện tại
RUN mvn clean package -DskipTests

FROM amazoncorretto:17-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]