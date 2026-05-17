param(
    [string]$Path,
    [string]$Config = "$PSScriptRoot\..\config\rules.json",
    [switch]$DryRun,
    [switch]$Recurse,
    [switch]$IncludeHidden
)

function Expand-PathValue {
    param([string]$Value)

    [Environment]::ExpandEnvironmentVariables($Value)
}

function Get-UniquePath {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $Path
    }

    $directory = Split-Path $Path
    $name = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    $extension = [System.IO.Path]::GetExtension($Path)
    $index = 1

    do {
        $candidate = Join-Path $directory "$name ($index)$extension"
        $index++
    } while (Test-Path -LiteralPath $candidate)

    $candidate
}

function Test-InOrganizedFolder {
    param(
        [string]$FilePath,
        [string]$RootPath,
        [string[]]$FolderNames
    )

    $fullFilePath = [System.IO.Path]::GetFullPath($FilePath)

    foreach ($folderName in $FolderNames) {
        $folderPath = Join-Path $RootPath $folderName
        $fullFolderPath = [System.IO.Path]::GetFullPath($folderPath).TrimEnd('\') + '\'

        if ($fullFilePath.StartsWith($fullFolderPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    return $false
}

$configData = Get-Content -LiteralPath $Config -Raw | ConvertFrom-Json

if (-not $Path) {
    $Path = Expand-PathValue $configData.targetPath
}

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Target path not found: $Path"
}

$extensionMap = @{}

foreach ($folder in $configData.folders.PSObject.Properties) {
    foreach ($extension in $folder.Value) {
        $extensionMap[$extension.ToLowerInvariant()] = $folder.Name
    }
}

$organizedFolders = @($configData.folders.PSObject.Properties.Name + $configData.fallbackFolder) | Select-Object -Unique
$files = Get-ChildItem -LiteralPath $Path -File -Recurse:$Recurse
$results = @()

foreach ($file in $files) {
    if (-not $IncludeHidden -and (($file.Attributes -band [System.IO.FileAttributes]::Hidden) -ne 0)) {
        continue
    }

    if ($Recurse -and (Test-InOrganizedFolder -FilePath $file.FullName -RootPath $Path -FolderNames $organizedFolders)) {
        continue
    }

    $extension = $file.Extension.ToLowerInvariant()

    if ([string]::IsNullOrWhiteSpace($extension)) {
        $destinationName = $configData.fallbackFolder
    } elseif ($extensionMap.ContainsKey($extension)) {
        $destinationName = $extensionMap[$extension]
    } else {
        $destinationName = $configData.fallbackFolder
    }

    $destinationFolder = Join-Path $Path $destinationName

    if ($file.DirectoryName -ieq $destinationFolder) {
        continue
    }

    $destinationPath = Get-UniquePath (Join-Path $destinationFolder $file.Name)

    $results += [pscustomobject]@{
        File = $file.Name
        From = $file.FullName
        To = $destinationPath
        Mode = if ($DryRun) { "Preview" } else { "Moved" }
    }

    if (-not $DryRun) {
        New-Item -ItemType Directory -Force $destinationFolder | Out-Null
        Move-Item -LiteralPath $file.FullName -Destination $destinationPath
    }
}

if ($results.Count -eq 0) {
    Write-Host "No files to organize." -ForegroundColor Yellow
} else {
    $results
}
