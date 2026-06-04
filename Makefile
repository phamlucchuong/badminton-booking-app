ENV_FILE ?= .env

.PHONY: run build test compose-up compose-down compose-logs compose-reset wait-db db-create migrate migrate-info migrate-repair rollback-reset

ifneq ("$(wildcard $(ENV_FILE))","")
include $(ENV_FILE)
export $(shell sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/\1/p' $(ENV_FILE))
endif

DB_USER ?= admin
DB_PASSWORD ?= admin
DB_NAME ?= badbook
DB_PORT ?= 5432
DB_URL ?= jdbc:postgresql://localhost:$(DB_PORT)/$(DB_NAME)

# Spring Boot commands
run: compose-up wait-db db-create
	./mvnw spring-boot:run
build:
	./mvnw clean package -DskipTests
test:
	./mvnw test

# Docker Compose commands
compose-up:
	docker compose -f docker-compose.dev.yaml up -d
compose-down:
	docker compose -f docker-compose.dev.yaml down
compose-logs:
	docker compose -f docker-compose.dev.yaml logs -f
compose-reset:
	docker compose -f docker-compose.dev.yaml down -v
	docker compose -f docker-compose.dev.yaml up -d

wait-db:
	@docker exec -i badbook-db sh -c 'until pg_isready -U "$(DB_USER)" -d postgres >/dev/null 2>&1; do sleep 1; done'

db-create:
	@docker exec -i badbook-db psql -U $(DB_USER) -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$(DB_NAME)'" | grep -q 1 || \
	docker exec -i badbook-db psql -U $(DB_USER) -d postgres -c "CREATE DATABASE $(DB_NAME);"

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
