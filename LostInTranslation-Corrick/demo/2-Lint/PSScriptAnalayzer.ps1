Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -MinimumVersion 1.25.0

# Run the analyzer
$settings = @{
    Rules = @{
        PSUseConstrainedLanguageMode = @{
            Enable = $true
            IgnoreSignatures = $true
        }
    }
}
Invoke-ScriptAnalyzer -Path ".\2-Lint\NotAllowed.ps1" `
    -Settings $settings `
    -IncludeRule PSUseConstrainedLanguageMode |
    Format-Table RuleName, Severity, Line, Message -AutoSize

Invoke-ScriptAnalyzer -Path ".\2-Lint\AlsoNotAllowed.ps1" `
    -Settings $settings `
    -IncludeRule PSUseConstrainedLanguageMode |
    Format-Table RuleName, Severity, Line, Message -AutoSize