# Bước 1: Build
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app

# Tự tạo cấu trúc thư mục chuẩn bên trong môi trường build
RUN mkdir -p src/main/java src/main/resources/static

# Copy các file của Dương vào đúng vị trí Maven cần
COPY DistClockApplication.java src/main/java/
COPY TicketRepository.java src/main/java/
COPY application.properties src/main/resources/
COPY index.html src/main/resources/static/
COPY pom.xml .

# Build ra file JAR
RUN mvn clean package -DskipTests

# Bước 2: Chạy
FROM amazoncorretto:17-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]