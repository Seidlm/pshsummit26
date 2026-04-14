# Agents.md — CLM Compliance Guide for AI Agents

## Overview

**Constrained Language Mode (CLM)** is a PowerShell security feature that restricts the types, commands, and language features available in a session. CLM is commonly used in:

- **Application Control environments** (Application Control for Business, AppLocker)
- **Just Enough Administration (JEA)** endpoints
- **Secure environments** requiring additional PowerShell restrictions

This document provides guidance for PowerShell developers on leveraging AI agents to assist with implementing and maintaining scripts that are compatible with CLM.

## Agent Roles

- **ScriptGenAgent**: Generates PowerShell scripts compatible with CLM restrictions. When generating code, always validate output against the CLM checklist (see below) before presenting it. Never produce code that uses disallowed features.
- **CLMReviewAgent**: Reviews scripts for compliance with CLM, highlighting disallowed features or risky patterns. Always read the full contents of every file in a module before making compliance judgments — do not guess based on file names alone.

## Example Prompts

- "Generate a PowerShell function to list running processes, ensuring compatibility with Constrained Language Mode."
- "Review this script and identify any commands or features not allowed in CLM."
- "Suggest alternatives for .NET method calls in this script to make it CLM-compliant."
- "Review the module manifest for CLM issues."
- "Is this module signed? If so, which CLM checks still apply?"

## CLM Quick Reference

### Allowed Types (~70 total)

| Category | Types |
|---|---|
| **Primitives** | string, int, int16, int32, int64, bool, byte, sbyte, char, datetime, decimal, double, float, long, short, single, uint, uint16, uint32, uint64, ulong, ushort, void |
| **Collections** | hashtable, array, arraylist, ordered |
| **PowerShell** | pscredential, psobject, pscustomobject (as type name only, NOT `[PSCustomObject]@{}`), pslistmodifier, psprimitivedictionary |
| **Security** | securestring, ObjectSecurity |
| **Utilities** | regex, guid, version, uri, xml, timespan, bigint, semver, cultureinfo, ipaddress, IPEndpoint, mailaddress, PhysicalAddress, WildcardPattern, NullString |
| **CIM/WMI** | cimclass, cimconverter, ciminstance, CimSession, cimtype, wmi, wmiclass, wmisearcher |
| **ADSI** | adsi, adsisearcher |
| **Certificates** | X500DistinguishedName, X509Certificate |
| **Module** | Microsoft.PowerShell.Commands.ModuleSpecification |
| **Attributes** | CmdletBinding, Parameter, OutputType, Alias, ValidateCount, ValidateDrive, ValidateLength, ValidateNotNull, ValidateNotNullOrEmpty, ValidateNotNullOrWhiteSpace, ValidatePattern, ValidateRange, ValidateScript, ValidateSet, ValidateTrustedData, ValidateUserDrive, SupportsWildcards, AllowEmptyCollection, AllowEmptyString, AllowNull, ArgumentCompleter, ArgumentCompletions, PSDefaultValue, PSTypeNameAttribute, DscLocalConfigurationManager, DscProperty, DscResource, Experimental, ExperimentAction, ExperimentalFeature, NoRunspaceAffinity |
| **Arrays** | Arrays of any allowed type are allowed (e.g., `[string[]]`, `[int[][]]`) |

> **Important:** Arrays of *disallowed* types (e.g., `[System.Net.WebClient[]]`) are still disallowed.

### Disallowed Types (examples)

- Most .NET types not in the allowed list (e.g., `System.Net.WebClient`, `System.IO.File`, `System.Console`)
- Custom PowerShell classes (the `class` keyword)
- `[PSCustomObject]@{}` — this uses type casting and is blocked in CLM
- Any type used as a type expression (`[Type]::Method()`), type cast (`[Type]$var`), variable type constraint, or in `New-Object -TypeName`

### Allowed COM Objects

- `Scripting.Dictionary`
- `Scripting.FileSystemObject`
- `VBScript.RegExp`

### Disallowed COM Objects

- All others (e.g., Excel.Application, WScript.Shell)

### Module Manifest Rules

- Do **not** use wildcards (`*`) in `FunctionsToExport`, `CmdletsToExport` — use explicit lists
- Do **not** use `.ps1` files in `RootModule` or `NestedModules` — use `.psm1` or `.dll`
- Do **not** use `ScriptsToProcess` — it loads in the caller's scope and will be blocked in CLM

### Other Disallowed Features

- `Add-Type` (code compilation)
- `Invoke-Expression` (restricted)
- XAML / WPF
- PowerShell `class` keyword

## Signature Handling and Enforcement

**Unsigned scripts:** All CLM restrictions are enforced.

**Signed scripts:** Only these checks are always enforced:
- Dot-sourcing restrictions
- Parameter type constraints (disallowed types in `param()` blocks)
- Module manifest best practices (no wildcards, no `.ps1` modules, no `ScriptsToProcess`)

