# Use an official OpenJDK runtime as a parent image
FROM openjdk:17-jdk-slim

# Set the working directory to /app
WORKDIR /app

# Copy the gradle wrapper and build files
COPY gradlew .
COPY gradle ./gradle
COPY build.gradle .
COPY settings.gradle .

# Download dependencies
RUN ./gradlew dependencies

# Copy the rest of the application code
COPY src ./src

# Build the application
RUN ./gradlew build -x test

# Expose port 8080 (the default Spring Boot port)
EXPOSE 8080

# Define the command to run your application
CMD ["java", "-jar", "build/libs/hello-world-0.0.1-SNAPSHOT.jar"]