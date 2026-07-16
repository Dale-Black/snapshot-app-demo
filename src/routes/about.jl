const _BASE = get(ENV, "SNAPSHOT_BASE_PATH", "")

function _step(n, title, body)
    Div(:class => "flex gap-4",
        Div(:class => "shrink-0 w-9 h-9 rounded-xl bg-primary/10 text-primary a-display font-bold flex items-center justify-center", "$(n)"),
        Div(H3(:class => "a-display font-semibold text-base-content", title),
            P(:class => "text-sm text-base-content/70 leading-relaxed mt-0.5", body)))
end

function About()
    Div(:class => "max-w-2xl space-y-10",
        Div(H1(:class => "a-display text-3xl sm:text-4xl font-bold text-base-content", "How the pieces fit together."),
            P(:class => "mt-3 text-base-content/70 leading-relaxed",
                "Therapy builds the pages, Snapshot publishes the result, and supported interactions execute in the browser:")),
        Div(:class => "space-y-6",
            _step(1, "Therapy builds the pages", "Your app is plain Julia. Therapy renders it to static HTML at build time — fast, cacheable, indexable."),
            _step(2, "WebAssembly makes it live", "Supported interactive components and notebook cells compile to WebAssembly and run in the visitor's browser."),
            _step(3, "Snapshot publishes the build", "A push runs the configured GitHub Actions workflow, then Snapshot serves the completed output from Cloudflare."),
            _step(4, "The browser talks to the database", "The guestbook calls Supabase directly, with access constrained by database grants and functions.")),
        Div(:class => "a-card bg-base-100 rounded-box p-6",
            P(:class => "text-base-content/80 leading-relaxed",
                "This repository is a compact example of Therapy routes, browser-side islands, an embedded Snapshot notebook and direct database access."),
            Div(:class => "mt-5 flex gap-3",
                A(:href => "https://snapshot.show", :target => "_blank", :class => "btn btn-primary btn-sm", "Try Snapshot ↗"),
                A(:href => "$(_BASE)/", :class => "btn btn-ghost btn-sm", "Back home"))))
end
About
