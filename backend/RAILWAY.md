# Deploying the Caffora backend to Railway

The backend runs on Railway as two services in one project: a **MySQL** database and the
**backend**, which Railway builds from `backend/Dockerfile`. The web frontend is deployed
separately on Vercel.

This file only names the variables. Never commit real values: generate them and paste
them into the Railway or Vercel dashboard.

Local development doesn't change: `docker compose up --build` in `backend/` still reads `backend/.env`.

---

## 1. MySQL service

1. In your Railway project, choose **New → Database → MySQL**.
2. Railway provisions it and exposes these variables on the service (named `MySQL` below):
   `MYSQLHOST`, `MYSQLPORT`, `MYSQLDATABASE`, `MYSQLUSER`, `MYSQLPASSWORD`.
3. You don't need to create any tables. With `DDL_AUTO=update`, Hibernate creates and
   updates the tables from the JPA entities when the backend starts.

## 2. Backend service

1. Choose **New → GitHub Repo** and pick this repository.
2. In **Settings → Source**, set **Root Directory** to `backend`.
   Railway detects `backend/Dockerfile` and builds with it.
3. Under **Settings → Networking**, click **Generate Domain** to get a public URL such as
   `https://<your-backend>.up.railway.app`.
4. Railway sets `PORT` automatically. `application.yml` reads
   `server.port: ${PORT:${SERVER_PORT:8080}}`, so you don't set it yourself.
5. Add the variables from section 3, then deploy.

## 3. Backend environment variables

Set these on the **backend** service under the **Variables** tab.

### Required: set every one of these before the first deploy

A missing `DB_*` or `JWT_SECRET` stops the app at startup. A missing `ADMIN_SEED_PASSWORD` does
**not**: on a fresh database the admin account would be created with the unresolved text
`${ADMIN_SEED_PASSWORD}` as its password. Double-check it is set.

| Variable | Value |
|---|---|
| `DB_HOST` | `${{MySQL.MYSQLHOST}}` |
| `DB_PORT` | `${{MySQL.MYSQLPORT}}` |
| `DB_NAME` | `${{MySQL.MYSQLDATABASE}}` |
| `DB_USERNAME` | `${{MySQL.MYSQLUSER}}` |
| `DB_PASSWORD` | `${{MySQL.MYSQLPASSWORD}}` |
| `JWT_SECRET` | A new random secret, e.g. from `openssl rand -base64 48`. Don't reuse one from `.env` or git history. |
| `ADMIN_SEED_PASSWORD` | A strong password for the admin account created on first startup |
| `CORS_ALLOWED_ORIGINS` | See section 4 |

`${{MySQL.…}}` is Railway's reference syntax. It pulls the value from the MySQL service,
so no database password is ever pasted by hand. If you renamed the MySQL service, use that
name instead of `MySQL`.

### Optional

| Variable | Default | Notes |
|---|---|---|
| `ADMIN_SEED_EMAIL` | `admin@caffora.com` | Email for the seeded admin account |
| `ADMIN_SEED_NAME` | `System Admin` | |
| `JWT_EXPIRATION_MS` | `86400000` (24h) | |
| `DDL_AUTO` | `update` | Keep `update` so new tables (e.g. `reviews`) are created |
| `SHOW_SQL` | `false` | |
| `LOGGING_LEVEL_COM_CAFFORA_BACKEND` | `DEBUG` | Set to `INFO` in production |

The admin account is only created when no admin exists yet. Sign in and change its password
after the first deploy.

## 4. CORS

`CORS_ALLOWED_ORIGINS` is a comma-separated list of the web origins allowed to call the API.
Entries may contain `*`, which is needed for Vercel preview URLs. Set exactly:

```
CORS_ALLOWED_ORIGINS=https://caffora.vercel.app,https://caffora-*.vercel.app
```

- No spaces, no quotes, no trailing slashes, and `https://`.
- If Vercel gives the project a different production domain (e.g. because `caffora` is already
  taken), replace both entries to match it.
- Add any custom domain you attach later, e.g. `https://www.caffora.com`.
- Don't add `localhost` in production. Locally the default `http://localhost:5173,http://localhost:3000`
  still applies, since docker-compose sets it.
- A bare `*`, or an entry like `https://*`, stops the app at startup. Credentials are enabled, so
  a wildcard would let every website make credentialed requests.
- `*` matches any characters, so `https://caffora-*.vercel.app` also matches other people's Vercel
  projects whose names start with `caffora-`. That's low risk here, because the API authenticates
  with a bearer token that browsers never send cross-site on their own (no cookies). Once you know
  your Vercel team slug, you can narrow it to `https://caffora-*-<team-slug>.vercel.app`.

## 5. Health check

In the backend service, open **Settings → Deploy → Healthcheck Path** and set:

```
/actuator/health
```

- Returns `200 {"status":"UP"}` once the app is running and can reach MySQL.
- If MySQL can't be reached, it returns `503`, so a broken deploy never goes live.
- It's public, shows no internal details, and is the only Actuator endpoint exposed.

## 6. Vercel (web frontend)

When importing the repo into Vercel, set **Root Directory** to `web`.

| Variable | Value |
|---|---|
| `VITE_API_URL` | `https://<your-backend>.up.railway.app/api` |

- Vite bakes `VITE_API_URL` in at build time, so **redeploy** the frontend after changing it.
- Then add the Vercel URL(s) to `CORS_ALLOWED_ORIGINS` on Railway (section 4).
- Product images (`/images/...`) are served by Vercel from `web/public/images`. The database
  stores only these paths, so the images need no extra setup.
- The app uses client-side routing (`BrowserRouter`). If refreshing a page like `/menu` gives
  a Vercel 404, add a `web/vercel.json` rewrite that sends all paths to `/index.html`.

## 7. Checking the deploy

```
curl https://<your-backend>.up.railway.app/actuator/health      # {"status":"UP"}
curl https://<your-backend>.up.railway.app/api/products         # 200, product list
curl https://<your-backend>.up.railway.app/api/reviews          # 200, public
curl -X POST https://<your-backend>.up.railway.app/api/reviews  # 401 (login required)
```
