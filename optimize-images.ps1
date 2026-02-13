#!/usr/bin/env pwsh
# =============================================
# SCRIPT DE OPTIMIZACIÓN DE IMÁGENES
# Para Windows PowerShell
# =============================================

Write-Host "🎨 Script de Optimización de Imágenes" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Función para mostrar ayuda
function Show-Help {
    Write-Host "COMANDOS DISPONIBLES:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Optimizar imágenes JPG/PNG (reduce tamaño sin pérdida visible)" -ForegroundColor Green
    Write-Host "2. Convertir imágenes a WebP (mejor compresión)" -ForegroundColor Green
    Write-Host "3. Redimensionar imágenes al tamaño correcto" -ForegroundColor Green
    Write-Host "4. Generar imágenes responsive (múltiples tamaños)" -ForegroundColor Green
    Write-Host ""
    Write-Host "REQUISITOS:" -ForegroundColor Yellow
    Write-Host "- ImageMagick: https://imagemagick.org/script/download.php" -ForegroundColor Gray
    Write-Host "- cwebp (Google): https://developers.google.com/speed/webp/download" -ForegroundColor Gray
    Write-Host ""
}

Show-Help

# Verificar si existe ImageMagick
function Test-ImageMagick {
    try {
        $null = magick --version 2>&1
        return $true
    }
    catch {
        return $false
    }
}

# Verificar si existe cwebp
function Test-CWebP {
    try {
        $null = cwebp -version 2>&1
        return $true
    }
    catch {
        return $false
    }
}

Write-Host "🔍 Verificando herramientas instaladas..." -ForegroundColor Cyan

if (Test-ImageMagick) {
    Write-Host "✅ ImageMagick instalado" -ForegroundColor Green
} else {
    Write-Host "❌ ImageMagick no encontrado" -ForegroundColor Red
    Write-Host "   Instalar desde: https://imagemagick.org/script/download.php" -ForegroundColor Yellow
}

