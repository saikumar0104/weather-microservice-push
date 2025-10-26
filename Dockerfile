# Use OpenJDK 17 as base image
FROM eclipse-temurin:17-jdk-alpine

# Set timezone
ENV TZ=Asia/Kolkata
RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo "$TZ" > /etc/timezone \
    && apk del tzdata

# Set working directory inside container
WORKDIR /app

# Copy Maven build output (jar file) to container
COPY target/weather-push-microservice-1.0.0.jar weather-push-microservice.jar

# Expose port if needed (Spring Boot default 8080)
EXPOSE 8080

# Environment variable for PushGateway URL
ENV PUSHGATEWAY_URL=http://10.60.31.5:9091

# Run the Spring Boot application
ENTRYPOINT ["java","-jar","/app/weather-push-microservice.jar"]
