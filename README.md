<div align="center">

<img src="orkestra/logo.png" alt="Orkestra" width="180" />

# Orkestra

**Intelligent Smart Home AI Dashboard & Local Gateway for Home Assistant**

[![Release](https://img.shields.io/github/v/release/orkestrasmarthome/orkestra-ha-addon?include_prereleases&sort=semver&color=C1A37F&label=release)](https://github.com/orkestrasmarthome/orkestra-ha-addon/releases)
[![amd64](https://img.shields.io/badge/amd64-supported-2ea44f)](https://github.com/orkestrasmarthome/orkestra-ha-addon)
[![aarch64](https://img.shields.io/badge/aarch64-supported-2ea44f)](https://github.com/orkestrasmarthome/orkestra-ha-addon)
[![License](https://img.shields.io/github/license/orkestrasmarthome/orkestra-ha-addon?color=6e6e6e)](https://github.com/orkestrasmarthome/orkestra-ha-addon)
[![Home Assistant Add-on](https://img.shields.io/badge/Home%20Assistant-Add--on-41BDF5?logo=home-assistant&logoColor=white)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Forkestrasmarthome%2Forkestra-ha-addon)

<br />

[![Add repository to My Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Forkestrasmarthome%2Forkestra-ha-addon)

</div>

---

Orkestra runs **inside your Home Assistant** as a local brain and gateway: a modern dashboard, natural-language control, and a secure path to the Orkestra cloud when you are away.

## Installation

### Method 1 — One-click (recommended)

1. Click **Add repository to My Home Assistant** above (or use this link):
   [Open the add-on repository dialog](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Forkestrasmarthome%2Forkestra-ha-addon)
2. Confirm the repository URL, then continue to **Install** → **Start**.
3. Follow **Connect & pair** in Method 2, step 4.

> **Tip:** If the My Home Assistant button does not open your instance, use Method 2. You need Home Assistant OS or Supervised with the Add-on Store.

### Method 2 — Manual

#### 1. Add Store

In Home Assistant, go to **Settings → Add-ons → Add-on Store → Repositories (⋮)** and paste:

```text
https://github.com/orkestrasmarthome/orkestra-ha-addon
```

#### 2. Install

Locate **Orkestra** in the store and click **Install**.

#### 3. Start

Enable **Start on boot**, then start the add-on.

> **Tip:** Home Assistant cannot turn **Auto-update** on for you. Enable it on the add-on info page if you want upgrades applied automatically.

#### 4. Connect & Pair

Click **Open Web UI**, copy your unique pairing code, and follow the [Orkestra Setup Guide](https://orkestra-assistant.com/docs/home-assistant-addon) to link your home.

1. Sign in at [orkestra-assistant.com](https://orkestra-assistant.com) (or the Orkestra mobile app).
2. Create a home or open the pairing flow.
3. Enter the pairing code from the add-on Web UI.

> **Tip:** You can also open Orkestra from the Home Assistant sidebar after it is running (`ingress`). Home Assistant API access is configured automatically — no long-lived access token is required for normal use.

## Key features

- **Local-first execution** — Control stays on your LAN when you are at home (fast-path to the add-on).
- **AI-driven automations** — Natural-language chat that can inspect state and help you create real Home Assistant automations.
- **Unified media & climate** — One dashboard for rooms, playback, climate, and everyday devices.
- **Secure outbound cloud relay** — Reach your home from the web portal or mobile app without opening inbound ports.

## Support & links

- **Web app:** [orkestra-assistant.com](https://orkestra-assistant.com)
- **Orkestra Setup Guide:** [orkestra-assistant.com/docs/home-assistant-addon](https://orkestra-assistant.com/docs/home-assistant-addon)
- **Support:** [support@orkestra-assistant.com](mailto:support@orkestra-assistant.com)
- **This store:** [github.com/orkestrasmarthome/orkestra-ha-addon](https://github.com/orkestrasmarthome/orkestra-ha-addon)

---

<details>
<summary><strong>Technical & developer details</strong></summary>

<br />

This repository is the **public Home Assistant Add-on Store** for Orkestra. Supervisor requires store repositories to be public so users can install from **Settings → Add-ons → Add-on Store**.

**No application source code** is published here. The runtime is built from the private [`orkestra`](https://github.com/orkestrasmarthome/orkestra) monorepo and published to GHCR.

| Path | Purpose |
|------|---------|
| `repository.yaml` | Registers this repo as an HA add-on store |
| `orkestra/config.yaml` | Production add-on manifest (version, image, options) |
| `orkestra/icon.png`, `orkestra/logo.png` | Store branding |
| `scripts/` | Manifest validation and GHCR image verification |

### Container image

Supervisor pulls prebuilt images:

```text
ghcr.io/orkestrasmarthome/orkestra-core-{arch}:{version}
```

Architectures: **amd64**, **aarch64**.

### How manifests are updated

The private monorepo CI (`.github/workflows/build-addon.yml`) builds Docker images on release, then uses `ADDON_UPDATE_TOKEN` to copy `services/brain-gateway/config.yaml` into `orkestra/config.yaml` here and push.

Manual edits to `orkestra/config.yaml` may be overwritten on the next release.

New installs default to **Start on boot** (`boot: auto`) and expose an Ingress sidebar entry (`panel_title: Orkestra`). Auto-update remains a Supervisor user preference.

See [ARCHITECTURE.md](ARCHITECTURE.md) for store topology.

</details>
