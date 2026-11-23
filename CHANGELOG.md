# Changelog

Each entry lists breaking changes first. Take a volume backup of both services before applying an update.

## 2.0.21 (2026-11-23)

First version of this template.

- Microweber 2.0.21 (security release of 2026-11-19), built from upstream commit `4ac62cc` on `php:8.4.28-apache-trixie@sha256:3550aedd…7c9688`.
- Railway MySQL 8 with a 128 MB InnoDB buffer pool.
- First boot installs Microweber non-interactively and creates the admin from `ADMIN_USERNAME` / `ADMIN_PASSWORD`; no public setup wizard.
- Settings, storage and uploads on a volume at `/data`; on a version change the start script runs Microweber's database update once.
- Fits 0.5 GB RAM / 1 vCPU per service (8 Apache workers, PHP memory limit 256 MB).
