cd(@__DIR__)
using Therapy
app = App(
    routes_dir = "src/routes",
    components_dir = "src/components",
    title = "Therapy × Snapshot",
    layout = :Layout,
    output_dir = "dist",
    tailwind = false,  # CSS built by npm Tailwind + DaisyUI (see build.sh)
)
Therapy.run(app)
