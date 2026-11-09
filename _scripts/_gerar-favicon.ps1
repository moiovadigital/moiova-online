# Gera favicon.ico (32x32 + 48x48) para moiova-online.
# Formato ICO com PNG embutido (valido desde o Windows Vista / todos os navegadores).
# So usa System.Drawing - nada instalado. Texto do script em ASCII puro.
Add-Type -AssemblyName System.Drawing

$dir = 'G:\0_2026_Novembro\moiova-online'
$corFundo = [System.Drawing.ColorTranslator]::FromHtml('#0a1020')
$corOuro  = [System.Drawing.ColorTranslator]::FromHtml('#c9a86a')

function New-PngBytes([int]$size) {
  $bmp = New-Object System.Drawing.Bitmap($size, $size)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear($corFundo)

  # mesmo mark do favicon: M dourado no quadrado32x32, escalado
  $g.ScaleTransform([float]($size / 32.0), [float]($size / 32.0))
  $pen = New-Object System.Drawing.Pen($corOuro, [float]3)
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.LineJoin  = [System.Drawing.Drawing2D.LineJoin]::Round
  $pts = @(
    (New-Object System.Drawing.PointF(7, 23)),
    (New-Object System.Drawing.PointF(7, 9)),
    (New-Object System.Drawing.PointF(16, 17)),
    (New-Object System.Drawing.PointF(25, 9)),
    (New-Object System.Drawing.PointF(25, 23))
  )
  $g.DrawLines($pen, $pts)
  $pen.Dispose()
  $g.Dispose()

  $ms = New-Object System.IO.MemoryStream
  $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  $bytes = $ms.ToArray()
  $ms.Dispose()
  return $bytes
}

function Build-Ico([array]$entradas) {
  $ms = New-Object System.IO.MemoryStream
  $bw = New-Object System.IO.BinaryWriter($ms)
  $bw.Write([uint16]0)                  # reserved
  $bw.Write([uint16]1)                  # type = icon
  $bw.Write([uint16]$entradas.Count)    # count
  $offset = 6 + (16 * $entradas.Count)
  foreach ($e in $entradas) {
    $bw.Write([byte]$e.Tamanho)         # width
    $bw.Write([byte]$e.Tamanho)         # height
    $bw.Write([byte]0)                  # colors (0 = truecolor)
    $bw.Write([byte]0)                  # reserved
    $bw.Write([uint16]1)                # planes
    $bw.Write([uint16]32)               # bits per pixel
    $bw.Write([uint32]$e.Png.Length)    # tamanho do dado
    $bw.Write([uint32]$offset)          # offset do dado
    $offset += $e.Png.Length
  }
  foreach ($e in $entradas) { $bw.Write([byte[]]$e.Png) }
  $bw.Flush()
  $out = $ms.ToArray()
  $bw.Dispose()
  $ms.Dispose()
  return $out
}

$t32 = New-PngBytes 32
$t48 = New-PngBytes 48
$ico = Build-Ico @(
  @{ Tamanho = 32; Png = $t32 },
  @{ Tamanho = 48; Png = $t48 }
)

$caminho = Join-Path $dir 'favicon.ico'
[System.IO.File]::WriteAllBytes($caminho, $ico)

$leitor = [System.IO.File]::ReadAllBytes($caminho)
"favicon.ico: $($leitor.Length) bytes | header=" + (($leitor[0..5] | ForEach-Object { $_.ToString('x2') }) -join ' ') + " | entradas=" + [BitConverter]::ToUInt16($leitor, 4)
