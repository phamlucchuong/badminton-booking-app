# Backend Deployment on EC2

## Recommended Architecture

Build the backend image in GitHub Actions, push it to GitHub Container Registry
(GHCR), then let EC2 pull and run that exact image. Do not build from source on
EC2: it makes deployments slower, requires build tools on the server, and makes
rollback and artifact verification harder.

Use RDS for PostgreSQL and ElastiCache for Redis when possible. Keeping stateful
services outside the application instance prevents data loss when replacing or
recovering EC2.

## One-Time EC2 Setup

Install Docker Engine and the Docker Compose v2 plugin, then prepare the deploy
directory. Ensure the deploy user can run Docker without `sudo`:

```bash
sudo mkdir -p /opt/badbook
sudo chown "$USER":"$USER" /opt/badbook
sudo usermod -aG docker "$USER"
newgrp docker
```

From a trusted workstation, upload the environment template:

```bash
scp deploy/backend/.env.example ubuntu@EC2_HOST:/opt/badbook/.env
ssh ubuntu@EC2_HOST chmod 600 /opt/badbook/.env
```

Then connect to EC2 and edit the production values:

```bash
ssh ubuntu@EC2_HOST
nano /opt/badbook/.env
chmod 600 /opt/badbook/.env
```

`DB_URL` must use the JDBC format, for example
`jdbc:postgresql://db-host:5432/badbook`.

For a private GHCR package, create a GitHub classic personal access token with
`read:packages`, then authenticate once on EC2:

```bash
echo "$GHCR_TOKEN" | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

Put Nginx or an Application Load Balancer in front of port `8080`. The Compose
file binds backend to `127.0.0.1` by default, so do not expose port `8080` in the
EC2 security group when Nginx runs on the same instance. Allow SSH only from
trusted IPs and expose HTTP/HTTPS through the proxy or load balancer.

## SSH Deploy Key

Create a dedicated key locally and authorize it for the EC2 deploy user:

```bash
ssh-keygen -t ed25519 -C badbook-github-actions -f badbook-deploy
ssh-copy-id -i badbook-deploy.pub ubuntu@EC2_HOST
ssh-keyscan -H EC2_HOST
```

Add these GitHub repository or `production` environment secrets:

- `EC2_HOST`: public DNS name or IP.
- `EC2_USER`: usually `ubuntu` or `ec2-user`.
- `EC2_SSH_PRIVATE_KEY`: contents of `badbook-deploy`.
- `EC2_KNOWN_HOSTS`: output from `ssh-keyscan -H EC2_HOST`.

Optionally set the `production` environment variable `EC2_SSH_PORT`; it defaults
to `22`. Add required reviewers to the GitHub `production` environment when
manual deployment approval is required.

## Deployment Flow

`.github/workflows/backend-cd.yml` runs after the `CI` workflow succeeds on
`main`, or manually through `workflow_dispatch`. It:

1. Builds `apps/backend/Dockerfile`.
2. Pushes immutable `${commit_sha}` and moving `latest` tags to GHCR.
3. Uploads `deploy/backend/compose.prod.yaml` to EC2.
4. Pulls the immutable image and waits for `/badbook/actuator/health`.

The production Compose configuration enables Flyway migrations on startup.
Create a database backup before deployments that include schema changes.

To roll back, run the Compose deployment on EC2 with a previous SHA tag:

```bash
cd /opt/badbook
BACKEND_IMAGE=ghcr.io/OWNER/badbook-backend:PREVIOUS_SHA \
  docker compose --env-file .env -f compose.prod.yaml up -d --wait backend
```
