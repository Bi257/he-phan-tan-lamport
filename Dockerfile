# Giai đoạn Build
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
# Copy toàn bộ project vào container
COPY . .
# Build file JAR và bỏ qua chạy Unit Test để tiết kiệm thời gian trên Render
RUN mvn clean package -DskipTests

# Giai đoạn Chạy (Runtime)
FROM amazoncorretto:17-alpine
WORKDIR /app
# Copy file JAR đã build từ giai đoạn trước và đổi tên thành app.jar
COPY --from=build /app/target/*.jar app.jar
# Mở cổng 8080 cho traffic mạng
EXPOSE 8080
# Lệnh thực thi ứng dụng
ENTRYPOINT ["java", "-jar", "app.jar"]