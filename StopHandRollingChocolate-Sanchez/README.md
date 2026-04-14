# Stop Hand-Rolling Chocolate

**Speaker:** Gilbert Sanchez ([@HeyItsGilbert](https://github.com/HeyItsGilbert))
**Subtitle:** Automating Chocolatey with psake

## Abstract

Chocolatey packages are just PowerShell — so why are we still hand-crafting them one ticket at a time? This session walks through turning a fragile, README-driven release process into a declarative, tested, auto-publishing pipeline built on psake.

We'll cover the Chocolatey mental model (a nuspec and a PowerShell script — that's it), extensions and hooks for centralizing org-wide logic, and a live demo that goes from a blank repo to a published, CI-backed package in about twenty minutes. Along the way: the "Brazil story" for why CDN routing belongs in an extension, and why `Invoke-psake` running locally should be the exact same thing CI runs.

## Key Take-Aways

- A Chocolatey package is just a nuspec + a PowerShell script — no magic.
- Extensions and hooks let you put org-wide logic in one place, not scattered across install scripts.
- psake turns "README and hope" into declared, dependency-ordered tasks.
- The same `build.ps1` runs locally and in CI — no drift.
- Automation pays off at 5 packages as well as 500.

## Contents

- `README.md` — this file
- `slides/` — PPTX, PDF, HTML exports plus Marp markdown source, theme, and referenced assets
- `demo/demoScript.ps1` — the live-demo driver script

## Source

Built with [Marp](https://marp.app) from the `StopHandRollingChocolate` branch of [HeyItsGilbert/PSSummit2026](https://github.com/HeyItsGilbert/PSSummit2026/tree/StopHandRollingChocolate).
