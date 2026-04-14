
function getLanguageMode {
    return $ExecutionContext.SessionState.LanguageMode
}

function stringBuilder {
    param (
        [string[]] $Words
    )
    $sb = New-Object System.Text.StringBuilder
    $null = $sb.AppendJoin(' ',$Words)
    $sb.ToString()
}