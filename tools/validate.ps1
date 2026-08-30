param(
    [switch]$HtmlOnly
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$htmlPath = Join-Path $root 'english_cheatsheet.html'
$pdfPath = Join-Path $root 'english_cheatsheet.pdf'
if (-not (Test-Path $htmlPath)) { throw "Built HTML not found: $htmlPath" }

$html = [IO.File]::ReadAllText($htmlPath)
if ([string]::IsNullOrWhiteSpace($html)) { throw 'Built HTML is empty.' }

function Count-Matches([string]$text, [string]$pattern) {
    return ([regex]::Matches($text, $pattern)).Count
}

$sections = Count-Matches $html '<section\b'
$h2 = Count-Matches $html '<h2\b'
$footers = Count-Matches $html 'class="footer"'
$images = Count-Matches $html '<img\b|<svg\b'
$imports = Count-Matches $html '@import|https?://|//[^/\s]+'
$debug = Count-Matches $html 'console\.log|var_dump|debugger'
$tocLinks = Count-Matches $html '<a href="#s\d+">'
if ($sections -ne 13) { throw "Expected 13 sections, found $sections." }
if ($h2 -ne 12) { throw "Expected 12 h2 headings, found $h2." }
if ($footers -ne $sections) { throw "Footer count ($footers) differs from section count ($sections)." }
if ($images -ne 0) { throw "Images or SVG found: $images." }
if ($imports -ne 0) { throw "External imports or URLs found: $imports." }
if ($debug -ne 0) { throw "Debug statements found: $debug." }
if ($tocLinks -ne 12) { throw "Expected 12 TOC links, found $tocLinks." }
$section6 = [regex]::Match($html, '(?is)<section\b[^>]*data-order="6"[^>]*>.*?</section>')
if (-not $section6.Success) { throw 'Section 6 not found.' }
if ($section6.Value -match '(?i)used\s+to') { throw 'used to must not be in section 6.' }
foreach ($id in 1..12) {
    if ($html -notmatch ('id="s{0}"' -f $id)) { throw "Section id s$id not found." }
}

Write-Output "HTML OK: sections=$sections, h2=$h2, footers=$footers, images=$images, external=$imports"

if (-not $HtmlOnly) {
    if (-not (Test-Path $pdfPath)) { throw "PDF not found: $pdfPath" }
    $pdfBytes = [IO.File]::ReadAllBytes($pdfPath)
    if ($pdfBytes.Length -lt 1000 -or [Text.Encoding]::ASCII.GetString($pdfBytes, 0, 5) -ne '%PDF-') { throw 'PDF is invalid or empty.' }
    $pdfText = [Text.Encoding]::GetEncoding(1252).GetString($pdfBytes)
    $pageObjects = ([regex]::Matches($pdfText, '/Type\s*/Page(?!s)')).Count
    $imageObjects = ([regex]::Matches($pdfText, '/Subtype\s*/Image')).Count
    if ($pageObjects -lt $sections) { throw "PDF page count ($pageObjects) is less than section count ($sections)." }
    if ($imageObjects -ne 0) { throw "Images found in PDF: $imageObjects." }
    if ($pdfText -match '(?i)travel|pronunciation|vocabulary|\breading\b|\bstory\b') { throw 'Forbidden content found in PDF.' }
    Write-Output "PDF OK: bytes=$($pdfBytes.Length), pages=$pageObjects, images=$imageObjects"
}