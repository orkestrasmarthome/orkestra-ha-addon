# Branding Asset Checklist

Replace the placeholder add-on store images in this directory with final, high-quality brand assets before the next store release.

## Required files

- [ ] **`icon.png`**
  - **Purpose:** Add-on icon in the Home Assistant Add-on Store and sidebar.
  - **Spec:** High-resolution **1:1** aspect ratio (e.g. **512×512** px).
  - **Look:** Minimalist Orkestra mark aligned with the glassmorphism product identity — clean, readable at small sizes.

- [ ] **`logo.jpeg`** (or **`logo.png`**)
  - **Purpose:** Banner at the top of the add-on detail page in the store.
  - **Spec:** Wider banner format — **2:1** or **16:9** aspect ratio (e.g. **1280×640** or **1920×1080** px).
  - **Look:** Hero-style branding that matches the dashboard aesthetic; avoid tiny text that won’t read in the HA UI.

## How to apply

1. Export final assets from the design source (Figma, etc.).
2. Overwrite the existing files in this folder:
   - `orkestra/icon.png`
   - `orkestra/logo.jpeg` (or rename to `logo.png` only if you also update references elsewhere)
3. Commit and push to `orkestra-ha-addon`.
4. **Delete this file (`ASSETS_TODO.md`)** once both assets are in place.
