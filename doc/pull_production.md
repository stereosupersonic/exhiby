# Pulling Production Data to Local Development

This guide explains how to use `bin/pull_production` to copy the production database and Active Storage files to your local machine for development.

## Prerequisites

### Local Tools

Make sure these are installed on your Mac:

- **PostgreSQL client tools** (`psql`, `pg_restore`, `dropdb`, `createdb`) — needed to connect to the Docker container from the host
- **Docker** — for the local PostgreSQL container
- **SSH** (included with macOS)

Install the PostgreSQL client tools via Homebrew (no need for the full server):

```bash
brew install libpq
brew link --force libpq
```

Verify with:

```bash
psql --version
pg_restore --version
ssh -V
docker --version
```

### SSH Access

You need SSH access to the production server (`37.120.188.157`) as user `stereosonic`. Test it:

```bash
ssh stereosonic@37.120.188.157 "echo OK"
```

If this fails, make sure your SSH key is configured. The key used for Kamal deployments (see `.kamal/secrets`) should work.

### Local PostgreSQL Container Running

PostgreSQL runs locally as a standalone Docker container. Make sure it is running before pulling:

```bash
docker ps --filter ancestor=postgres --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

If the container is not running, start it (adjust image version and password to match your `config/database.yml` / `.env`):

```bash
docker run -d \
  --name postgres-dev \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgresdb \
  -p 5432:5432 \
  -v pgdata-dev:/var/lib/postgresql/data \
  postgres:17-alpine
```

The script reads connection settings (host, port, username, password) from `config/database.yml`, so it will connect to whatever the container exposes. The defaults are:

| Setting | Default (from `database.yml`) |
|---------|-------------------------------|
| Host | `0.0.0.0` |
| Port | `5432` |
| Username | `postgres` |
| Password | `postgresdb` |

### No Active Connections

The script will terminate existing connections to `exhiby_development`, but for a clean run make sure your local Rails server is stopped:

```bash
# Stop bin/dev or any running Rails process
```

## Usage

### Full Pull (Database + Storage)

```bash
bin/pull_production
```

This performs all three steps:
1. Dumps and restores the production database
2. Streams all Active Storage files
3. Sanitizes sensitive data (resets passwords)

### Database Only

```bash
bin/pull_production --db-only
```

Use this when you only need fresh data but already have the media files locally.

### Storage Files Only

```bash
bin/pull_production --media-only
```

Use this when your database is fine but images/attachments are missing or outdated.

### Skip Sanitization

```bash
bin/pull_production --no-sanitize
```

Restores the database without resetting passwords. Useful if you want to keep the original password hashes for debugging authentication issues.

## What Each Step Does

### Step 1: Database Pull

1. Reads local database settings (name, host, port, user, password) from `config/database.yml` via Rails
2. Connects via SSH to the production server
3. Runs `pg_dump` inside the `exhiby-postgres` Docker container
4. Creates a compressed custom-format dump (~compressed binary)
5. Streams the dump to `/tmp/exhiby_production.dump` on your Mac
6. Terminates any active connections to the local development database
7. Drops and recreates the local development database
8. Restores the dump using `pg_restore` with 4 parallel jobs
9. Removes the temporary dump file

### Step 2: Storage Pull

1. Finds the running web container on production (e.g., `exhiby-web-abc123`)
2. Runs `tar` inside the container to archive `/rails/storage`
3. Streams the tar archive over SSH
4. Extracts files into the local `storage/` directory

### Step 3: Sanitization

Runs `bin/rails db:sanitize` which:

1. Resets **all** user passwords to `password`
2. Deletes all sessions (forces re-login)
3. Prints admin email addresses so you know which accounts to use

## After the Pull

### Log In Locally

Start your local server:

```bash
bin/dev
```

Visit `http://localhost:3000` and log in with any user account. The password for all accounts is now:

```
password
```

The script prints admin email addresses at the end — use one of those for full access.

### Verify Everything Works

- **ActionText content**: Check artist biographies and articles — HTML formatting should be preserved
- **Images**: Browse media items and albums — thumbnails and full images should load
- **Attachments**: Check artist profile images and any PDF uploads

## Troubleshooting

### "Permission denied" on SSH

Make sure your SSH key is loaded:

```bash
ssh-add -l
```

If empty, add your key:

```bash
ssh-add ~/.ssh/id_rsa   # or whichever key you use
```

### pg_restore Warnings

`pg_restore` may print warnings like:

```
pg_restore: warning: errors ignored on restore: 3
```

This is normal. It typically happens because production roles (e.g., `postgres`) don't exist locally with the same configuration. The `--no-owner --no-acl` flags handle this, and the data is restored correctly.

### "database is being accessed by other users"

Stop all processes using the database:

```bash
# Stop Rails server, console, sidekiq, etc.

# Or force-terminate connections manually (connects to your local Docker Postgres)
psql -h 0.0.0.0 -U postgres -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'exhiby_development' AND pid <> pg_backend_pid();"
```

### "connection refused" or "could not connect to server"

Make sure your local PostgreSQL Docker container is running:

```bash
docker ps --filter ancestor=postgres
```

If it's not running, start it (see Prerequisites above).

### Storage Files Missing After Pull

Check that files were actually downloaded:

```bash
find storage -type f | wc -l
```

If zero, the web container might not have been found. Verify it's running:

```bash
ssh stereosonic@37.120.188.157 "docker ps --filter name=exhiby-web"
```

### Images Not Displaying Locally

Active Storage generates URLs based on the blob key. After a full pull (DB + storage), the keys should match. If images are broken:

1. Make sure you pulled **both** database and storage (not just one)
2. Check that `storage/` contains two-character subdirectories (`0a`, `0b`, etc.)
3. Restart your Rails server to clear any cached blob URLs

### Slow Transfer

The storage pull streams all files in a single tar archive. For large media libraries this can take a while. You can check progress by watching the `storage/` directory grow:

```bash
# In another terminal
watch "du -sh storage/"
```

## Running Sanitization Independently

If you already restored the database but forgot to sanitize, or want to re-sanitize:

```bash
bin/rails db:sanitize
```

This task refuses to run in production as a safety measure.

## Configuration Reference

**Production settings** are hardcoded in `bin/pull_production` and match `config/deploy.yml`:

| Setting | Value | Source |
|---------|-------|--------|
| Production server | `37.120.188.157` | `bin/pull_production` |
| SSH user | `stereosonic` | `bin/pull_production` |
| Postgres container | `exhiby-postgres` | `bin/pull_production` |
| Production database | `exhiby_production` | `bin/pull_production` |
| Database user | `postgres` | `bin/pull_production` |
| Container storage path | `/rails/storage` | `bin/pull_production` |
| Local storage path | `storage/` | `bin/pull_production` |

**Local database settings** are read automatically from `config/database.yml` (development environment):

| Setting | Source |
|---------|--------|
| Database name | `config/database.yml` → `development.database` |
| Host | `config/database.yml` → `development.host` |
| Port | `config/database.yml` → `development.port` |
| Username | `config/database.yml` → `development.username` |
| Password | `config/database.yml` → `development.password` |

If production settings change (e.g., server migration), update the variables at the top of `bin/pull_production`. Local database settings are picked up automatically from `config/database.yml` — no script changes needed.
