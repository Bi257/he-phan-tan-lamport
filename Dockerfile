# Stage 1: Build
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
COPY . .
# Xóa thư mục target cũ nếu có và build mới hoàn toàn
RUN mvn clean package -DskipTests

# Stage 2: Run
FROM amazoncorretto:17-alpine
WORKDIR /app
# Chỉ copy file jar vừa mới build xong
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]