**Note:** Signature detection via text block (`# SIG # Begin signature block`) does NOT validate authenticity. Always use `Get-AuthenticodeSignature` to verify signatures when possible. `Get-AuthenticodeSignature` will have a `Status` of `Valid` when code is properly signed.

## How to Review a Script or Module for CLM Compliance

### Step-by-Step Algorithm

1. **Identify file type:** `.ps1`, `.psm1`, or `.psd1`
2. **Check if signed:** Run `Get-AuthenticodeSignature` on the file
3. **If `.psd1` (module manifest):** Run manifest checks (always enforced, even for signed files):
   - No wildcards in export fields
   - No `.ps1` files in `RootModule`, `NestedModules`
   - No `ScriptsToProcess`
4. **If signed with a valid signature:** Run selective checks only:
   - Dot-sourcing restrictions
   - Parameter type constraints (disallowed types in `param()`)
   - Manifest best practices (if `.psd1`)
5. **If unsigned:** Run ALL checks:
   - `Add-Type` usage
   - Disallowed COM objects
   - Disallowed .NET types in: parameter constraints, variable constraints, `New-Object -TypeName`, type expressions (`[Type]::Method()`), type casts (`[Type]$var`), member invocations on typed variables
   - PowerShell `class` keyword
   - `[PSCustomObject]@{}` (type casting)
   - XAML/WPF
   - `Invoke-Expression`
   - Dot-sourcing
   - Manifest checks (if `.psd1`)
6. **For modules with multiple files:** Review ALL files — manifest + root module + nested modules + functions folder. Do not review individual files in isolation.
7. **Report findings** with the output format below.

### What to Scan For (Checklist)

| Pattern | Check | Enforced For |
|---|---|---|
| `Add-Type` | Not permitted | Unsigned only |
| `New-Object -ComObject <disallowed>` | Only 3 COM objects allowed | Unsigned only |
| `[DisallowedType]` in params | Disallowed .NET type in `param()` | **All scripts** |
| `[DisallowedType]$var` | Type constraint on variable | Unsigned only |
| `[DisallowedType]::Method()` | Type expression / static call | Unsigned only |
| `[DisallowedType]$value` | Type cast / convert | Unsigned only |
| `$typedVar.Method()` | Member invocation on disallowed type | Unsigned only |
| `New-Object -TypeName <disallowed>` | Disallowed type in New-Object | Unsigned only |
| `class MyClass { }` | PowerShell class keyword | Unsigned only |
| `[PSCustomObject]@{}` | Type casting | Unsigned only |
| XAML / `xmlns` | WPF/XAML not permitted | Unsigned only |
| `Invoke-Expression` | Restricted | Unsigned only |
| `. $path\script.ps1` | Dot-sourcing | **All scripts** |
| `FunctionsToExport = '*'` | Wildcard exports in manifest | **All manifests** |
| `RootModule = 'X.ps1'` | .ps1 in manifest module fields | **All manifests** |
| `ScriptsToProcess` | Blocked in CLM | **All manifests** |

## Guidelines for Agents

- **Always read file contents** before making compliance judgments — do not guess based on file names.
- **For modules**, review all files: manifest (`.psd1`), root module (`.psm1`), nested modules, and any files in a functions folder. Can read manifests (`.psd1`) files with `Import-PowerShellDataFile` to read as objects.
- **Never generate code** that uses disallowed features. Always validate generated code against the checklist above before presenting it.
- **Parameter and variable type constraints:** Only use allowed types (see Quick Reference).
- **Member invocations:** Only on allowed types (e.g., string methods are allowed).
- **`[PSCustomObject]@{}` is NOT allowed** in CLM — use `New-Object PSObject -Property @{}` or a hashtable instead.
- **Always include comments** explaining any CLM-specific considerations or workarounds.
- **Flag and explain** any use of restricted features, and suggest compliant alternatives.
- **Verify signatures** using `Get-AuthenticodeSignature` instead of only checking for `# SIG # Begin signature block`.
- **Optionally validate** using `Invoke-ScriptAnalyzer` with the `PSUseConstrainedLanguageMode` rule for automated checking.
- https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_language_modes is the source of truth for CLM language features.

## Example Review Output

### Output Format Template

Use this consistent format for each finding:

```
❌ [FileName.ps1:L##] Description of the issue.
   Suggestion: Compliant alternative.

✅ [FileName.ps1:L##] Description of compliant pattern.
```

### Unsigned Script Examples

