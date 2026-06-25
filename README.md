# Therapy × Snapshot Demo

A live demo of what you can build **for free** with a [Therapy](https://github.com/GroupTherapyOrg/Therapy.jl)
web app hosted on **[Snapshot](https://snapshot.djblack.workers.dev)**:

- **Interactive pages** (WebAssembly, runs in the browser)
- An **embedded live Julia notebook**
- A **real database** (guestbook) called straight from a static site — no backend
- All on Cloudflare's edge, all on free tiers

It's a static Therapy app (`julia app.jl build` → HTML), published to the edge by
Snapshot. The guestbook talks directly to a free Supabase database, locked down with
row-level security — see `db.sql`. Connect a repo to Snapshot and ship your own.
