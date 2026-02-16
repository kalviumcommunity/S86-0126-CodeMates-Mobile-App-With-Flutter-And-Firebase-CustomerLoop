# CustomerLoop Icon Generator Script
# This script helps you generate app icons for all platforms

Write-Host "🎨 CustomerLoop Icon Generator" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Check if icon.png exists
$iconPath = "assets\icon.png"

if (-Not (Test-Path $iconPath)) {
    Write-Host "❌ icon.png not found in assets folder!" -ForegroundColor Red
    Write-Host ""
    Write-Host "📋 Please follow these steps:" -ForegroundColor Yellow
    Write-Host "   1. Open assets\convert_icon.html in your browser" -ForegroundColor White
    Write-Host "   2. Click 'Download icon.png'" -ForegroundColor White
    Write-Host "   3. Save it to the assets folder" -ForegroundColor White
    Write-Host "   4. Run this script again`n" -ForegroundColor White
    
    $openHTML = Read-Host "Would you like to open the converter tool now? (Y/N)"
    if ($openHTML -eq "Y" -or $openHTML -eq "y") {
        Start-Process "assets\convert_icon.html"
        Write-Host "`n✅ Converter opened! Follow the steps above.`n" -ForegroundColor Green
    }
    
    exit
}

Write-Host "✅ Found icon.png" -ForegroundColor Green

# Check icon size
$file = Get-Item $iconPath
$size = $file.Length / 1KB
Write-Host "📏 Icon size: $([math]::Round($size, 2)) KB`n" -ForegroundColor Cyan

# Get dependencies
Write-Host "📦 Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dependencies updated`n" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to get dependencies`n" -ForegroundColor Red
    exit
}

# Generate icons
Write-Host "🎨 Generating app icons for all platforms..." -ForegroundColor Yellow
Write-Host "   This may take a minute...`n" -ForegroundColor Cyan

flutter pub run flutter_launcher_icons

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n🎉 SUCCESS! Icons generated for all platforms!`n" -ForegroundColor Green
    Write-Host "✅ Android icons created" -ForegroundColor Green
    Write-Host "✅ iOS icons created" -ForegroundColor Green
    Write-Host "✅ Web icons created" -ForegroundColor Green
    Write-Host "✅ Windows icons created`n" -ForegroundColor Green
    
    Write-Host "📱 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Run: flutter clean" -ForegroundColor White
    Write-Host "   2. Run: flutter run" -ForegroundColor White
    Write-Host "   3. See your new icon! 🎉`n" -ForegroundColor White
    
    $runNow = Read-Host "Would you like to rebuild the app now? (Y/N)"
    if ($runNow -eq "Y" -or $runNow -eq "y") {
        Write-Host "`n🧹 Cleaning build..." -ForegroundColor Yellow
        flutter clean
        Write-Host "🚀 Building and running app...`n" -ForegroundColor Yellow
        flutter run
    }
} else {
    Write-Host "`n❌ Icon generation failed`n" -ForegroundColor Red
    Write-Host "💡 Try running manually:" -ForegroundColor Yellow
    Write-Host "   dart run flutter_launcher_icons`n" -ForegroundColor White
}