```
❌ [MyScript.ps1:L5] Uses `Add-Type` to compile C# code. Not allowed in CLM.
   Suggestion: Use built-in cmdlets or pre-compile and sign the assembly.

❌ [MyScript.ps1:L12] Uses `[System.Net.WebClient]` as a parameter type. Not allowed in CLM.
   Suggestion: Use `[string]` for the URL and call `Invoke-WebRequest` or `Invoke-RestMethod`.

❌ [MyScript.ps1:L20] Uses `class MyClass { }`. The `class` keyword is not permitted in CLM.
   Suggestion: Use `New-Object PSObject` with `Add-Member`, or use a hashtable.

❌ [MyScript.ps1:L30] Uses `[PSCustomObject]@{}`. Type casting is not allowed in CLM.
   Suggestion: Use one of:
     Option 1: $obj = New-Object PSObject -Property @{ Name = "Test" }
     Option 2: $obj = @{ Name = "Test" }

❌ [MyScript.ps1:L40] Uses `New-Object -ComObject Excel.Application`. Only 3 COM objects allowed.
   Suggestion: Use allowed COM objects or PowerShell cmdlets (e.g., ImportExcel module).

❌ [MyScript.ps1:L50] Uses `[System.IO.File]::ReadAllText()`. Static method on disallowed type.
   Suggestion: Use `Get-Content -Raw` instead.

✅ [MyScript.ps1:L60] Uses `Get-Process` and `Where-Object`. These are allowed in CLM.
```

### Signed Script Examples

```
❌ [MyModule.psm1:L8] Dot-sources a script that executes code at load time. Always enforced.
   Suggestion: Only dot-source scripts that define functions, or use Import-Module.

❌ [MyModule.psm1:L15] Uses `[System.Net.WebClient]` as a parameter type. Always enforced for params.
   Suggestion: Use `[string]` and call `Invoke-WebRequest` instead.

✅ [MyModule.psm1:L25] Uses `Add-Type`. Allowed because the script is signed and trusted.

❌ [MyModule.psd1:L3] Uses wildcard `FunctionsToExport = '*'`. Always enforced for manifests.
   Suggestion: Use explicit list: FunctionsToExport = @('Get-MyFunction', 'Set-MyFunction')
```

### Module Manifest Examples

```
❌ [MyModule.psd1:L4] RootModule = 'MyModule.ps1'. Do not use .ps1 files.
   Suggestion: Rename to .psm1: RootModule = 'MyModule.psm1'

❌ [MyModule.psd1:L6] FunctionsToExport = '*'. Wildcards not allowed.
   Suggestion: Use explicit list: FunctionsToExport = @('Get-Widget', 'Set-Widget')

❌ [MyModule.psd1:L8] ScriptsToProcess = @('Init.ps1'). Blocked in CLM (loads in caller's scope).
   Suggestion: Remove ScriptsToProcess. Move initialization into the module's .psm1 file.
```

## Common Pitfalls

- Using `[System.IO.File]::ReadAllText()` instead of `Get-Content -Raw`.
- Creating COM objects for Excel or Word automation (only three COM objects are allowed).
- Using `[PSCustomObject]@{}` (type casting — not allowed in CLM).
- Defining PowerShell classes with the `class` keyword.
- Using type constraints or casts to disallowed types on parameters, variables, or in expressions.
- Using `New-Object -TypeName` with a disallowed .NET type.
- Using wildcards, `.ps1` files, or `ScriptsToProcess` in module manifests.
- Assuming arrays of disallowed types are allowed (e.g., `[System.Net.WebClient[]]` is still disallowed).
- Reviewing only one file in a multi-file module instead of checking the entire module.

## Agent Output Expectations

- List each issue found, with file name and line number in the format: `❌ [File:L##] Description`.
- For each issue, explain why it is a problem in CLM.
- Suggest a compliant alternative or fix.
- Summarize overall compliance at the end (e.g., "3 issues found — not CLM-compliant" or "No issues — CLM-compliant").
- If the script is signed, note which checks are enforced and which are skipped.
- For modules, list the files reviewed.

## Security and Review

- All agent-generated scripts should be reviewed by a human before deployment.
- Agents must not execute scripts automatically in production environments.
- Use session configurations to enforce CLM where possible.

- Use `Invoke-ScriptAnalyzer -Settings @{ Rules = @{ PSUseConstrainedLanguageMode = @{ Enable = $true } } }` for automated validation.
- For maximum safety, set `IgnoreSignatures = $true` to enforce all CLM rules regardless of script signature with the `PSUseConstrainedLanguageMode` PSScriptAnalyzer rule.

## Resources

- [About PowerShell Language Modes](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_language_modes)
- [PowerShell Constrained Language Mode](https://devblogs.microsoft.com/powershell/powershell-constrained-language-mode/)
- [PowerShell Module Function Export in Constrained Language](https://devblogs.microsoft.com/powershell/powershell-module-function-export-in-constrained-language/)
- [PowerShell Constrained Language Mode and the Dot-Source Operator](https://devblogs.microsoft.com/powershell/powershell-constrained-language-mode-and-the-dot-source-operator/)

---
This file is intended to help teams safely and effectively use AI agents when working with PowerShell Constrained Language Mode.