DB_USER=admin
DB_PASSWORD=admin
DB_NAME=badbook
DB_PORT=5432
DB_URL=jdbc:postgresql://localhost:$(DB_PORT)/$(DB_NAME)

# Spring Boot commands
run:
	./mvnw spring-boot:run
build:
	./mvnw clean package -DskipTests

# Docker Compose commands
compose-up:
	docker compose -f docker-compose.dev.yaml up -d
compose-down:
	docker compose -f docker-compose.dev.yaml down
compose-logs:
	docker compose -f docker-compose.dev.yaml logs -f

# Flyway commands
migrate:
	mvn flyway:migrate -Dflyway.url=$(DB_URL) -Dflyway.user=$(DB_USER) -Dflyway.password=$(DB_PASSWORD)

migrate-info:
	mvn flyway:info -Dflyway.url=$(DB_URL) -Dflyway.user=$(DB_USER) -Dflyway.password=$(DB_PASSWORD)

migrate-repair:
	mvn flyway:repair -Dflyway.url=$(DB_URL) -Dflyway.user=$(DB_USER) -Dflyway.password=$(DB_PASSWORD)

rollback-reset:
	mvn flyway:clean -Dflyway.url=$(DB_URL) -Dflyway.user=$(DB_USER) -Dflyway.password=$(DB_PASSWORD) -Dflyway.cleanDisabled=false
	mvn flyway:migrate -Dflyway.url=$(DB_URL) -Dflyway.user=$(DB_USER) -Dflyway.password=$(DB_PASSWORD)