if (Test-CWebP) {
    Write-Host "✅ cwebp instalado" -ForegroundColor Green
} else {
    Write-Host "❌ cwebp no encontrado" -ForegroundColor Red
    Write-Host "   Instalar desde: https://developers.google.com/speed/webp/download" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Función para optimizar JPG/PNG
function Optimize-Images {
    Write-Host "🔧 Optimizando imágenes..." -ForegroundColor Cyan
    
    $images = Get-ChildItem -Path . -Include *.jpg, *.jpeg, *.png -Recurse
    
    if ($images.Count -eq 0) {
        Write-Host "❌ No se encontraron imágenes JPG/PNG" -ForegroundColor Red
        return
    }
    
    foreach ($img in $images) {
        Write-Host "  Procesando: $($img.Name)" -ForegroundColor Gray
        
        $output = $img.FullName
        $temp = "$output.temp"
        
        # Optimizar con ImageMagick (reduce calidad imperceptiblemente pero reduce tamaño)
        & magick "$output" -strip -quality 85 -interlace Plane "$temp"
        
        if ($?) {
            Move-Item -Path $temp -Destination $output -Force
            Write-Host "  ✅ Optimizado: $($img.Name)" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Error al optimizar: $($img.Name)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "✅ Optimización completada" -ForegroundColor Green
}

# Función para convertir a WebP
function Convert-ToWebP {
    Write-Host "🖼️  Convirtiendo imágenes a WebP..." -ForegroundColor Cyan
    
    $images = Get-ChildItem -Path . -Include *.jpg, *.jpeg, *.png -Recurse
    
    if ($images.Count -eq 0) {
        Write-Host "❌ No se encontraron imágenes para convertir" -ForegroundColor Red
        return
    }
    
    foreach ($img in $images) {
        $webpName = [System.IO.Path]::ChangeExtension($img.Name, ".webp")
        $webpPath = Join-Path $img.DirectoryName $webpName
        
        Write-Host "  Convirtiendo: $($img.Name) → $webpName" -ForegroundColor Gray
        
        # Convertir con cwebp (calidad 80 = buen balance)
        & cwebp -q 80 $img.FullName -o $webpPath 2>&1 | Out-Null
        
        if ($?) {
            $originalSize = (Get-Item $img.FullName).Length / 1KB
            $webpSize = (Get-Item $webpPath).Length / 1KB
            $saved = [math]::Round((($originalSize - $webpSize) / $originalSize * 100), 1)
            
            Write-Host "  ✅ Convertido: $webpName (ahorro: $saved%)" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Error al convertir: $($img.Name)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "✅ Conversión completada" -ForegroundColor Green
}

# Función para redimensionar imágenes
function Resize-Images {
    param(
        [int]$Width = 1920
    )
    
    Write-Host "📐 Redimensionando imágenes a ancho máximo: ${Width}px..." -ForegroundColor Cyan
    
    $images = Get-ChildItem -Path . -Include *.jpg, *.jpeg, *.png -Recurse
    
    foreach ($img in $images) {
        Write-Host "  Procesando: $($img.Name)" -ForegroundColor Gray
        
        # Redimensionar manteniendo aspect ratio
        & magick $img.FullName -resize "${Width}x>" $img.FullName
        
        if ($?) {
            Write-Host "  ✅ Redimensionado: $($img.Name)" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "✅ Redimensionado completado" -ForegroundColor Green
}

# Función para generar responsive images
function Generate-ResponsiveImages {
    Write-Host "📱 Generando imágenes responsive..." -ForegroundColor Cyan
    
    $images = Get-ChildItem -Path . -Include *.jpg, *.jpeg, *.png -File
    $sizes = @(320, 640, 768, 1024, 1920)
    
    foreach ($img in $images) {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($img.Name)
        $extension = $img.Extension
        
        Write-Host "  Procesando: $($img.Name)" -ForegroundColor Gray
        
        foreach ($size in $sizes) {
            $outputName = "${baseName}-${size}w${extension}"
            $outputPath = Join-Path $img.DirectoryName $outputName
            
            & magick $img.FullName -resize "${size}x>" -quality 85 $outputPath 2>&1 | Out-Null
            
            if ($?) {
                Write-Host "    ✅ Creado: $outputName" -ForegroundColor Green
            }
        }
    }
    
    Write-Host ""
    Write-Host "✅ Imágenes responsive generadas" -ForegroundColor Green
}

# Menú interactivo
function Show-Menu {
    Write-Host ""
    Write-Host "SELECCIONA UNA OPCIÓN:" -ForegroundColor Yellow
    Write-Host "1. Optimizar imágenes existentes (JPG/PNG)" -ForegroundColor White
    Write-Host "2. Convertir a WebP" -ForegroundColor White
    Write-Host "3. Redimensionar imágenes" -ForegroundColor White
    Write-Host "4. Generar imágenes responsive" -ForegroundColor White
    Write-Host "5. Ejecutar todo (optimizar + WebP)" -ForegroundColor White
    Write-Host "0. Salir" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Opción"
    
    switch ($choice) {
        "1" {
            if (Test-ImageMagick) {
                Optimize-Images
            } else {
                Write-Host "❌ ImageMagick no está instalado" -ForegroundColor Red
            }
        }
        "2" {
            if (Test-CWebP) {
                Convert-ToWebP
            } else {
                Write-Host "❌ cwebp no está instalado" -ForegroundColor Red
            }
        }
        "3" {
            if (Test-ImageMagick) {
                $width = Read-Host "Ancho máximo en pixels (default: 1920)"
                if ([string]::IsNullOrEmpty($width)) { $width = 1920 }
                Resize-Images -Width $width
            } else {
                Write-Host "❌ ImageMagick no está instalado" -ForegroundColor Red
            }
        }
        "4" {
            if (Test-ImageMagick) {
                Generate-ResponsiveImages
            } else {
                Write-Host "❌ ImageMagick no está instalado" -ForegroundColor Red
            }
        }
        "5" {
            if ((Test-ImageMagick) -and (Test-CWebP)) {
                Optimize-Images
                Convert-ToWebP
            } else {
                Write-Host "❌ Faltan herramientas necesarias" -ForegroundColor Red
            }
        }
        "0" {
            Write-Host ""
            Write-Host "👋 ¡Hasta luego!" -ForegroundColor Cyan
            exit
        }
        default {
            Write-Host "❌ Opción inválida" -ForegroundColor Red
        }
    }
    
    # Volver a mostrar el menú
    Show-Menu
}

# Iniciar menú si las herramientas están disponibles
if ((Test-ImageMagick) -or (Test-CWebP)) {
    Show-Menu
} else {
    Write-Host ""
    Write-Host "⚠️  Instala las herramientas necesarias para continuar" -ForegroundColor Yellow
    Write-Host ""
}
