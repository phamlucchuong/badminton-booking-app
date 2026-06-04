BACKEND_ENV_FILE ?= $(if $(wildcard apps/backend/.env),apps/backend/.env,.env)
BACKEND_DIR ?= apps/backend
BACKEND_MVN ?= ./$(BACKEND_DIR)/mvnw
BACKEND_POM ?= $(BACKEND_DIR)/pom.xml
BACKEND_COMPOSE ?= $(BACKEND_DIR)/docker-compose.dev.yaml
WEB_ADMIN_DIR ?= apps/web-admin
APP_USER_DIR ?= apps/app-user
COMPOSE_ENV_ARG = $(if $(wildcard $(BACKEND_ENV_FILE)),--env-file $(BACKEND_ENV_FILE),)

.PHONY: run build test backend-verify verify compose-up compose-down compose-logs compose-reset wait-db db-create migrate migrate-info migrate-repair rollback-reset web-admin-install web-admin-dev web-admin-build web-admin-lint app-user-pub-get app-user-run app-user-analyze app-user-test app-user-build env-backend-init

ifneq ("$(wildcard $(BACKEND_ENV_FILE))","")
include $(BACKEND_ENV_FILE)
export $(shell sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/\1/p' $(BACKEND_ENV_FILE))
endif

DB_USER ?= admin
DB_PASSWORD ?= admin
DB_NAME ?= badbook
DB_PORT ?= 5432
DB_URL ?= jdbc:postgresql://localhost:$(DB_PORT)/$(DB_NAME)

# Spring Boot commands
run:
	$(BACKEND_MVN) -f $(BACKEND_POM) spring-boot:run
build:
	$(BACKEND_MVN) -f $(BACKEND_POM) clean package -DskipTests
test:
	$(BACKEND_MVN) -f $(BACKEND_POM) test

backend-verify:
	$(BACKEND_MVN) -f $(BACKEND_POM) clean verify

verify: backend-verify web-admin-lint web-admin-build app-user-analyze app-user-test app-user-build

# Docker Compose commands
compose-up:
	docker compose $(COMPOSE_ENV_ARG) -f $(BACKEND_COMPOSE) up -d
compose-down:
	docker compose $(COMPOSE_ENV_ARG) -f $(BACKEND_COMPOSE) down
compose-logs:
	docker compose $(COMPOSE_ENV_ARG) -f $(BACKEND_COMPOSE) logs -f
compose-reset:
	docker compose $(COMPOSE_ENV_ARG) -f $(BACKEND_COMPOSE) down -v
	docker compose $(COMPOSE_ENV_ARG) -f $(BACKEND_COMPOSE) up -d

wait-db:
	@docker exec -i badbook-db sh -c 'until pg_isready -U "$(DB_USER)" -d postgres >/dev/null 2>&1; do sleep 1; done'

db-create:
	@docker exec -i badbook-db psql -U $(DB_USER) -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$(DB_NAME)'" | grep -q 1 || \
	docker exec -i badbook-db psql -U $(DB_USER) -d postgres -c "CREATE DATABASE $(DB_NAME);"

# Flyway commands
migrate:
	$(BACKEND_MVN) -f $(BACKEND_POM) flyway:migrate -Dflyway.url=$(DB_URL) -Dflyway.user=$(DB_USER) -Dflyway.password=$(DB_PASSWORD)

migrate-info:
	$(BACKEND_MVN) -f $(BACKEND_POM) flyway:info -Dflyway.url=$(DB_URL) -Dflyway.user=$(DB_USER) -Dflyway.password=$(DB_PASSWORD)

migrate-repair:
	$(BACKEND_MVN) -f $(BACKEND_POM) flyway:repair -Dflyway.url=$(DB_URL) -Dflyway.user=$(DB_USER) -Dflyway.password=$(DB_PASSWORD)

rollback-reset:
	$(BACKEND_MVN) -f $(BACKEND_POM) flyway:clean -Dflyway.url=$(DB_URL) -Dflyway.user=$(DB_USER) -Dflyway.password=$(DB_PASSWORD) -Dflyway.cleanDisabled=false
	$(BACKEND_MVN) -f $(BACKEND_POM) flyway:migrate -Dflyway.url=$(DB_URL) -Dflyway.user=$(DB_USER) -Dflyway.password=$(DB_PASSWORD)

# Frontend commands
web-admin-install:
	pnpm install --frozen-lockfile

web-admin-dev:
	pnpm --dir $(WEB_ADMIN_DIR) dev

web-admin-build:
	pnpm --dir $(WEB_ADMIN_DIR) build

web-admin-lint:
	pnpm --dir $(WEB_ADMIN_DIR) lint

app-user-pub-get:
	cd $(APP_USER_DIR) && flutter pub get

app-user-run:
	cd $(APP_USER_DIR) && flutter run

app-user-analyze:
	cd $(APP_USER_DIR) && flutter analyze --no-fatal-warnings --no-fatal-infos

app-user-test:
	cd $(APP_USER_DIR) && flutter test

app-user-build:
	cd $(APP_USER_DIR) && flutter build apk --debug

env-backend-init:
	cp -n $(BACKEND_DIR)/.env.example $(BACKEND_DIR)/.env
