Set-StrictMode -Version Latest

function Invoke-InConstrainedRunspace {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Script,

        [hashtable]$Parameters
    )

    $initialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
    $initialSessionState.LanguageMode = [System.Management.Automation.PSLanguageMode]::ConstrainedLanguage

    $runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($initialSessionState)
    $runspace.Open()

    try {
        $ps = [System.Management.Automation.PowerShell]::Create()
        $ps.Runspace = $runspace

        [void]$ps.AddScript($Script)
        if ($Parameters) {
            [void]$ps.AddParameters($Parameters)
        }

        $invokeException = $null

        try {
            $output = $ps.Invoke()
        }
        catch {
            $invokeException = $_
            $output = @()
        }

        [pscustomobject]@{
            Output = $output
            Errors = @($ps.Streams.Error)
            HadErrors = $ps.HadErrors
            InvokeException = $invokeException
        }
    }
    finally {
        if ($ps) {
            $ps.Dispose()
        }

        $runspace.Close()
        $runspace.Dispose()
    }
}

Describe 'MyModule in CLM' {
    BeforeAll {
        $moduleManifestPath = Join-Path -Path $PSScriptRoot -ChildPath '..\MyModule.psd1'
        $moduleManifestPath = [System.IO.Path]::GetFullPath($moduleManifestPath)
    }

    It 'uses constrained language mode in the isolated runspace' {
        $result = Invoke-InConstrainedRunspace -Script '$ExecutionContext.SessionState.LanguageMode.ToString()'

        $result.HadErrors | Should Be $false
        $result.Output.Count | Should Be 1
        $result.Output[0] | Should Be 'ConstrainedLanguage'
    }

    It 'imports MyModule and exposes exported functions in CLM runspace' {
        $script = @'
param([string]$ModulePath)

Import-Module -Name $ModulePath -Force -ErrorAction Stop

(Get-Command -Module MyModule -Name Test-LanguageMode, Test-Com, Test-Win32).Count
'@

        $result = Invoke-InConstrainedRunspace -Script $script -Parameters @{ ModulePath = $moduleManifestPath }

        $result.InvokeException | Should Be $null
        $result.HadErrors | Should Be $false
        $result.Output.Count | Should Be 1
        $result.Output[0] | Should Be 3
    }

    It 'blocks COM object creation from Test-Com in CLM' {
        $script = @'
param([string]$ModulePath)

Import-Module -Name $ModulePath -Force -ErrorAction Stop

try {
    Test-Com -Message "hello" -ErrorAction Stop
    "NO_ERROR"
}
catch {
    $_.FullyQualifiedErrorId
}
'@

        $result = Invoke-InConstrainedRunspace -Script $script -Parameters @{ ModulePath = $moduleManifestPath }

        $result.InvokeException | Should Be $null
        $result.Output.Count | Should Be 1
        $result.Output[0] | Should Match 'CannotCreateComType|ComObject|ConstrainedLanguage'
    }

    It 'blocks Add-Type from Test-Win32 in CLM' {
        $script = @'
param([string]$ModulePath)

Import-Module -Name $ModulePath -Force -ErrorAction Stop

try {
    Test-Win32 -Text "hello" -Title "title" -ErrorAction Stop
    "NO_ERROR"
}
catch {
    $_.FullyQualifiedErrorId
}
'@

        $result = Invoke-InConstrainedRunspace -Script $script -Parameters @{ ModulePath = $moduleManifestPath }

        $result.InvokeException | Should Be $null
        $result.Output.Count | Should Be 1
        $result.Output[0] | Should Match 'CannotDefineNewType|AddType|ConstrainedLanguage'
    }
}
