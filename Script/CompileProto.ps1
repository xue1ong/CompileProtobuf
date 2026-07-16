[CmdletBinding()]
param(
    [string]$ProtoDir,
    [string]$OutputDir,
    [string]$Protoc = "protoc"
)

$ErrorActionPreference = "Stop"
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path

if ([string]::IsNullOrWhiteSpace($ProtoDir)) {
    $ProtoDir = Join-Path $projectRoot "proto"
}
if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $projectRoot "Results"
}

try {
    $protocCommand = Get-Command $Protoc -CommandType Application -ErrorAction Stop
}
catch {
    Write-Host "Cannot find protoc. Add protoc.exe to PATH or use -Protoc <path>." -ForegroundColor Red
    exit 1
}

$protocPath = $protocCommand.Source
$version = & $protocPath --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to run protoc: $protocPath" -ForegroundColor Red
    exit $LASTEXITCODE
}

if (-not (Test-Path -LiteralPath $ProtoDir -PathType Container)) {
    Write-Host "Proto directory does not exist: $ProtoDir" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path -LiteralPath $OutputDir -PathType Container)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$trimChars = [char[]]@('\', '/')
$protoRoot = (Resolve-Path -LiteralPath $ProtoDir).Path.TrimEnd($trimChars)
$outputRoot = (Resolve-Path -LiteralPath $OutputDir).Path.TrimEnd($trimChars)
$protoFiles = @(Get-ChildItem -LiteralPath $protoRoot -Filter "*.proto" -File -Recurse | Sort-Object FullName)

Write-Host "protoc: $version ($protocPath)"
Write-Host "Input : $protoRoot"
Write-Host "Output: $outputRoot"

if ($protoFiles.Count -eq 0) {
    Write-Host "No .proto files found."
    exit 0
}

$compiledCount = 0
$failedFiles = @()
Push-Location $protoRoot
try {
    foreach ($protoFile in $protoFiles) {
        $relativePath = $protoFile.FullName.Substring($protoRoot.Length).TrimStart($trimChars) -replace '\\', '/'
        Write-Host "Compiling $relativePath"

        & $protocPath "--proto_path=$protoRoot" "--cpp_out=$outputRoot" $relativePath
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Compilation failed: $relativePath" -ForegroundColor Red
            $failedFiles += $relativePath
            continue
        }

        $compiledCount++
    }
}
finally {
    Pop-Location
}

if ($failedFiles.Count -gt 0) {
    Write-Host "Finished with errors. Compiled $compiledCount file(s); failed $($failedFiles.Count) file(s):" -ForegroundColor Red
    $failedFiles | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

Write-Host "Done. Compiled $compiledCount file(s) into $outputRoot"

