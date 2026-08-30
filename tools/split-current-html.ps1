$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $root 'english_cheatsheet.html'
$source = [IO.File]::ReadAllText($sourcePath)
$utf8 = New-Object System.Text.UTF8Encoding($false)

$styleMatch = [regex]::Match($source, '(?s)<style>\s*(.*?)\s*</style>')
if (-not $styleMatch.Success) {
    throw 'Не найден блок <style>.'
}

$sectionMatches = [regex]::Matches($source, '(?s)<section\b.*?</section>')
if ($sectionMatches.Count -ne 13) {
    throw "Ожидалось 13 секций, найдено $($sectionMatches.Count)."
}

$sectionsPath = Join-Path $root 'src\sections'
$stylesPath = Join-Path $root 'src\styles'
New-Item -ItemType Directory -Force $sectionsPath, $stylesPath | Out-Null
[IO.File]::WriteAllText((Join-Path $stylesPath 'cheatsheet.css'), $styleMatch.Groups[1].Value.Trim() + [Environment]::NewLine, $utf8)

$slugs = @(
    'cover',
    'sentence-frame',
    'to-be',
    'tenses',
    'verb-forms',
    'articles-quantity',
    'prepositions',
    'used-to-modals',
    'additional-grammar',
    'tenses-table',
    'choice-tree',
    'adverbs',
    'compact-grammar'
)

for ($index = 0; $index -lt $sectionMatches.Count; $index++) {
    $section = $sectionMatches[$index].Value
    $title = if ($index -eq 0) { 'Обложка' } else {
        [regex]::Match($section, '<h2>(.*?)</h2>').Groups[1].Value
    }

    $section = [regex]::Replace($section, '(?s)<div class="footer">.*?</div>', '')
    $class = if ($index -eq 0) { 'sheet' } else { 'sheet page-break' }
    $titleAttribute = [System.Net.WebUtility]::HtmlEncode($title)
    $attributes = 'class="{0}" id="s{1}" data-order="{1}" data-slug="{2}" data-title="{3}"' -f $class, $index, $slugs[$index], $titleAttribute
    $section = [regex]::Replace($section, '<section class="[^"]+">', "<section $attributes>", 1)

    $fileName = '{0:00}-{1}.html' -f $index, $slugs[$index]
    [IO.File]::WriteAllText((Join-Path $sectionsPath $fileName), $section.Trim() + [Environment]::NewLine, $utf8)
}

Write-Output "Создано секций: $($sectionMatches.Count)"