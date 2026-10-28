param(
    [Parameter(Mandatory=$true)][string]$Docx,
    [string]$Pdf = (Join-Path $PSScriptRoot '..\build\audit\official.pdf')
)
$ErrorActionPreference = 'Stop'
$sourcePath = (Resolve-Path -LiteralPath $Docx).Path
$outputPath = [IO.Path]::GetFullPath($Pdf)
New-Item -ItemType Directory -Force -Path ([IO.Path]::GetDirectoryName($outputPath)) | Out-Null
$wordAudit = New-Object -ComObject Word.Application
$wordAudit.Visible = $false
$wordAudit.DisplayAlerts = 0
try {
    $documentAudit = $wordAudit.Documents.Open($sourcePath, $false, $true)
    try {
        $documentAudit.ExportAsFixedFormat($outputPath, 17)
    } finally {
        $documentAudit.Close(0)
    }
} finally {
    $wordAudit.Quit()
}
Write-Output $outputPath
