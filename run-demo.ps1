param([string]$Device = 'chrome')
$ErrorActionPreference = 'Stop'
$projectDirectory = Split-Path -Parent $PSCommandPath
$flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutterCommand) {
    $flutterExecutable = $flutterCommand.Source
} else {
    # Local SDK used to validate this workspace; not included in the source ZIP.
    $bundledSdk = Join-Path $projectDirectory '..\..\work\sdk\flutter\bin\flutter.bat'
    if (!(Test-Path -LiteralPath $bundledSdk)) {
        throw 'Install Flutter 3.24+ and add it to PATH. See README.md.'
    }
    $flutterExecutable = (Resolve-Path -LiteralPath $bundledSdk).Path
}
Push-Location -LiteralPath $projectDirectory
try {
    & $flutterExecutable pub get
    if ($LASTEXITCODE -ne 0) { throw 'Dependency resolution failed.' }
    & $flutterExecutable run -d $Device
} finally {
    Pop-Location
}
