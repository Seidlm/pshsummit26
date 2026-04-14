$languageMode = $host.Runspace.LanguageMode

$piRounded = try {
    [math]::Round(([math]::pi), 2)
} 
catch {
    "failed"
}

$class = try {
    class Book {
        # Class properties
        [string]   $Title
        [string]   $Author
        [string]   $Synopsis
        [string]   $Publisher
        [datetime] $PublishDate
        [int]      $PageCount
        [string[]] $Tags
        # Default constructor
        Book() { $this.Init(@{}) }
        # Convenience constructor from hashtable
        Book([hashtable]$Properties) { $this.Init($Properties) }
        # Common constructor for title and author
        Book([string]$Title, [string]$Author) {
            $this.Init(@{Title = $Title; Author = $Author })
        }
        # Shared initializer method
        [void] Init([hashtable]$Properties) {
            foreach ($Property in $Properties.Keys) {
                $this.$Property = $Properties.$Property
            }
        }
        # Method to calculate reading time as 2 minutes per page
        [timespan] GetReadingTime() {
            if ($this.PageCount -le 0) {
                throw 'Unable to determine reading time from page count.'
            }
            $Minutes = $this.PageCount * 2
            return [timespan]::new(0, $Minutes, 0)
        }
        # Method to calculate how long ago a book was published
        [timespan] GetPublishedAge() {
            if (
                $null -eq $this.PublishDate -or
                $this.PublishDate -eq [datetime]::MinValue
            ) { throw 'PublishDate not defined' }

            return (Get-Date) - $this.PublishDate
        }
        # Method to return a string representation of the book
        [string] ToString() {
            return "$($this.Title) by $($this.Author) ($($this.PublishDate.Year))"
        }
    }

    $Book = [Book]::new(@{
            Title       = 'The Hobbit'
            Author      = 'J.R.R. Tolkien'
            Publisher   = 'George Allen & Unwin'
            PublishDate = '1937-09-21'
            PageCount   = 310
            Tags        = @('Fantasy', 'Adventure')
        })

    $Book
    $Time = $Book.GetReadingTime()
    $Time = @($Time.Hours, 'hours and', $Time.Minutes, 'minutes') -join ' '
    $Age = [Math]::Floor($Book.GetPublishedAge().TotalDays / 365.25)

    "It takes $Time to read $Book,`nwhich was published $Age years ago."

}
catch {
    "failed"
}

$dotSourcing = try {
    . "$PSScriptRoot\TestModule.ps1"
    Test-It -switchy
}
catch {
    "failed"
}

$Invoke = try {
    Invoke-Expression -Command 'Write-Output "Hello from Invoke-Expression"'
} catch {
    "failed"
}


Write-Output @"
We are running in: $languageMode
Non-Core method: $piRounded
Class: $class
Dot Sourcing: $dotSourcing
Invoke-Expression: $Invoke
"@
  