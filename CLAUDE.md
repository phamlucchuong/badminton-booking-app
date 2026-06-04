# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Badminton court booking platform, organized as a monorepo:

- `apps/backend/` — Spring Boot 3.5 REST API (Java 21, Maven), PostgreSQL + Redis, Flyway migrations.
- `apps/web-admin/` — React 19 + Vite + TypeScript admin SPA (pnpm workspace).
- `apps/app-user/` — Flutter user app (FlutterFlow-generated, Firebase/Firestore).
- `docs/` — design and migration notes.

All commands below are run from the **repo root** via the `Makefile`, which auto-loads `apps/backend/.env` (falling back to root `.env`).

## Common Commands

### Backend (Spring Boot)
- `make compose-up` — start PostgreSQL + Redis (`apps/backend/docker-compose.dev.yaml`); required before running the app.
- `make run` — start the API (`spring-boot:run`). Served at `http://localhost:8080/badbook` (context-path `/badbook`).
- `make build` — `clean package -DskipTests`.
- `make test` — run all backend tests.
- Run a single test: `./apps/backend/mvnw -f apps/backend/pom.xml test -Dtest=BookingServiceTest` (or `-Dtest=BookingServiceTest#methodName`).
- `make migrate` / `make migrate-info` / `make migrate-repair` — Flyway against the running DB.
- `make rollback-reset` — `flyway:clean` then `migrate` (destroys all data).
- Swagger UI: `http://localhost:8080/badbook/swagger-ui.html`.

### Web admin (React)
- `make web-admin-install`, `make web-admin-dev` (port 3002), `make web-admin-build`, `make web-admin-lint`.

### Flutter user app
- `make app-user-pub-get`, `make app-user-run`.

### Env setup
- `make env-backend-init` — create `apps/backend/.env` from `apps/backend/.env.example`. Do this first.

CI (`.github/workflows/ci.yml`) verifies backend, web admin, and Flutter app changes on pushes/PRs to `main` and `dev`.

## Backend Architecture

Package root: `vn.chuongpl.badbook`. **Feature-sliced**, not layer-sliced — each domain lives under `features/<name>/` containing its own `Controller`, `Service`, `Repository`, JPA entity, MapStruct `Mapper`, and `dto/{request,response}/`. Features: `auth`, `user`, `role`, `permission`, `venue`, `court`, `booking`, `product`, `payment`, `finance`, `review`, `schedule`, `location`, `media`, `otp`, `search`, `admin`.

Cross-cutting code lives in:
- `common/` — `ApiResponse<T>` (uniform `{code, message, data}` envelope), `PageResponse`, `enums/` (status enums + `ErrorCode`), `exception/` (`AppException` + `GlobalExceptionHandler`).
- `configuration/` — security, JWT, Cloudinary, Goong (geocoding) WebClient, Flyway.

### Conventions to follow
- **Controllers** return `ApiResponse.<T>builder().data(...).build()` directly (not `ResponseEntity`). Use `@PreAuthorize("hasRole('USER'|'VENUE_MANAGER'|'ADMIN')")` for authorization, and `@AuthenticationPrincipal Jwt jwt` + `jwt.getSubject()` to get the current user id.
- **Errors**: throw `new AppException(ErrorCode.X)`. Add new error cases to the `ErrorCode` enum (grouped by domain, numeric codes; messages are in Vietnamese). `GlobalExceptionHandler` maps these to the `ApiResponse` envelope.
- **Lombok + MapStruct** are used throughout (`@RequiredArgsConstructor` for DI, mappers as Spring components). Both run via annotation processors — a clean build is needed after changing entities/mappers.
- **Entities** are validated against the schema (`spring.jpa.hibernate.ddl-auto: validate`) — the DB schema is owned by Flyway migrations in `apps/backend/src/main/resources/db/migration/` (`V1__...` onward), **not** by Hibernate. Schema changes require a new `V<n>__*.sql` migration.
- Note: Flyway auto-run is **disabled** in `application.yaml` (`spring.flyway.enabled: false`); migrations are applied explicitly via `make migrate`.

### Security & auth
- Stateless JWT resource server (`spring-security-oauth2-resource-server`). `CustomerJwtDecoder` decodes tokens; `JwtBlacklistFilter` (backed by Redis via `JwtBlacklistService`) rejects logged-out tokens. Roles map to `ROLE_*` authorities.
- Public endpoints are whitelisted in `SecurityConfig` (`PUBLIC_POST_ENDPOINT` / `PUBLIC_GET_ENDPOINT`); everything else requires authentication.
- `ApplicationInitConfig` seeds roles (`ADMIN`, `VENUE_MANAGER`, `USER`) and a default admin (`admin@gmail.com`) on startup.

### External integrations
- **Cloudinary** — media uploads (`media` feature). **Goong** — geocoding (`location` feature). **VNPay** — payments (`payment` feature, sandbox config in `application.yaml`). **JavaMail** — OTP/email. All keyed via env vars with placeholder defaults.

### Tests
JUnit 5 + Mockito + AssertJ, unit-style service tests (mocked repositories, `@ExtendWith(MockitoExtension.class)`). H2 is the test-scope DB.

## Web Admin Architecture

React 19 SPA, `@/` aliases `src/`. Routing in `src/router.tsx` (`react-router-dom` v6, `createBrowserRouter`) with an `AdminLayout` shell wrapping nested `pages/admin/*`. State via **Zustand** stores in `src/store/` (`auth`, `preferences`). UI built with Tailwind CSS v4 (`@tailwindcss/vite`), `lucide-react` icons, `recharts`, `sonner` toasts. User-facing copy is centralized in `src/lib/copy.ts`.

## Flutter App Notes

`app_user` is FlutterFlow-generated (`lib/flutter_flow/`, `lib/backend/`, page/component folders). Backed by Firebase/Firestore. Does not use `.env` — pass runtime config via `flutter run --dart-define=KEY=value`.
