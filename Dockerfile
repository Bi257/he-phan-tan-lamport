# Giai đoạn 1: Build ứng dụng
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
COPY . .
# Chạy lệnh build Maven
RUN mvn clean package -DskipTests

# Giai đoạn 2: Chạy ứng dụng
FROM amazoncorretto:17-alpine
WORKDIR /app
# Copy file app.jar đã được đặt tên cố định từ bước build
COPY --from=build /app/target/app.jar app.jar
EXPOSE 8080
# Lệnh khởi chạy ứng dụng
ENTRYPOINT ["java", "-jar", "app.jar"]