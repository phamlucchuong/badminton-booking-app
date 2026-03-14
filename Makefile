
# Makefile for Spring Boot application
run:
	./mvnw spring-boot:run
build:
	./mvnw clean package -DskipTests

# docker compose commands
compose-up:
	docker compose -f docker-compose.dev.yaml up -d
compose-down:
	docker compose -f docker-compose.dev.yaml down
compose-build:
	docker compose -f docker-compose.dev.yaml build
compose-logs:
	docker compose -f docker-compose.dev.yaml logs -f
compose-restart:
	docker compose -f docker-compose.dev.yaml restart
