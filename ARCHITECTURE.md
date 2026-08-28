# Orkestra HA Add-on — Architecture

## Overview

**orkestra-ha-addon** is a **Home Assistant Add-on Store repository** — a distribution manifest that tells Home Assistant Supervisor how to install and run Orkestra. It is **not** the application codebase; the actual runtime is built from **orkestra-core** and published as Docker images on GHCR.

### What This Repository Provides

1. **Add-on store metadata** (`repository.yaml`) — registers the GitHub repo as an HA add-on repository users can add in Settings → Add-ons → Add-on Store.
2. **Add-on manifest** (`orkestra/config.yaml`) — tells Supervisor how to run the container: slug, version, architectures, Ingress panel, ports, options schema, and which prebuilt image to pull.
3. **Branding assets** (`orkestra/icon.png`, `orkestra/logo.jpeg`).

### Installation Flow

When a user installs the add-on, Supervisor:

- Pulls `ghcr.io/orkestrasmarthome/orkestra-core-{arch}` (version tag from manifest)
- Mounts persistent volume at `/data`
- Injects `SUPERVISOR_TOKEN` (because `homeassistant_api: true`)
- Writes user options to `/data/options.json`
- Exposes the UI via **Home Assistant Ingress** at `/api/hassio_ingress/<token>/…` on port **3001**
- Adds a sidebar panel titled **"Orkestra"** with icon `mdi:home-lightning-bolt-outline`

### Runtime Business Logic (from orkestra-core)

The container runs a unified **"Brain + Gateway"** server that provides:

| Domain | Behavior |
|--------|----------|
| **Dashboard** | Auto-generated, room/zone-based smart-home UI from HA entity taxonomy |
| **Setup wizard** | Multi-stage onboarding: HA auth → room mapping → discovery → integrations → calibration |
| **Chat / AI** | Natural-language device control, automation drafting; AI proxied to Orkestra Cloud |
| **Automations** | Create/deploy native HA automations from chat or nightly AI suggestions |
| **Analytics / Brain** | Ingests HA state events into SQLite, nightly pattern analysis, automation suggestions |
| **Vision / occupancy** | Optional face recognition via MQTT → Double Take |
| **Messaging** | WhatsApp Web + Telegram bot integrations |

In **Supervisor add-on mode**, HA credentials are automatic via `SUPERVISOR_TOKEN` — no Long-Lived Access Token required from the user.

---

## Tech Stack

### This Repository (orkestra-ha-addon)

| Layer | Technology |
|-------|------------|
| Format | Home Assistant Add-on manifest (YAML) |
| Distribution | GitHub repo + GHCR prebuilt images |
| CI | Version bumps automated from `orkestra-core` |

### Runtime Application (orkestra-core)

| Layer | Technology |
|-------|------------|
| Runtime | Node.js 22 (Alpine), `tsx` for TypeScript execution |
| Backend | Express 5, WebSocket (`ws`) |
| Frontend | React 19, Vite 8, Tailwind CSS 4 |
| Database | SQLite via Prisma 7 at `/data/orkestra.db` |
| HA integration | `home-assistant-js-websocket`, REST proxy |
| AI | Orkestra Cloud API proxy |
| Container | Multi-stage Dockerfile; entrypoint `/run.sh` |
| CI/CD | GitHub Actions in orkestra-core: release → image build → auto-bump this repo |

---

## Directory Structure

### orkestra-ha-addon (complete tree)

```
orkestra-ha-addon/
├── repository.yaml          # HA add-on store registration
└── orkestra/
    ├── config.yaml          # Add-on manifest (Supervisor contract)
    ├── icon.png             # Add-on store icon
    └── logo.jpeg            # Branding asset
```

### Related: orkestra-core (application source)

```
orkestra-core/
├── config.yaml              # Canonical add-on manifest (includes cloud options)
├── Dockerfile               # Multi-stage build → GHCR image
├── run.sh                   # Container entrypoint
├── frontend/                # React SPA
├── server/                  # Express "Brain + Gateway"
├── ai-vision/               # Optional local vision stack
└── .github/workflows/
    ├── release.yml          # Auto patch bump on main push
    └── build-addon.yaml     # Build GHCR images + bump orkestra-ha-addon
```

---

## Core Components

### Add-on Manifest (`orkestra/config.yaml`)

| Field | Value / Purpose |
|-------|-----------------|
| `slug` | `orkestra` |
| `version` | Semver tag matching GHCR image (e.g. `"1.0.2"`) |
| `ingress` / `ingress_port` | `true` / `3001` — primary UI path |
| `homeassistant_api` | `true` — enables `SUPERVISOR_TOKEN` |
| `options` | `home_assistant_url`, `home_assistant_token` |
| `image` | `ghcr.io/orkestrasmarthome/orkestra-core-{arch}` |
| `arch` | `aarch64`, `amd64`, `armhf`, `armv7`, `i386` |

