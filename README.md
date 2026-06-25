# Therapy × Snapshot Demo

A live demo of what you can build **for free** with a [Therapy](https://github.com/GroupTherapyOrg/Therapy.jl)
web app hosted on **[Snapshot](https://snapshot.show)**:

- **Interactive pages** (WebAssembly, runs in the browser)
- An **embedded live Julia notebook**
- A **real database** (guestbook) called straight from a static site — no backend
- All on Cloudflare's edge, all on free tiers

It's a static Therapy app (`julia app.jl build` → HTML), published to the edge by
Snapshot. Connect a repo to Snapshot and ship your own.

---

## ⚠️ Reusing this as a template? Read this first.

This repo is meant to be copied, so here's exactly **what makes the guestbook safe**
— and where people usually get it wrong. The guestbook page talks to Supabase
**directly from the browser**. That's fine *only* because of how it's set up. The
short version:

**1. The key in the browser is the *public* `anon` key — and that's by design.**
The `anon` key is meant to be shipped to clients. It is **not** a secret; it grants
nothing on its own. Your safety comes from Row-Level Security + database functions,
**never** from hiding the key.
👉 **Never** put the `service_role` key (or any service/secret key) in client code.
It bypasses RLS and would let anyone do anything. In this repo the only key that
ever reaches the browser is `window.DEMO_SB.key`, and it must be the `anon` key.

**2. The browser can't write to the table directly.**
`anon` has **no** insert/update/delete on `demo_guestbook`. All writes go through two
`SECURITY DEFINER` functions (`add_guestbook`, `delete_guestbook`) — see
[`db.sql`](./db.sql). Because the table grants are locked down, a hand-crafted request
straight to the REST API can't skip the rules; the functions are the only door.

**3. The functions enforce every limit server-side** (a malicious client can't opt out):
- message length capped (280 chars), name capped (40)
- per-IP rate limit (3/min, 20/day) so it can't be flooded
- a hard **500-row total cap** — the oldest rows are pruned, so storage is bounded
- IPs and delete-tokens are only ever stored as **salted SHA-256 hashes**

**4. You can delete only your *own* messages.**
Each browser holds a random token in `localStorage` (it identifies nobody). The server
stores only its hash. `delete_guestbook` removes a row only if your token's hash
matches — so no one can delete someone else's note.

**5. Reads expose nothing sensitive.**
`anon` can `SELECT` only `(id, name, message, created_at)` via a column-level grant —
the IP and owner hashes are never readable. And the UI HTML-escapes every name and
message, so a message can't inject script.

**If you copy this pattern:** run [`db.sql`](./db.sql) in your Supabase SQL editor,
put your project URL + **anon** key in `window.DEMO_SB` (in
`src/routes/guestbook.jl`), and you're done. Leave those blank and the page falls back
to a local-only demo. Don't loosen the table grants or add a broad `insert`/`delete`
RLS policy — that's what keeps it safe.

## ⚠️ Inline page scripts + the client router (the `__therapy` marker)

Therapy ships a **client router** (View Transitions): clicking a navbar link swaps
only the `#page-content` region instead of doing a full page load. **Browsers do not
run `<script>` tags that arrive through that kind of DOM swap.** So a page that wires
itself up with an inline `<script>` (like the guestbook) will work on a hard refresh
but be **inert when you navigate to it from another tab** — a confusing "it's dead
until I reload" bug.

The fix (see `src/routes/guestbook.jl`): put the literal token **`__therapy`** in a
comment inside your script. The router scans swapped-in content for that token and
**re-executes** matching scripts. Pair it with a generation counter so any in-flight
async work from a previous run bails:

```js
(function(){
  /* __therapy  ← makes the client router re-run this after a navigation swap */
  var GEN = (window.__myGen = (window.__myGen || 0) + 1);
  // ... in async callbacks: if (GEN !== window.__myGen) return;
})();
```

Scripts in the persistent shell (header/footer, outside `#page-content`) don't need
this — they run once and stay. Only per-page inline scripts do.
