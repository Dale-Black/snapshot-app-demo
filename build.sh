#!/usr/bin/env bash
# Build this Therapy app to dist/. Snapshot's app mode runs this in CI.
set -euo pipefail
cd "$(dirname "$0")"
julia --project=. app.jl build
npm i
npx @tailwindcss/cli -i input.css -o dist/styles.css --minify