**Config drift note:** The canonical manifest in `orkestra-core/config.yaml` adds `orkestra_cloud_url` and `orkestra_instance_token` options. The store repo manifest may lag behind on these fields.

### Store Registration (`repository.yaml`)

Registers the GitHub repository as an HA add-on store:

```yaml
name: "Orkestra Add-ons"
url: "https://github.com/orkestrasmarthome/orkestra-ha-addon"
maintainer: "Eden Keshet"
```

### Container Entrypoint (orkestra-core `run.sh`)

1. Sets `DATA_DIR=/data`, `PORT=3001`, `DATABASE_URL=file:/data/orkestra.db`
2. Runs `npx prisma db push --accept-data-loss` (schema sync on upgrade)
3. Starts `npx tsx src/index.ts`

### Runtime Server (orkestra-core)

The container boots a unified Express server with:

- REST API routes for setup, calibration, chat, automations, vision, etc.
- WebSocket relay at `/ws` for real-time entity updates
- Static React SPA served in production
- Background services: MQTT, WhatsApp, Telegram, nightly cron, reactive engine

See **orkestra-core/ARCHITECTURE.md** for full server, frontend, and workflow documentation.

---

## Data Flow & Design Patterns

### Request Flow (HA Add-on Mode)

```
User Browser
  → HA Ingress (/api/hassio_ingress/<token>/…)
    → Orkestra container :3001 (Express)
      → Static React SPA OR /api/* routes
        → ha.service.ts → http://supervisor/core (SUPERVISOR_TOKEN)
        → ai.service.ts → https://api.orkestra.app/api/ai/generate
        → prisma → /data/orkestra.db
```

### Persistent Data

All persistent state lives at `/data/` in the container:

| Path | Contents |
|------|----------|
| `/data/orkestra.db` | SQLite database (Prisma) |
| `/data/options.json` | User-configured add-on options |
| `/data/user-configs/` | Per-user SDUI dashboard JSON |
| WhatsApp session data | Multi-session WhatsApp Web state |

### Design Patterns (Runtime)

| Pattern | Where |
|---------|-------|
| **Supervisor-first auth** | `env.ts` prefers `SUPERVISOR_TOKEN` over user LLAT |
| **Ingress-aware SPA** | `appBase.ts` strips/adds HA Ingress prefix |
| **BFF / Gateway** | `gateway.routes.ts` proxies HA, hides tokens |
| **Cloud AI proxy** | Local Brain never holds OpenAI keys; uses instance token |
| **Single HA WebSocket** | All ingest/reactive/caching share one connection |

### CI/CD Pipeline (cross-repo)

```
orkestra-core: push to main
  → release.yml: bump config.yaml patch version
  → build-addon.yaml: build GHCR images (amd64, aarch64)
      tags: {version}, latest
      labels: io.hass.type=addon
  → bump-ha-addon job: checkout orkestra-ha-addon
      → patch orkestra/config.yaml version
      → commit "chore: auto bump addon version"
```

Image registry: `ghcr.io/orkestrasmarthome/orkestra-core-{arch}`

---

## Integrations & Dependencies

### External Services (Runtime)

| Integration | Purpose |
|-------------|---------|
| **Home Assistant Core** | `http://supervisor/core` + `SUPERVISOR_TOKEN` — all HA operations |
| **Orkestra Cloud** | `https://api.orkestra.app` — AI generation, auth/subscription |
| **Orkestra Client** | `https://orkestra-client.vercel.app/dashboard` — subscription upgrade UI |
| **Google Calendar/Gmail** | OAuth2 via `/api/google` |
| **WhatsApp Web** | Notifications, remote commands |
| **Telegram Bot** | Notifications, commands |
| **Double Take / Frigate** | Face recognition (optional ai-vision stack) |
| **MQTT (Mosquitto)** | Vision event bus |

### Workspace Projects

| Project | Relationship |
|---------|--------------|
| **orkestra-ha-addon** | **This repo** — HA store manifest only |
| **orkestra-core** | **Application source** — builds Docker images referenced by add-on |
| **orkestra-cloud** | SaaS backend for auth, billing, AI proxy |
| **orkestra-client** | Cloud billing/subscription dashboard |

### Dual Distribution Model

| Method | Use Case |
|--------|----------|
| **orkestra-ha-addon** (this repo) | Published GHCR-based installs via the HA add-on store |
| **orkestra-core** + `deploy_local.sh` | Local development — rsync to HA SMB add-ons folder, rebuild via HA REST API |

### Supported Architectures

Manifest declares: `aarch64`, `amd64`, `armhf`, `armv7`, `i386`. CI currently builds `amd64` + `aarch64` only.

---

## Notes

1. **No application source here** — this repo contains only the HA Supervisor contract and branding. Full architecture documentation for the runtime lives in `orkestra-core/ARCHITECTURE.md`.
2. **Config sync** — the store manifest version is auto-bumped by orkestra-core CI; cloud-related options may need manual sync from `orkestra-core/config.yaml`.
3. **No Dockerfile in this repo** — images are built and published from orkestra-core.
