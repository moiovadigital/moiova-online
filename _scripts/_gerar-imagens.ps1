# Gera og-capa.png (1200x630) e apple-touch-icon.png (180x180) para moiova-online
# Usa apenas System.Drawing (recurso do proprio Windows) - nada instalado.
Add-Type -AssemblyName System.Drawing

$dir = 'G:\0_2026_Novembro\moiova-online\imagens'
$hex = { param($h) [System.Drawing.ColorTranslator]::FromHtml($h) }

$bgTop    = & $hex '#0a1020'
$bgBot    = & $hex '#141d38'
$gold     = & $hex '#c9a86a'
$goldLt   = & $hex '#e8d3a2'
$goldDk   = & $hex '#a98a52'
$textCol  = & $hex '#f1ece2'
$muted    = & $hex '#aab0bd'
$barBg    = & $hex '#141d38'

$sf  = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$sm  = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# ============================ og-capa.png (1200x630) ============================
$w = 1200; $h = 630
$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.TextRenderingHint = $sf
$g.SmoothingMode = $sm

# fundo em gradiente diagonal (mesmos tons do site)
$rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
$grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $bgTop, $bgBot, [float]40)
$g.FillRectangle($grad, $rect)

# brilho dourado discreto no canto superior direito
$penGlow = New-Object System.Drawing.SolidBrush(([System.Drawing.Color]::FromArgb(26, $gold)))
$g.FillEllipse($penGlow, 830, -230, 560, 560)
$penGlow.Dispose()

# ---- logo: "moiova" claro + "Digital" dourado ----
$fLogo = [System.Drawing.Font]::new('Georgia', 46, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$szLogo = $g.MeasureString('moiova ', $fLogo)
$g.DrawString('moiova', $fLogo, (New-Object System.Drawing.SolidBrush($textCol)), 100, 74)
$g.DrawString(' Digital', $fLogo, (New-Object System.Drawing.SolidBrush($gold)), 100 + $szLogo.Width - 6, 74)

# ---- filete dourado (mesmo do .section-title::before) ----
$g.FillRectangle((New-Object System.Drawing.SolidBrush($goldDk)), 100, 176, 96, 3)

# ---- manchete em2 linhas ----
$fH1 = [System.Drawing.Font]::new('Georgia', 62, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString('Sites para alugar',      $fH1, (New-Object System.Drawing.SolidBrush($goldLt)), 100, 216)
$g.DrawString('e sites institucionais', $fH1, (New-Object System.Drawing.SolidBrush($textCol)), 100, 296)

# ---- subtexto ----
$fSub = [System.Drawing.Font]::new('Segoe UI', 25, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString('Código próprio — sem plataforma refém.',            $fSub, (New-Object System.Drawing.SolidBrush($muted)), 100, 402)
$g.DrawString('Atendimento online em todas as etapas.',           $fSub, (New-Object System.Drawing.SolidBrush($muted)), 100, 440)

# ---- barra inferior ----
$g.FillRectangle((New-Object System.Drawing.SolidBrush($barBg)), 0, 534, $w, $h - 534)
$fUrl = [System.Drawing.Font]::new('Segoe UI', 26, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString('www.moiovadigital.com.br', $fUrl, (New-Object System.Drawing.SolidBrush($gold)), 100, 572)

$fNote = [System.Drawing.Font]::new('Segoe UI', 23, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$nota = 'Planos a partir de R$99/mês'
$szNota = $g.MeasureString($nota, $fNote)
$g.DrawString($nota, $fNote, (New-Object System.Drawing.SolidBrush($muted)), $w - 100 - $szNota.Width, 576)

$g.Dispose()
$bmp.Save((Join-Path $dir 'og-capa.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

# ====================== apple-touch-icon.png (180x180) ======================
# Mesmo mark do favicon (M dourado sobre azul-escuro), escala180/32 =5.625
$ic = New-Object System.Drawing.Bitmap(180, 180)
$gi = [System.Drawing.Graphics]::FromImage($ic)
$gi.TextRenderingHint = $sf
$gi.SmoothingMode = $sm
$gi.Clear($bgTop)
$gi.ScaleTransform([float]5.625, [float]5.625)

$pen = New-Object System.Drawing.Pen($gold, [float]3)
$pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$pen.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
$pen.LineJoin  = [System.Drawing.Drawing2D.LineJoin]::Round
$pontos = @(
  (New-Object System.Drawing.PointF(7, 23)),
  (New-Object System.Drawing.PointF(7, 9)),
  (New-Object System.Drawing.PointF(16, 17)),
  (New-Object System.Drawing.PointF(25, 9)),
  (New-Object System.Drawing.PointF(25, 23))
)
$gi.DrawLines($pen, $pontos)
$pen.Dispose()
$gi.Dispose()
$ic.Save((Join-Path $dir 'apple-touch-icon.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$ic.Dispose()

Get-ChildItem $dir -File | Select-Object Name, Length | Format-Table -AutoSize
