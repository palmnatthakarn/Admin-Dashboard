# 🗑️ Project Cleanup Script
# ลบไฟล์ test และ .bat ที่ไม่จำเป็นออกจากโปรเจค

Write-Host "🧹 Starting Project Cleanup..." -ForegroundColor Green
Write-Host "=" * 50

# สร้างรายการไฟล์ที่จะลบ
$testFiles = @(
    "check_api_format.dart",
    "compare_api_formats.dart", 
    "debug_api_response.dart",
    "simple_test_dealers.dart",
    "test_api_connection.dart",
    "test_api_dealer_filter.dart",
    "test_api_fixed.dart",
    "test_api_speed.dart",
    "test_data_transformation.dart",
    "test_dealer_api.dart",
    "test_dealer_filter.dart",
    "test_dealer_filtering.dart",
    "test_dealer_simple.dart",
    "test_dealers_api.dart",
    "test_dealers_wrapper.dart",
    "test_direct_api.dart",
    "test_final_fix.dart",
    "test_flutter_dealer_filter.dart",
    "test_new_transformation.dart",
    "test_products_safe_cast.dart",
    "test_products_table_performance.dart",
    "test_server_side_filtering.dart",
    "test_simple_api.dart",
    "test_table_widget_performance.dart",
    "test_transformation_simple.dart"
)

$batFiles = @(
    "run_performance_tests.bat",
    "start-api-server.bat", 
    "start-remote-api-server.bat",
    "test_api.bat"
)

# ลบไฟล์ test
Write-Host "🧪 Removing test files..." -ForegroundColor Yellow
$removedTestFiles = 0
foreach ($file in $testFiles) {
    if (Test-Path $file) {
        try {
            Remove-Item $file -Force
            Write-Host "   ✅ Removed: $file" -ForegroundColor Green
            $removedTestFiles++
        }
        catch {
            Write-Host "   ❌ Failed to remove: $file" -ForegroundColor Red
        }
    }
    else {
        Write-Host "   ⚠️  Not found: $file" -ForegroundColor Gray
    }
}

# ลบไฟล์ .bat
Write-Host "`n🔧 Removing .bat files..." -ForegroundColor Yellow
$removedBatFiles = 0
foreach ($file in $batFiles) {
    if (Test-Path $file) {
        try {
            Remove-Item $file -Force
            Write-Host "   ✅ Removed: $file" -ForegroundColor Green
            $removedBatFiles++
        }
        catch {
            Write-Host "   ❌ Failed to remove: $file" -ForegroundColor Red
        }
    }
    else {
        Write-Host "   ⚠️  Not found: $file" -ForegroundColor Gray
    }
}

# สรุปผลลัพธ์
Write-Host "`n📊 Cleanup Summary:" -ForegroundColor Cyan
Write-Host "=" * 30
Write-Host "   Test files removed: $removedTestFiles" -ForegroundColor Green
Write-Host "   Batch files removed: $removedBatFiles" -ForegroundColor Green
Write-Host "   Total files removed: $($removedTestFiles + $removedBatFiles)" -ForegroundColor Green

# ตรวจสอบไฟล์ที่เหลือ
Write-Host "`n📋 Remaining important files:" -ForegroundColor Cyan
$importantFiles = @(
    "lib/",
    "assets/", 
    "api-server/",
    "test/",
    "pubspec.yaml",
    "README.md"
)

foreach ($file in $importantFiles) {
    if (Test-Path $file) {
        Write-Host "   ✅ $file" -ForegroundColor Green
    }
    else {
        Write-Host "   ❌ $file (MISSING!)" -ForegroundColor Red
    }
}

Write-Host "`n🎉 Project cleanup completed!" -ForegroundColor Green
Write-Host "📁 Your project is now cleaner and more organized." -ForegroundColor Cyan

# ถามว่าต้องการลบไฟล์ documentation หรือไม่
Write-Host "`n❓ Do you want to remove documentation files too? (y/N)" -ForegroundColor Yellow
$response = Read-Host

if ($response -eq "y" -or $response -eq "Y") {
    $docFiles = @(
        "DESIGN_IMPROVEMENTS.md",
        "PERFORMANCE_TESTING.md", 
        "SOLUTION.md",
        "TROUBLESHOOTING.md",
        "USAGE.md",
        "LARGE_DATASET_STRATEGY.md",
        "FILES_TO_DELETE.md"
    )
    
    Write-Host "📚 Removing documentation files..." -ForegroundColor Yellow
    $removedDocFiles = 0
    foreach ($file in $docFiles) {
        if (Test-Path $file) {
            try {
                Remove-Item $file -Force
                Write-Host "   ✅ Removed: $file" -ForegroundColor Green
                $removedDocFiles++
            }
            catch {
                Write-Host "   ❌ Failed to remove: $file" -ForegroundColor Red
            }
        }
    }
    Write-Host "   📚 Documentation files removed: $removedDocFiles" -ForegroundColor Green
}
else {
    Write-Host "📚 Documentation files kept." -ForegroundColor Cyan
}

Write-Host "`n✨ All done! Your Flutter project is ready for production." -ForegroundColor Green