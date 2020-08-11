function BolgerUtils-New-ConsoleInAdminModeHere {
    Start-Process wt -ArgumentList '-d .' -verb RunAs
}

function BolgerUtils-New-ConsoleHere {
    Start-Process wt -ArgumentList '-d .'
}

function BolgerUtils-Update-GitForWindows {
    git update-git-for-windows
}

function BolgerUtils-Test-DatabaseConnection {
    & 'D:\Visual Studio 2019\Projects\TestDatabaseConnection\TestDatabaseConnection\bin\Debug\netcoreapp3.1\TestDatabaseConnection.exe'
}

function BolgerUtils-Node-TaskList {
    tasklist /fi 'imagename eq node.exe'
}

function BolgerUtils-Node-TaskKill {
    taskkill /f /im node.exe
}

function BolgerUtils-Zip-Folder {
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

function BolgerUtils-Zip-Project {
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

    BolgerUtils-Zip-Folder $folderPath
}

function BolgerUtils-Create-Script {
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
