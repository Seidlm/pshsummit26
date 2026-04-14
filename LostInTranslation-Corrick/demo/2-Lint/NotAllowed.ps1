. $PSScriptRoot\Private.ps1

function Test-LanguageMode {
    [CmdletBinding()]
    param (
        $String
    )

    $LanguageMode = getLanguageMode

    try {
        $math = [math]::Round([math]::pi, 9)
    } catch {
        $math = "maybe 3.14"
    }
    
    try {
        $phrase = stringBuilder -Words "the", "quick", "brown", "fox", "jumps", "over", "the", "lazy", "dog"
    } catch {
        $phrase = "lazy dog got the brown fox"
    }

    try {
        [PSCustomObject]@{
            LanguageMode = $LanguageMode
            Math = $math
            Phrase = $phrase
        }
    } catch {
        $obj = New-Object -TypeName PSObject
        Add-Member -InputObject $obj -MemberType NoteProperty -Name "LanguageMode" -Value $LanguageMode
        Add-Member -InputObject $obj -MemberType NoteProperty -Name "Math" -Value $Math
        Add-Member -InputObject $obj -MemberType NoteProperty -Name "Phrase" -Value $Phrase
        $obj
    }

}
function Test-Method {
    [CmdletBinding()]
    param (
        [int]$Number
    )
    
    [math]::Round([math]::pi, $Number)
}

function Test-Com {
    [CmdletBinding()]
    param (
        [String]$Message
    )
    $shell = New-Object -ComObject WScript.Shell
    $shell.PopUp($Message)
}

function Test-Win32 {
    [CmdletBinding()]
    param (
        [String]$Text,
        [String]$Title
    )
    Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class Win32 {
    [DllImport("user32.dll")]
    public static extern int MessageBox(IntPtr hWnd, string text, string caption, int type);
}
"@

[Win32]::MessageBox(0, "$Text", "$Title", 0)
}
