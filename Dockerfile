# Multi-stage build for Spring Boot 3 application
# Stage 1: Build stage
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml and source code
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Stage 2: Runtime stage
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Create a non-root user for security
RUN useradd -m -u 1000 appuser

# Copy the built JAR from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Change ownership of the app to appuser
RUN chown appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port 9000
EXPOSE 9000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD java -cp app.jar org.springframework.boot.loader.JarLauncher || exit 1

# Run the application with server.port=9000
ENTRYPOINT ["java", "-jar", "app.jar", "--server.port=9000"]
