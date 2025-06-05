<#
Examples:

BolgerUtils-ConsoleHere
BolgerUtils-ConsoleHere -admin
#>
function BolgerUtils-ConsoleHere {
    param(
        [Parameter(HelpMessage="Creates console in admin mode")]
        [switch]
        $admin = $false
    )

    if($admin) {
        Start-Process wt -ArgumentList '-d .' -verb RunAs
    } else {
        Start-Process wt -ArgumentList '-d .'
    }
}

function BolgerUtils-Git-Update {
    git update-git-for-windows
}

function BolgerUtils-Node-TaskList {
    tasklist /fi 'imagename eq node.exe'
}

function BolgerUtils-Node-TaskKill {
    taskkill /f /im node.exe
}

function BolgerUtils-Zip {
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $folderPath
    )

    if(-Not (Test-Path $folderPath -PathType Container)) {
        Write-Error "The path '$folderPath' is not a directory."
        return
    }

    $folderName = Split-Path $folderPath -Leaf
    Compress-Archive -Force -Path $folderPath -DestinationPath "$($folderName).zip"
}

function BolgerUtils-Project-Zip {
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $folderPath
    )

    if(-Not (Test-Path $folderPath -PathType Container)) {
        Write-Error "The path '$folderPath' is not a directory."
        return
    }
    
    $folderPathContainsSlnFile = `
        (Get-ChildItem "$folderPath" -Filter "*.sln") -or (Get-ChildItem "$folderPath" -Filter "*.slnx")
    $folderPathContainsCsprojFile = Test-Path "$($folderPath)\*.csproj" -PathType Leaf
    if(-Not $folderPathContainsSlnFile -and -Not $folderPathContainsCsprojFile) {
        Write-Error "The path '$folderPath' does not contain a .sln or .slnx or .csproj file."
        return
    }

    # Clean and zip the project.
    BolgerUtils-Project-Clean $folderPath
    BolgerUtils-Zip $folderPath
}

function BolgerUtils-Project-Clean {
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $folderPath
    )

    if(-Not (Test-Path $folderPath -PathType Container)) {
        Write-Error "The path '$folderPath' is not a directory."
        return
    }
    
    $folderPathContainsSlnFile = `
        (Get-ChildItem "$folderPath" -Filter "*.sln") -or (Get-ChildItem "$folderPath" -Filter "*.slnx")
    $folderPathContainsCsprojFile = Test-Path "$($folderPath)\*.csproj" -PathType Leaf
    if(-Not $folderPathContainsSlnFile -and -Not $folderPathContainsCsprojFile) {
        Write-Error "The path '$folderPath' does not contain a .sln or .slnx or .csproj file."
        return
    }

    if($folderPathContainsSlnFile -and -Not $folderPathContainsCsprojFile) {
        # Clean all the projects.
        Get-ChildItem -Directory $folderPath | ForEach-Object {
            # Skip the folder if no .csproj file is found.
            if(-Not (Test-Path "$($_)\*.csproj" -PathType Leaf)) {
                continue
            }

            dotnet clean $_
        }
    }

    # Clean the solution / project.
    dotnet clean $folderPath
    
    # Remove the .vs folder.
    $path = "$(Get-Item $folderPath)\.vs"
    if(Test-Path $path -PathType Container) {
        Write-Host "Removing $($path)"
        Remove-Item $path -Force -Recurse -ErrorAction Continue
    }

    BolgerUtils-Project-Remove-BinAndObj $folderPath
}

function BolgerUtils-Project-Remove-BinAndObj {
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $folderPath
    )

    if(-Not (Test-Path $folderPath -PathType Container)) {
        Write-Error "The path '$folderPath' is not a directory."
        return
    }

    $folderPathContainsSlnFile = `
        (Get-ChildItem "$folderPath" -Filter "*.sln") -or (Get-ChildItem "$folderPath" -Filter "*.slnx")
    $folderPathContainsCsprojFile = Test-Path "$($folderPath)\*.csproj" -PathType Leaf
    if(-Not $folderPathContainsSlnFile -and -Not $folderPathContainsCsprojFile) {
        Write-Error "The path '$folderPath' does not contain a .sln or .slnx or .csproj file."
        return
    }

    $folders = $folderPathContainsCsprojFile ? @(Get-Item $folderPath) : (Get-ChildItem -Directory $folderPath)

    # Scan all folders starting from the provided folder path and
    # remove the bin & obj folders if a .csproj file is present.
    foreach($folder in $folders) {
        # Skip the folder if no .csproj file is found.
        if(-Not (Test-Path "$($folder)\*.csproj" -PathType Leaf)) {
            continue
        }

        $paths = @("$($folder)\bin", "$($folder)\obj")
        foreach($path in $paths) {
            if(Test-Path $path -PathType Container) {
                Write-Host "Removing $($path)"
                Remove-Item $path -Force -Recurse -ErrorAction Continue
            }
        }
    }
}

<#
Examples:

Single-line:
    BolgerUtils-Script-Create '<database-name>' 'create database [<database-name>];' 'TestDatabase'
 
Output:
    create database [TestDatabase];

Multi-line:
    BolgerUtils-Script-Create '<database-name>' 'create database [<database-name>];' 'TestDatabase1
    TestDatabase2
    TestDatabase3'

Output:
    create database [TestDatabase1];
    create database [TestDatabase2];
    create database [TestDatabase3];

Files:
    BolgerUtils-Script-Create '<database-name>' (Get-Content -Raw TemplateFile.txt) (Get-Content -Raw InputFile.txt)
#>
function BolgerUtils-Script-Create {
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $patternToReplaceWithinTemplate,
        [ValidateNotNullOrEmpty()]
        [string]
        $template,
        [ValidateNotNullOrEmpty()]
        [string]
        $inputLines
    )

    $lines = $inputLines.Split([System.String[]] @("`r`n", "`n"), [System.StringSplitOptions]::RemoveEmptyEntries)
    foreach($line in $lines) {
        $template.Replace($patternToReplaceWithinTemplate, $line)
    }
}
