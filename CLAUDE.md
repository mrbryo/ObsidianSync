# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ObsidianSync** is a self-hosted Obsidian Sync server using CouchDB and Docker, designed for Unraid deployment. It allows users to sync their Obsidian vaults across devices without relying on Obsidian's cloud service.

The project is based on the setup guide from [Self-Host Obsidian Sync in 10 Minutes with Docker](https://www.joshuapack.com/self-host-obsidian-sync-in-10-minutes-with-docker/), but aims to provide a more secure, locally-available implementation with future Tailscale support for remote access.

## Architecture

- **Database**: CouchDB running in a single-node configuration
- **Deployment**: Docker container orchestrated via docker-compose
- **Target Platform**: Unraid (Community Application)
- **Authentication**: Basic HTTP authentication (username/password)
- **CORS Configuration**: Enabled for Obsidian app and web clients

### Key Configuration Details

The CouchDB instance is configured in `config/local.ini` with:
- **CORS**: Allows connections from Obsidian app (`app://obsidian.md`), Capacitor (`capacitor://localhost`), and local browser clients
- **Authentication**: Required for all requests via `require_valid_user = true`
- **Large File Support**: Configured for 4GB bulk imports and 50MB max document size
- **Session Management**: Basic auth redirect to session handler

## Development

### Starting the Development Environment
```bash
docker compose up
```

This starts the CouchDB container with:
- Container name: `obsidian-sync`
- Port: `5984` (CouchDB HTTP API)
- Volume: `./data/` (persistent database storage)
- Config: `./config/local.ini` (mounted into CouchDB)
- Restart policy: `unless-stopped`

### Environment Variables

Set via `docker-compose.yml`:
- `COUCHDB_USER`: Admin username (currently `admin_user`)
- `COUCHDB_PASSWORD`: Admin password (currently `admin_password`)

**Important**: These should be injected via secrets/environment at runtime for production, not hardcoded.

### Accessing the Service

- CouchDB HTTP API: `http://localhost:5984`
- Admin credentials: Use `COUCHDB_USER` and `COUCHDB_PASSWORD` from environment
- Web interface: `http://localhost:5984/_utils/` (requires authentication)

## Deployment

### Production Images
Images are pushed to an Unraid server as a community application. Ensure:
- Secrets are injected via environment variables, never baked into images
- Health checks are configured for all services
- Base image is `couchdb:latest`

### Dockerfile

Currently empty. Should define:
- Base image: `couchdb:latest` (or build custom image if needed)
- Any additional tools or configurations
- Health check configuration

## Configuration

### `config/local.ini`

This file controls CouchDB behavior and is mounted directly into the container. Key sections:

- `[httpd]`: CORS headers and realm configuration
- `[cors]`: Allowed origins, credentials, methods, max age
- `[chttpd]`: Request size limits and user validation
- `[chttpd_auth]`: Authentication requirements
- `[couchdb]`: Single-node mode, document size limits

Modify this file to:
- Add additional allowed origins for remote access (Tailscale support)
- Adjust max file sizes if needed
- Change session configuration

## Common Tasks

### Access CouchDB Admin Console
Navigate to `http://localhost:5984/_utils/` and log in with admin credentials.

### Inspect Database
Use curl or a CouchDB client:
```bash
curl -u admin_user:admin_password http://localhost:5984/
```

### Add Allowed Origins (for Tailscale)
Edit `config/local.ini` under `[cors]` → `origins` to include your Tailscale domain or IP.

## Future Enhancements

- Tailscale integration for secure remote access
- Enhanced security measures beyond basic auth
- Production-grade secret management
