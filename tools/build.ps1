$ErrorActionPreference = 'Stop'

param(
    [switch]$Pdf,
    [switch]$SkipValidation
)

$root = Split-Path -Parent $PSScriptRoot
$templatePath = Join-Path $root 'src\template.html'
$stylesPath = Join-Path $root 'src\styles\cheatsheet.css'
$sectionsPath = Join-Path $root 'src\sections'
$outputHtmlPath = Join-Path $root 'english_cheatsheet.html'
$outputPdfPath = Join-Path $root 'english_cheatsheet.pdf'
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Read-Utf8([string]$path) {
    return [IO.File]::ReadAllText($path)
}

if (-not (Test-Path $templatePath)) { throw "Не найден шаблон: $templatePath" }
if (-not (Test-Path $stylesPath)) { throw "Не найден CSS: $stylesPath" }
if (-not (Test-Path $sectionsPath)) { throw "Не найден каталог секций: $sectionsPath" }

$sectionFiles = @(Get-ChildItem -LiteralPath $sectionsPath -Filter '*.html' -File | Sort-Object Name)
if ($sectionFiles.Count -eq 0) { throw 'В каталоге src\sections нет HTML-файлов.' }

$sections = @()
foreach ($file in $sectionFiles) {
    $section = Read-Utf8 $file.FullName
    $match = [regex]::Match($section, '(?s)^\s*<section\b(?<attrs>[^>]*)>(?<body>.*?)</section>\s*$')
    if (-not $match.Success) { throw "Файл секции имеет неверную структуру: $($file.FullName)" }

    $orderMatch = [regex]::Match($match.Groups['attrs'].Value, 'data-order="(?<order>\d+)"')
    $titleMatch = [regex]::Match($match.Groups['attrs'].Value, 'data-title="(?<title>[^"]+)"')
    $idMatch = [regex]::Match($match.Groups['attrs'].Value, 'id="(?<id>s\d+)"')
    if (-not $orderMatch.Success -or -not $titleMatch.Success -or -not $idMatch.Success) {
        throw "Секция $($file.Name) должна иметь data-order, data-title и id."
    }

    $body = $match.Groups['body'].Value.Trim()
    $footer = '<div class="footer"><span>Grammar reference</span><span class="footer-page">00 / 00</span></div>'
    $lastContentClose = $body.LastIndexOf('</div>')
    if ($lastContentClose -lt 0) { throw "В секции $($file.Name) не найден контейнер content." }
    $body = $body.Insert($lastContentClose, $footer)
    $sections += [pscustomobject]@{
        Order = [int]$orderMatch.Groups['order'].Value
        Id = $idMatch.Groups['id'].Value
        Title = [System.Net.WebUtility]::HtmlDecode($titleMatch.Groups['title'].Value)
        Markup = '<section' + $match.Groups['attrs'].Value + '>' + $body + '</section>'
    }
}

$sections = @($sections | Sort-Object Order)
$orders = @($sections | ForEach-Object Order)
$ids = @($sections | ForEach-Object Id)
if (($orders | Select-Object -Unique).Count -ne $orders.Count) { throw 'У секций дублируются data-order.' }
if (($ids | Select-Object -Unique).Count -ne $ids.Count) { throw 'У секций дублируются id.' }

$tocLinks = @($sections | Where-Object { $_.Order -gt 0 } | ForEach-Object {
    '<a href="#{0}">{1}</a>' -f $_.Id, [System.Net.WebUtility]::HtmlEncode($_.Title)
}) -join ''
$toc = '<nav class="toc-nav" aria-label="Оглавление"><b>ОГЛАВЛЕНИЕ:</b> ' + $tocLinks + '</nav>'

$total = $sections.Count
foreach ($section in $sections) {
    $page = '{0:00} / {1:00}' -f ($sections.IndexOf($section) + 1), $total
    $section.Markup = $section.Markup.Replace('00 / 00', $page)
    if ($section.Order -eq 8) {
        $section.Markup = $section.Markup.Replace('class="sheet page-break"', 'class="sheet page-break dense-print"')
    }
}

$template = Read-Utf8 $templatePath
$css = Read-Utf8 $stylesPath
$markup = ($sections | ForEach-Object Markup) -join [Environment]::NewLine
$result = $template.Replace('/* BUILD_CSS */', $css.Trim()).Replace('<nav class="toc-nav" aria-label="Оглавление"></nav>', $toc).Replace('<!-- BUILD_SECTIONS -->', $markup)
[IO.File]::WriteAllText($outputHtmlPath, $result.Trim() + [Environment]::NewLine, $utf8)

if (-not $SkipValidation) {
    & (Join-Path $PSScriptRoot 'validate.ps1') -HtmlOnly
}

if ($Pdf) {
    $chrome = @(
        'C:\Program Files\Google\Chrome\Application\chrome.exe',
        'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
        'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $chrome) { throw 'Не найден Chrome или Edge для сборки PDF.' }

    $tempRoot = Join-Path $env:TEMP ('english-cheatsheet-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Force $tempRoot | Out-Null
    $pdfTemp = Join-Path $tempRoot 'english_cheatsheet.pdf'
    try {
        $htmlUri = ([Uri]$outputHtmlPath).AbsoluteUri
        $arguments = @('--headless', '--disable-gpu', '--no-pdf-header-footer', "--user-data-dir=$tempRoot\profile", "--print-to-pdf=$pdfTemp", $htmlUri)
        $process = Start-Process -FilePath $chrome -ArgumentList $arguments -Wait -PassThru -NoNewWindow
        if ($process.ExitCode -ne 0 -or -not (Test-Path $pdfTemp)) { throw "Headless-браузер не собрал PDF (код $($process.ExitCode))." }
        Move-Item -LiteralPath $pdfTemp -Destination $outputPdfPath -Force
    } finally {
        if (Test-Path $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue }
    }
    & (Join-Path $PSScriptRoot 'validate.ps1')
}

Write-Output "Собран HTML: $outputHtmlPath"
if ($Pdf) { Write-Output "Собран PDF: $outputPdfPath" }