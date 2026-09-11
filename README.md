# Orkestra HA Add-on Store (Public)

This repository is the **public Home Assistant Add-on Store** for Orkestra. Home Assistant Supervisor requires add-on store repositories to be **public** so users can install from Settings → Add-ons → Add-on Store.

## What lives here

| Path | Purpose |
|------|---------|
| `repository.yaml` | Registers this repo as an HA add-on store |
| `orkestra/config.yaml` | Production add-on manifest (version, image, options) |
| `orkestra/icon.png`, `logo.jpeg` | Store branding |
| `scripts/` | Manifest validation and GHCR image verification |

**No application source code** — the runtime is built from the private [`orkestra`](https://github.com/orkestrasmarthome/orkestra) monorepo and published to GHCR.

## Container image

Supervisor pulls prebuilt images:

```
ghcr.io/orkestrasmarthome/orkestra-core-{arch}:{version}
```

## How manifests are updated

The private monorepo CI (`.github/workflows/build-addon.yml`) builds Docker images on release, then uses `ADDON_UPDATE_TOKEN` to copy `services/brain-gateway/config.yaml` into `orkestra/config.yaml` here and push.

Manual edits to `orkestra/config.yaml` may be overwritten on the next release.

## User install

1. Add store URL: `https://github.com/orkestrasmarthome/orkestra-ha-addon`
2. Install the **Orkestra** add-on
3. Configure cloud URL and instance token from the [web portal](https://orkestra-client.vercel.app)

See [`ARCHITECTURE.md`](ARCHITECTURE.md) for store topology and [`../orkestra/docs/HA_ADDON_STORE.md`](../orkestra/docs/HA_ADDON_STORE.md) for the full cross-repo release model (local path if monorepo is checked out alongside this repo).
