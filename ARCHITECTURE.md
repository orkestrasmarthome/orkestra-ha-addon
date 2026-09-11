# Orkestra HA Add-on Store — Architecture

## Overview

**orkestra-ha-addon** is a **public** Home Assistant Add-on Store repository. Supervisor reads manifests here and pulls **prebuilt Docker images from GHCR** — no proprietary application code is included.

| Repo | Visibility | Role |
|------|------------|------|
| **orkestra-ha-addon** (this repo) | **Public** | HA store manifests, icons, validation scripts |
| **orkestra** (monorepo) | **Private** | Application source, Docker build, CI |

## Installation flow

When a user installs the add-on, Supervisor:

1. Reads `orkestra/config.yaml` from this repo
2. Pulls `ghcr.io/orkestrasmarthome/orkestra-core-{arch}:{version}`
3. Mounts `/data`, injects `SUPERVISOR_TOKEN`, exposes Ingress on port **3001**

## Directory layout

```
orkestra-ha-addon/
├── repository.yaml          # Store registration
├── orkestra/
│   ├── config.yaml          # Production manifest (synced by monorepo CI)
│   ├── icon.png
│   └── logo.jpeg
├── scripts/                 # validate-addons.sh, verify-addon-images.sh
└── .github/workflows/       # addon-store.yml — validate on push
```

## Manifest sync (cross-repo)

```
orkestra (private) push → release.yml bumps services/brain-gateway/config.yaml
                       → build-addon.yml builds GHCR images
                       → bump-ha-addon job (ADDON_UPDATE_TOKEN)
                            copies config → orkestra/config.yaml (this repo)
                            commits + pushes to main
```

Canonical metadata template: `services/brain-gateway/config.yaml` in the private monorepo.

## Runtime (built elsewhere)

The container runs `services/brain-gateway` + embedded `apps/local-addon` from the private monorepo. Features: HA WebSocket relay, Ingress SPA, device pairing (web portal `/pair`), cloud AI proxy, SQLite/Prisma.

## CI in this repo

`addon-store.yml` validates manifests on push and optionally verifies GHCR images exist for tagged releases.

## Related documentation

- Private monorepo: `docs/HA_ADDON_STORE.md` in the `orkestra` repository
- Platform architecture: `ARCHITECTURE.md` at monorepo root (private)
