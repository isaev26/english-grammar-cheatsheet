$ErrorActionPreference = 'Stop'

param(
    [switch]$HtmlOnly
)

$root = Split-Path -Parent $PSScriptRoot
$htmlPath = Join-Path $root 'english_cheatsheet.html'
$pdfPath = Join-Path $root 'english_cheatsheet.pdf'
if (-not (Test-Path $htmlPath)) { throw "Не найден итоговый HTML: $htmlPath" }

$html = [IO.File]::ReadAllText($htmlPath)
if ([string]::IsNullOrWhiteSpace($html)) { throw 'Итоговый HTML пуст.' }

function Count-Matches([string]$text, [string]$pattern) {
    return ([regex]::Matches($text, $pattern)).Count
}

$sections = Count-Matches $html '<section\b'
$h2 = Count-Matches $html '<h2\b'
$footers = Count-Matches $html 'class="footer"'
$images = Count-Matches $html '<img\b|<svg\b'
$imports = Count-Matches $html '@import|https?://|//[^/\s]+'
$debug = Count-Matches $html 'console\.log|var_dump|debugger'
if ($sections -ne 13) { throw "Ожидалось 13 секций, найдено $sections." }
if ($h2 -ne 12) { throw "Ожидалось 12 заголовков h2, найдено $h2." }
if ($footers -ne $sections) { throw "Количество footer ($footers) не равно количеству секций ($sections)." }
if ($images -ne 0) { throw "Найдены изображения или SVG: $images." }
if ($imports -ne 0) { throw "Найдены внешние импорты или URL: $imports." }
if ($debug -ne 0) { throw "Найдены отладочные вставки: $debug." }
if ($html -match '(?is)<h2>6\..*?</section>.*?used to') { throw 'used to найден после раздела 6.' }
foreach ($id in 1..12) {
    if ($html -notmatch "id=\"s$id\"") { throw "Не найден id секции s$id." }
}

Write-Output "HTML OK: sections=$sections, h2=$h2, footers=$footers, images=$images, external=$imports"

if (-not $HtmlOnly) {
    if (-not (Test-Path $pdfPath)) { throw "Не найден PDF: $pdfPath" }
    $pdfBytes = [IO.File]::ReadAllBytes($pdfPath)
    if ($pdfBytes.Length -lt 1000 -or [Text.Encoding]::ASCII.GetString($pdfBytes, 0, 5) -ne '%PDF-') { throw 'PDF имеет неверный формат или пуст.' }
    $pdfText = [Text.Encoding]::GetEncoding(1252).GetString($pdfBytes)
    if ($pdfText -notmatch '/Type\s*/Page') { throw 'В PDF не найден объект страницы.' }
    if ($pdfText -match '(?i)travel|pronunciation|vocabulary|\breading\b|\bstory\b') { throw 'В PDF найдено запрещённое содержание.' }
    Write-Output "PDF OK: bytes=$($pdfBytes.Length)"
}