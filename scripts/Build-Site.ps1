[CmdletBinding()]
param(
    [ValidateRange(640, 6000)]
    [int]$MaxDimension = 2400,

    [ValidateRange(1, 100)]
    [int]$JpegQuality = 82
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot
$sourceHtml = Join-Path $projectRoot 'Photography_Site.html'
$sourceImageDirectory = Join-Path $projectRoot 'Croatia Best of Best'
$outputRoot = Join-Path $projectRoot 'site'
$outputImageDirectory = Join-Path $outputRoot 'images'

if (-not (Test-Path -LiteralPath $sourceHtml -PathType Leaf)) {
    throw "Source HTML not found: $sourceHtml"
}

if (-not (Test-Path -LiteralPath $sourceImageDirectory -PathType Container)) {
    throw "Source image directory not found: $sourceImageDirectory"
}

New-Item -ItemType Directory -Path $outputImageDirectory -Force | Out-Null

# The deployed site needs a conventional index page and short, URL-safe asset paths.
$html = Get-Content -LiteralPath $sourceHtml -Raw -Encoding UTF8
$html = $html.Replace('Croatia%20Best%20of%20Best/', 'images/')
$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path $outputRoot 'index.html'), $html, $utf8WithoutBom)

$jpegEncoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
    Where-Object { $_.MimeType -eq 'image/jpeg' } |
    Select-Object -First 1
$encoderParameters = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParameters.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
    [System.Drawing.Imaging.Encoder]::Quality,
    [long]$JpegQuality
)

try {
    $sourceImages = Get-ChildItem -LiteralPath $sourceImageDirectory -File |
        Where-Object { $_.Extension -match '^\.jpe?g$' }

    foreach ($sourceImage in $sourceImages) {
        $image = [System.Drawing.Image]::FromFile($sourceImage.FullName)
        try {
            $scale = [Math]::Min(1.0, $MaxDimension / [double][Math]::Max($image.Width, $image.Height))
            $width = [Math]::Max(1, [int][Math]::Round($image.Width * $scale))
            $height = [Math]::Max(1, [int][Math]::Round($image.Height * $scale))

            $bitmap = New-Object System.Drawing.Bitmap($width, $height)
            try {
                $bitmap.SetResolution(72, 72)
                $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
                try {
                    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
                    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
                    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
                    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                    $graphics.DrawImage($image, 0, 0, $width, $height)
                }
                finally {
                    $graphics.Dispose()
                }

                $destination = Join-Path $outputImageDirectory $sourceImage.Name
                $bitmap.Save($destination, $jpegEncoder, $encoderParameters)
                $sizeMb = [Math]::Round((Get-Item -LiteralPath $destination).Length / 1MB, 2)
                Write-Host "Built $($sourceImage.Name): ${width}x${height}, ${sizeMb} MB"
            }
            finally {
                $bitmap.Dispose()
            }
        }
        finally {
            $image.Dispose()
        }
    }
}
finally {
    $encoderParameters.Dispose()
}

Write-Host "Site ready at $outputRoot"
