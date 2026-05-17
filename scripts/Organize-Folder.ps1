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

$configData = Get-Content $Config -Raw | ConvertFrom-Json

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

$files = Get-ChildItem -LiteralPath $Path -File -Recurse:$Recurse

foreach ($file in $files) {
    if (-not $IncludeHidden -and (($file.Attributes -band [System.IO.FileAttributes]::Hidden) -ne 0)) {
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

    if ($file.DirectoryName -eq $destinationFolder) {
        continue
    }

    $destinationPath = Get-UniquePath (Join-Path $destinationFolder $file.Name)

    [pscustomobject]@{
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
