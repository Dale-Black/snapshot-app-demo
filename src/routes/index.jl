const _BASE = get(ENV, "SNAPSHOT_BASE_PATH", "")

function feature(icon, title, body)
    Div(:class => "a-card bg-base-100 rounded-box p-6 flex flex-col gap-3",
        RawHtml("""<div class="w-10 h-10 rounded-xl bg-primary/10 text-primary flex items-center justify-center">$(icon)</div>"""),
        H3(:class => "a-display text-lg font-semibold text-base-content", title),
        P(:class => "text-sm text-base-content/70 leading-relaxed", body))
end

function Index()
    Div(:class => "space-y-16",
        Div(:class => "a-hero rounded-box px-6 py-16 sm:py-24 text-center -mx-2",
            Span(:class => "badge badge-primary badge-outline mb-5", "a live Therapy app"),
            H1(:class => "a-display text-4xl sm:text-6xl font-bold text-base-content leading-[1.05] max-w-3xl mx-auto",
                "Look what you can build for free."),
            P(:class => "mt-5 text-lg text-base-content/70 max-w-xl mx-auto leading-relaxed",
                "This whole site is a Therapy app — interactive, with real data and live notebooks — built in GitHub and hosted on the edge by Snapshot. No server. No bill."),
            Div(:class => "mt-8 flex items-center justify-center gap-3",
                A(:href => "$(_BASE)/play", :class => "btn btn-primary", "See it run →"),
                A(:href => "$(_BASE)/guestbook", :class => "btn btn-ghost", "Try the database"))),
        Div(:class => "grid sm:grid-cols-2 lg:grid-cols-4 gap-5",
            feature("⌁", "Interactive (WASM)", "Real Julia notebooks compiled to WebAssembly, running entirely in the visitor's browser."),
            feature("⛁", "Real data, free", "A live database with sign-in and persistence — straight from a static site, no backend to run."),
            feature("◴", "On the edge", "Served from Cloudflare's global edge. Fast everywhere, scales to zero, costs nothing."),
            feature("✦", "Just a GitHub repo", "Push your code; Snapshot builds and publishes it. The exact stack that powers Snapshot itself.")),
        Div(:class => "a-card bg-base-100 rounded-box p-8 sm:p-10",
            H2(:class => "a-display text-2xl font-bold text-base-content", "Everything here is static — and yet…"),
            P(:class => "mt-3 text-base-content/70 max-w-2xl leading-relaxed",
                "There's no application server anywhere. The pages are plain HTML built by Therapy. The interactivity is WebAssembly. The database calls go straight from your browser to a free edge database, protected by row-level security. That's the whole trick — and it's the same way the Snapshot dashboard works."),
            Div(:class => "mt-6 flex flex-wrap gap-2",
                Span(:class => "badge badge-lg", "Therapy.jl"),
                Span(:class => "badge badge-lg", "WebAssembly"),
                Span(:class => "badge badge-lg", "Cloudflare edge"),
                Span(:class => "badge badge-lg", "Supabase"),
                Span(:class => "badge badge-lg badge-primary", "\$0 / month"))))
end
Index
