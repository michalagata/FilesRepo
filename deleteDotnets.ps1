param (
    [Parameter(Mandatory = $true)]
    [string]$DotnetVersion
)

# Known .NET installation locations
$locations = @(
    "C:\Program Files\dotnet",
    "C:\Program Files (x86)\dotnet",
    "$env:USERPROFILE\.dotnet"
)

Write-Host "Searching for .NET version $DotnetVersion in known locations..." -ForegroundColor Green

foreach ($location in $locations) {
    if (Test-Path -Path $location) {
        Write-Host "Checking location: $location" -ForegroundColor Yellow
        Remove-DotnetVersion -Path $location -Version $DotnetVersion
    } else {
        Write-Host "Skipping non-existent location: $location" -ForegroundColor Gray
    }
}

Write-Host "Operation completed." -ForegroundColor Green

function Remove-DotnetVersion {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    # Target folder for shared frameworks
    $sharedPath = Join-Path -Path $Path -ChildPath "shared"
    if (-Not (Test-Path -Path $sharedPath)) {
        Write-Host "No shared folder found in $Path" -ForegroundColor Gray
        return
    }

    # Recursively search for folders matching the version pattern
    Get-ChildItem -Path $sharedPath -Recurse -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.Name -like "$Version*") {
            Write-Host "Found matching folder: $($_.FullName)" -ForegroundColor Cyan
            try {
                Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction Stop
                Write-Host "Successfully deleted $($_.FullName)" -ForegroundColor Green
            } catch {
                Write-Host "Failed to delete $($_.FullName): $_" -ForegroundColor Red
            }
        }
    }
}