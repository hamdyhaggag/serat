$baseUrl = "https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/the_9_books"
$outputDir = "assets/hadiths"

# Create output directory if it doesn't exist
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force
}

# List of files to download
$files = @(
    "bukhari.json",
    "muslim.json",
    "abudawud.json",
    "tirmidhi.json",
    "nasai.json",
    "ibnmajah.json"
)

# Download each file
foreach ($file in $files) {
    $url = "$baseUrl/$file"
    $outputPath = Join-Path $outputDir $file
    Write-Host "Downloading $file..."
    Invoke-WebRequest -Uri $url -OutFile $outputPath
}

# Download Nawawi 40 hadiths
$nawawiUrl = "https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/forties/nawawi40.json"
$nawawiOutputPath = Join-Path $outputDir "nawawi40.json"
Write-Host "Downloading nawawi40.json..."
Invoke-WebRequest -Uri $nawawiUrl -OutFile $nawawiOutputPath

Write-Host "All files downloaded successfully!" 