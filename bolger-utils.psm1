<#
Examples:

BolgerUtils-ConsoleHere
BolgerUtils-ConsoleHere -admin
BolgerUtils-ConsoleHere -Admin
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
    if(-Not (Test-Path "$($folderPath)\*.sln" -PathType Leaf)) {
        Write-Error "The path '$folderPath' does not contain a .sln file."
        return
    }

    # Clean and zip project.
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
    if(-Not (Test-Path "$($folderPath)\*.sln" -PathType Leaf)) {
        Write-Error "The path '$folderPath' does not contain a .sln file."
        return
    }

    # Clean solution and remove .vs folder.
    dotnet clean $folderPath
    Remove-Item "$($folderPath)\.vs" -Force -Recurse -ErrorAction SilentlyContinue

    # Clean all projects and remove bin & obj folders.
    Get-ChildItem -Directory $folderPath | ForEach-Object {
        # Skip folder if no .csproj file is found.
        if(-Not (Test-Path "$($_)\*.csproj" -PathType Leaf)) {
            continue
        }

        dotnet clean $_
        Remove-Item "$($_)\bin", "$($_)\obj" -Force -Recurse -ErrorAction SilentlyContinue
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
