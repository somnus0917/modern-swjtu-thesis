# Controlled Word measurement; never opens or modifies the official reference.
param([string]$Pdf = (Join-Path $PSScriptRoot '..\build\audit\word-single-no-grid.pdf'))
$ErrorActionPreference = 'Stop'
$outputPath = [IO.Path]::GetFullPath($Pdf)
New-Item -ItemType Directory -Force -Path ([IO.Path]::GetDirectoryName($outputPath)) | Out-Null
$wordAudit = New-Object -ComObject Word.Application
$wordAudit.Visible = $false
$wordAudit.DisplayAlerts = 0
try {
    $documentAudit = $wordAudit.Documents.Add()
    try {
        $documentAudit.Content.Text = "第一行用于测量单倍行距。`r第二行用于测量单倍行距。`r第三行用于测量单倍行距。"
        $documentAudit.Content.Font.Name = 'Times New Roman'
        $documentAudit.Content.Font.NameFarEast = '宋体'
        $documentAudit.Content.Font.Size = 10.5
        $documentAudit.Content.ParagraphFormat.LineSpacingRule = 0
        $documentAudit.Content.ParagraphFormat.DisableLineHeightGrid = $true
        $documentAudit.Content.ParagraphFormat.SpaceBefore = 0
        $documentAudit.Content.ParagraphFormat.SpaceAfter = 0
        $documentAudit.ExportAsFixedFormat($outputPath, 17)
    } finally { $documentAudit.Close(0) }
} finally { $wordAudit.Quit() }
