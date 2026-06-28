const _BASE = get(ENV, "SNAPSHOT_BASE_PATH", "")

function _step(n, title, body)
    Div(:class => "flex gap-4",
        Div(:class => "shrink-0 w-9 h-9 rounded-xl bg-primary/10 text-primary a-display font-bold flex items-center justify-center", "$(n)"),
        Div(H3(:class => "a-display font-semibold text-base-content", title),
            P(:class => "text-sm text-base-content/70 leading-relaxed mt-0.5", body)))
end

function About()
    Div(:class => "max-w-2xl space-y-10",
        Div(H1(:class => "a-display text-3xl sm:text-4xl font-bold text-base-content", "All of this, for \$0."),
            P(:class => "mt-3 text-base-content/70 leading-relaxed",
                "This site has no server, no container, nothing to keep running — and it's still interactive, with a real database. Here's the whole stack:")),
        Div(:class => "space-y-6",
            _step(1, "Therapy builds the pages", "Your app is plain Julia. Therapy renders it to static HTML at build time — fast, cacheable, indexable."),
            _step(2, "WebAssembly makes it live", "Interactive bits (and whole Julia notebooks) compile to WASM and run in the visitor's browser. No server doing the work."),
            _step(3, "Snapshot hosts it on the edge", "Push to GitHub; Snapshot builds it in your own Actions and serves it from Cloudflare's global edge. Scales to zero, costs nothing."),
            _step(4, "The browser talks to a free database", "Need sign-in or persistence? The page calls a free edge database (Supabase) directly, locked down with row-level security. Still no backend of your own.")),
        Div(:class => "a-card bg-base-100 rounded-box p-6",
            P(:class => "text-base-content/80 leading-relaxed",
                "It's the exact recipe behind Snapshot itself — a full dashboard with GitHub login and a database, running entirely on free tiers. Now it's yours: connect a repo and ship."),
            Div(:class => "mt-5 flex gap-3",
                A(:href => "https://snapshot.show", :target => "_blank", :class => "btn btn-primary btn-sm", "Try Snapshot ↗"),
                A(:href => "$(_BASE)/", :class => "btn btn-ghost btn-sm", "Back home"))))
end
About
