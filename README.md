[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/microweber?utm_medium=integration&utm_source=button&utm_campaign=microweber)

# Deploy and Host Microweber on Railway

Microweber is an open-source (MIT) drag-and-drop website builder and CMS written in PHP on Laravel. You edit pages live on the page itself, and it includes a blog, an online shop with products, orders and payments, a media library, multilingual content and SEO settings. This template deploys Microweber 2.0.21.

## About Hosting Microweber

Microweber needs PHP 8.4 with Apache, a MySQL database and disk space for its settings, uploads and caches. This template builds Microweber 2.0.21 from the pinned upstream release on the official `php:8.4-apache` image and runs Railway's MySQL next to it on the private network. On the first boot the start script waits for MySQL, installs Microweber with the default theme and sample content, and creates the admin user from generated variables, so no setup wizard is left open to the public. Settings, uploads and caches live on a volume at `/data`, and the database on MySQL's own volume. Updating means redeploying a newer version of this template.

## Common Use Cases

* Company, portfolio or landing-page websites that non-technical people edit with drag and drop
* A small online shop with products, cart, checkout and order management
* A blog or news site with categories, comments and SEO settings

## Dependencies for Microweber Hosting

* MySQL 8 (Railway's MySQL service, included)
* A Railway volume for Microweber's settings, uploads and caches (included)

### Deployment Dependencies

* Microweber: https://github.com/microweber/microweber (release v2.0.21)
* Official PHP image: https://hub.docker.com/_/php (`8.4.28-apache-trixie`, pinned by digest)
* Template source: https://github.com/aalfath/microweber-railway-template

### Implementation Details

**Services**

| Service | What it does |
|---|---|
| `Microweber` (public) | Apache + PHP 8.4 with Microweber 2.0.21 on port 8080. Health check `/healthz`. Volume at `/data` (settings in `config/microweber.php`, `storage/`, uploads in `userfiles/media`, theme CSS and language files). |
| `MySQL` | Railway's MySQL 8 with its own volume. Holds all pages, products, orders and users. Started with a 128 MB InnoDB buffer pool so it fits small plans. |

**After deploying**

1. Open the `Microweber` service's public URL. The first boot takes about a minute while it installs.
2. Sign in at `https://YOUR-DOMAIN/admin` with the user `admin` and the password in the `ADMIN_PASSWORD` variable of the `Microweber` service.
3. Change the admin email and password under **Users**, then set your site name under **Settings**.
4. For email (contact forms, order mails, password resets), add your SMTP server under **Settings > Email**.

**Variables**

| Variable | Default | What it is |
|---|---|---|
| `ADMIN_USERNAME` | `admin` | Username of the first admin, created on the first boot only. |
| `ADMIN_PASSWORD` | generated | Password of the first admin, created on the first boot only. Change it in the admin panel afterwards; changing the variable later doesn't change it. |
| `APP_KEY` | generated (32 characters) | Laravel encryption key for sessions and cookies. Keep it unchanged, or everyone is signed out. |
| `DB_*` | references to `MySQL` | Database connection over the private network. |
| `APACHE_MAX_WORKERS` | `8` (not set) | Optional: more Apache workers for busy sites on larger plans (each uses about 30–60 MB). |

**Resources.** Tested with 0.5 GB RAM and 1 vCPU per service: Microweber peaked at about 150 MB and MySQL at about 265 MB, so the template runs on Railway's smallest plans.

**Updates.** Railway shows an update notice when this template's repository gets a new version. Read `CHANGELOG.md` first, take a volume backup of both services, then apply it: on start the image runs Microweber's database update step once for the new version. Microweber's built-in updater would change files inside the container that a redeploy replaces, so update through the template instead.

**Left out.** The optional premium "Big" theme (downloaded from Microweber's own package server) isn't bundled; the default theme is. You can add themes and modules from the admin panel's marketplace, but files installed that way live in the container and are lost on the next deploy.

## Why Deploy Microweber on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Microweber on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
