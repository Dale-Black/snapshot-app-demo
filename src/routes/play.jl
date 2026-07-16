function Play()
    Div(:class => "space-y-8",
        Div(:class => "max-w-2xl",
            Span(:class => "badge badge-secondary badge-outline mb-3", "interactive"),
            H1(:class => "a-display text-3xl sm:text-4xl font-bold text-base-content", "Live, in your browser."),
            P(:class => "mt-3 text-base-content/70 leading-relaxed",
                "Below is a Julia notebook embedded in this page. Drag the slider; supported Julia cells recompute in WebAssembly. No Julia server handles the interaction.")),
        Div(:class => "a-card bg-base-100 rounded-box overflow-hidden",
            RawHtml("""<iframe src="https://snapshot.show/app/Dale-Black/snapshot-demo/demo/" title="Live notebook" style="width:100%;height:540px;border:0;display:block"></iframe>""")),
        P(:class => "text-sm text-base-content/60",
            "This notebook lives in a different repo and is published by Snapshot too — your app can embed any of them. Want a whole collection with a sidebar? Snapshot builds that automatically from a repo of notebooks."))
end
Play
