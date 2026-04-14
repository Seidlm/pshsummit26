. $PSScriptRoot\Private.ps1
enum TestStates {
    running
    stopped
    waiting
}
class MyClass {
    [string] $Name
    [string] $Property
    [TestStates] $State

    MyClass() { $this.Init(@{})}
    MyClass([hashtable]$Properties) { $this.Init($Properties) }

    [void] Init([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    [string] TestNonCoreType() {
        return ".TestNonCoreType() won't work in CLM; but we are in $(getLanguageMode)"
    }
    
    [string] ToString() {
        return "Name: $($this.Name); Property: $($this.Property); State: $($this.State)"
    }
}

function Get-TestClass {
    [CmdletBinding()]
    param (
        [String]$Name,
        [String]$Property,
        [TestStates]$State

    )
    [MyClass]::New(@{Name=$Name;Property=$Property;State = $State})
}
function Test-Class {
    [CmdletBinding()]
    param (
        [MyClass]$ClassInstance
    )
    $ClassInstance.TestNonCoreType()
}


# SIG # Begin signature block
# Signature removed
# SIG # End signature block
