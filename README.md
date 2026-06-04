# BadBook Monorepo

## Structure

- `apps/backend/`: Spring Boot API, database migrations, backend scripts, Docker Compose.
- `apps/web-admin/`: React/Vite administration client.
- `apps/app-user/`: Flutter user application.
- `docs/`: design and migration notes.
- `.github/`: CI workflow definitions.
- `Makefile`: root command interface for all applications.

## Environment Layout

- `apps/backend/.env`: backend runtime and local infrastructure variables.
- `apps/backend/.env.example`: canonical backend env template.
- `apps/web-admin/.env.example`: web admin Vite variables.
- root `.env`: legacy fallback only; prefer `apps/backend/.env`.

## Common Commands

- `make env-backend-init`: create `apps/backend/.env` from its template.
- `make run`: start backend from repo root.
- `make test`: run backend tests.
- `make compose-up`: start PostgreSQL and Redis for backend development.
- `make web-admin-install`: install pnpm workspace dependencies.
- `make web-admin-dev`: start the admin web app.
- `make app-user-pub-get`: install Flutter dependencies.
- `make verify`: run backend tests, web lint/build, and Flutter analyze/tests.
- `make app-user-build`: build a debug APK when an installable artifact is needed.

## Notes

- Backend commands prefer `apps/backend/.env` and only fall back to root `.env`.
- `apps/app-user` does not use `.env`; pass runtime config with `flutter run --dart-define=KEY=value`.
