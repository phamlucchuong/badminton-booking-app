# Repository Guidelines

## Project Structure & Module Organization

This repository is a monorepo for a badminton booking platform.

- `apps/backend/`: Java 21 Spring Boot API. Feature code lives under `src/main/java/vn/chuongpl/badbook/features/`; shared configuration and exceptions are in `configuration/` and `common/`.
- `apps/backend/src/main/resources/db/migration/`: versioned Flyway SQL migrations (`V14__description.sql`).
- `apps/backend/src/test/`: JUnit/Spring Boot tests and test configuration.
- `apps/web-admin/`: React, TypeScript, Vite, Tailwind, and Zustand admin client.
- `apps/app-user/`: Flutter user application; assets are grouped under `assets/`.
- `docs/`: architecture, migration, and implementation plans.

## Build, Test, and Development Commands

Run common workflows from the repository root:

- `make env-backend-init`: create `apps/backend/.env` from the committed template.
- `make compose-up`: start local PostgreSQL and Redis services.
- `make run`: run the Spring Boot API.
- `make test`: run backend tests; `make build` packages the backend without tests.
- `make web-admin-install && make web-admin-dev`: install and run the admin client.
- `make web-admin-lint && make web-admin-build`: lint and type-check/build the admin client.
- `make app-user-pub-get && make app-user-run`: install and run the Flutter app.
- `make verify`: run backend tests, web lint/build, and Flutter analyze/test/APK build.

Run Flutter checks from `apps/app-user` with `flutter analyze --no-fatal-warnings --no-fatal-infos` and `flutter test`; generated FlutterFlow lint findings remain visible but do not fail CI unless they are errors.

## Coding Style & Naming Conventions

Follow existing language conventions. Java uses four-space indentation, PascalCase types, camelCase members, and feature-oriented packages. Name Spring layers consistently, such as `VenueController`, `VenueService`, and `VenueRepository`.

TypeScript uses two-space indentation, single quotes, functional React components, and kebab-case filenames such as `admin-users-page.tsx`. Run ESLint before submitting. Dart follows `flutter_lints`; format changed Dart files with `dart format`.

## Testing Guidelines

Backend tests use JUnit 5, Spring Boot Test, H2, and Spring Security Test. Place tests in the matching package and name them `*Test.java`. Flutter tests belong in `test/` and end in `_test.dart`. Add focused tests for service behavior, authorization rules, migrations, and bug fixes. CI runs `./apps/backend/mvnw -f apps/backend/pom.xml clean verify`.

## Commit & Pull Request Guidelines

History generally follows Conventional Commits: `feat:`, `fix:`, `build:`, `refactor:`, with optional scopes such as `fix(app_user):`. Keep commits focused and describe behavior in the imperative mood.

Pull requests should explain the change, list verification commands, link relevant issues or plans, and include screenshots for UI changes. Document new environment variables in the appropriate `.env.example`; never commit secrets or generated build output.
