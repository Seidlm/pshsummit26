# Lost in Translation — PowerShell Summit 2026

**Speaker:** Josh Corrick

This session explores **Constrained Language Mode (CLM)** in PowerShell — what it restricts, how to write compliant code, and how to integrate CLM checks into your development workflow using AI agents, linting, testing, and code signing.

## What is Constrained Language Mode?

CLM is a PowerShell security feature that limits available types, commands, and language features. It is enforced in Application Control environments (WDAC, AppLocker), JEA endpoints, and other hardened configurations. Scripts that rely on disallowed features (custom classes, arbitrary .NET calls, `Add-Type`, unapproved COM objects, etc.) will fail under CLM.

## Demo Structure

### 1 — AI Agents (`demo/1-Ai/`)

Demonstrates using AI agents to author and review CLM-compliant PowerShell code.

- **[Agents.md](demo/1-Ai/Agents.md)** — A comprehensive CLM compliance guide designed for AI agents, including allowed/disallowed types, module manifest rules, and a step-by-step review algorithm.
- **MySignedModule** — A signed example module that intentionally uses CLM-incompatible features (custom `class`, `enum`, dot-sourcing an unsigned file) to show how signing interacts with CLM enforcement.

### 2 — Linting (`demo/2-Lint/`)

Shows how to use **PSScriptAnalyzer** (v1.25.0+) with the `PSUseConstrainedLanguageMode` rule to statically detect CLM violations before runtime.

- **[PSScriptAnalayzer.ps1](demo/2-Lint/PSScriptAnalayzer.ps1)** — Invokes the analyzer against the sample scripts.
- **[NotAllowed.ps1](demo/2-Lint/NotAllowed.ps1)** — Contains violations such as `[math]::Round()`, `[PSCustomObject]@{}`, dot-sourcing, COM objects (`WScript.Shell`), and `Add-Type` with P/Invoke.
- **[AlsoNotAllowed.ps1](demo/2-Lint/AlsoNotAllowed.ps1)** — Uses custom classes, enums, and disallowed type casts.

### 3 — Testing (`demo/3-Test/`)

Validates module behavior under CLM at runtime using **Pester** tests in an isolated constrained runspace.

- **[MyModule.CLM.Tests.ps1](demo/3-Test/tests/MyModule.CLM.Tests.ps1)** — Pester tests that create a constrained-language runspace, import the module, and verify that restricted operations (COM creation, `Add-Type`) are correctly blocked.
- **MyModule** — An unsigned module with functions that exercise CLM boundaries (`Test-LanguageMode`, `Test-Com`, `Test-Win32`). The manifest intentionally uses wildcards (`*`) in export fields to demonstrate a common CLM anti-pattern.

### 4 — Signing (`demo/4-Signing/`)

Covers code signing basics and how signing affects CLM enforcement.

- **[Signing.ps1](demo/4-Signing/Signing.ps1)** — Creates a self-signed code-signing certificate, signs a script, and verifies the signature with `Get-AuthenticodeSignature`.
- **[NotAllowed.ps1](demo/4-Signing/NotAllowed.ps1)** — A signed script demonstrating features that fail under CLM (classes, disallowed methods, dot-sourcing, `Invoke-Expression`).

## Slides

Presentation slides are available in the `slides/` directory in PDF and PPTX formats.

## Key Takeaways

- **Know the allowed types** — CLM permits ~70 types; everything else is blocked for unsigned code.
- **Lint early** — Use `PSScriptAnalyzer` with `PSUseConstrainedLanguageMode` to catch issues statically.
- **Test in a constrained runspace** — Validate behavior at runtime before deploying to locked-down environments.
- **Sign your code** — Signed scripts bypass most CLM restrictions, but manifest rules and dot-sourcing checks still apply.
- **Leverage AI agents** — Use agent prompts and the CLM reference guide to generate and review compliant code.
