const _BASE = get(ENV, "SNAPSHOT_BASE_PATH", "")  # Snapshot sub-path; "" at the root

function Layout(children...; title="Therapy × Snapshot")
    Fragment(
        RawHtml("""<link rel="stylesheet" href="$(_BASE)/styles.css">"""),
        RawHtml("""<script>(function(){try{var t=localStorage.getItem('demo-theme');if(!t){t=(window.matchMedia&&matchMedia('(prefers-color-scheme: dark)').matches)?'aurora-dark':'aurora';}document.documentElement.setAttribute('data-theme',t);}catch(e){}})();</script>"""),
        RawHtml("""<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">"""),
        Div(:class => "min-h-screen flex flex-col",
            Header(:class => "sticky top-0 z-20 border-b border-base-300 bg-base-100/80 backdrop-blur",
                Div(:class => "max-w-5xl mx-auto px-5 h-16 flex items-center justify-between",
                    A(:href => "$(_BASE)/", :class => "flex items-center gap-2.5 group",
                        RawHtml("""<svg width="24" height="24" viewBox="0 0 24 24" fill="none" class="transition-transform group-hover:rotate-12"><path d="M12 2l2.6 6.8L22 11l-7.4 2.2L12 20l-2.6-6.8L2 11l7.4-2.2z" fill="url(#g)"/><defs><linearGradient id="g" x1="0" y1="0" x2="24" y2="24"><stop stop-color="#6d5efc"/><stop offset="1" stop-color="#00bfae"/></linearGradient></defs></svg>"""),
                        Span(:class => "a-display text-lg font-bold text-base-content", "Therapy × Snapshot")),
                    Nav(:class => "flex items-center gap-0.5",
                        A(:href => "$(_BASE)/play", :class => "btn btn-ghost btn-sm", "Play"),
                        A(:href => "$(_BASE)/guestbook", :class => "btn btn-ghost btn-sm", "Guestbook"),
                        A(:href => "$(_BASE)/about", :class => "btn btn-ghost btn-sm hidden sm:inline-flex", "About"),
                        RawHtml("""<button id="theme-toggle" class="btn btn-ghost btn-sm btn-circle" title="Toggle theme" aria-label="Toggle theme"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/></svg></button>"""))) ),
            MainEl(:id => "page-content", :class => "flex-1 w-full max-w-5xl mx-auto px-5 py-12 sm:py-16", children...),
            Footer(:class => "border-t border-base-300",
                Div(:class => "max-w-5xl mx-auto px-5 py-8 text-sm text-base-content/60 flex flex-wrap gap-3 justify-between items-center",
                    Span("Built with Therapy.jl · hosted free on the edge by Snapshot"),
                    A(:href => "https://snapshot.djblack.workers.dev", :target => "_blank", :class => "link link-hover", "Snapshot ↗")))),
        RawHtml("""<script>(function(){var b=document.getElementById('theme-toggle');if(b)b.addEventListener('click',function(){var c=document.documentElement.getAttribute('data-theme');var n=(c==='aurora-dark')?'aurora':'aurora-dark';document.documentElement.setAttribute('data-theme',n);try{localStorage.setItem('demo-theme',n)}catch(e){}});})();</script>"""),
    )
end
Layout
