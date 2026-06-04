# Badminton Booking Monorepo

## Structure

- `backend/`: Spring Boot API, database migrations, backend scripts, Docker Compose.
- `frontend/`: client apps imported from the frontend project.
- `docs/`: design and migration notes.
- `.github/`: CI workflow definitions.

## Environment Layout

- `backend/.env`: backend runtime and local infrastructure variables.
- `backend/.env.example`: canonical backend env template.
- `frontend/apps/web-admin/.env.example`: web admin env template for Vite variables.
- root `.env`: legacy fallback only; prefer moving values into `backend/.env`.

## Common Commands

- `make env-backend-init`: create `backend/.env` from `backend/.env.example`.
- `make run`: start backend from repo root.
- `make test`: run backend tests.
- `make compose-up`: start PostgreSQL and Redis for backend development.
- `make web-admin-install`: install dependencies for `frontend/apps/web-admin`.
- `make web-admin-dev`: start the admin web app.
- `make app-user-pub-get`: install Flutter dependencies for `frontend/apps/app_user`.

## Notes

- Backend commands from the root `Makefile` automatically prefer `backend/.env` and only fall back to root `.env` for compatibility.
- `frontend/apps/app_user` does not use `.env` yet. When runtime config is needed there, prefer `flutter run --dart-define=KEY=value`.
