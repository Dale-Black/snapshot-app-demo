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
                "A Therapy app published with Snapshot."),
            P(:class => "mt-5 text-lg text-base-content/70 max-w-xl mx-auto leading-relaxed",
                "This site is built as static HTML in GitHub Actions. Its supported Julia interactions run in the browser, and the Play page embeds a notebook published from another repository."),
            Div(:class => "mt-8 flex items-center justify-center gap-3",
                A(:href => "$(_BASE)/play", :class => "btn btn-primary", "Open the Play page →"),
                A(:href => "$(_BASE)/guestbook", :class => "btn btn-ghost", "Open the guestbook"))),
        Div(:class => "grid sm:grid-cols-2 lg:grid-cols-4 gap-5",
            feature("⌁", "Interactive (WASM)", "Real Julia notebooks compiled to WebAssembly, running entirely in the visitor's browser."),
            feature("⛁", "Direct data access", "The guestbook calls a Supabase project directly, with access controlled by database policies."),
            feature("◴", "Published output", "Snapshot serves the completed build from Cloudflare."),
            feature("✦", "Repository driven", "A push runs the repository's configured build and publish workflow.")),
        Div(:class => "a-card bg-base-100 rounded-box p-8 sm:p-10",
            H2(:class => "a-display text-2xl font-bold text-base-content", "Static pages, browser-side interaction."),
            P(:class => "mt-3 text-base-content/70 max-w-2xl leading-relaxed",
                "There is no continuously running Julia application process for these pages. Therapy builds the HTML, supported interactions run as WebAssembly, and the guestbook calls Supabase under row-level database policies."),
            Div(:class => "mt-6 flex flex-wrap gap-2",
                Span(:class => "badge badge-lg", "Therapy.jl"),
                Span(:class => "badge badge-lg", "WebAssembly"),
                Span(:class => "badge badge-lg", "Cloudflare"),
                Span(:class => "badge badge-lg", "Supabase"))))
end
Index
