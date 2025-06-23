# Updated Dockerfile (Dockerfile)
FROM openjdk:17-jdk-slim

WORKDIR /app

# Install curl
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY gradlew .
COPY gradle ./gradle
COPY build.gradle .
COPY settings.gradle .

RUN ./gradlew dependencies

COPY config ./config
COPY src ./src

RUN ./gradlew build -x test

EXPOSE 8080

CMD ["java", "-jar", "build/libs/hello-world-0.0.1-SNAPSHOT.jar"]