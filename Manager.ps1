# -------------------------------------------------
# اسکریپت اتوماسیون پاورشل ویندوز
# شامل: نصب ابزارها، تم‌ها، aliasها و اتصال به هوش مصنوعی
# -------------------------------------------------

# Step 0: غیرفعال کردن سیاست اجرای اسکریپت (برای اجرای بدون محدودیت)
Set-ExecutionPolicy Bypass -Scope Process -Force

# ----------------------------
# Step 1: نصب Chocolatey و Scoop
# ----------------------------
Write-Host "🛠️ نصب Chocolatey و Scoop..." -ForegroundColor Cyan

# نصب Chocolatey
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# نصب Scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    iex (iwr -useb get.scoop.sh | iex)
    scoop bucket add main
}

# ----------------------------
# Step 2: نصب ابزارهای CLI
# ----------------------------
Write-Host "📦 نصب ابزارهای ضروری..." -ForegroundColor Cyan

# لیست ابزارها برای نصب با Chocolatey
$chocoPackages = @(
    "git",          # کنترل نسخه
    "bat",          # جایگزین cat
    "fzf",          # جستجو تعاملی
    "ripgrep",      # جستجوی سریع
    "thefuck",      # اصلاح خودکار خطاها
    "ntfy",         # نوتیفیکیشن
    "curl",         # انتقال داده
    "python",       # پایتون برای thefuck و AI
    "7zip"          # ابزار فشرده‌سازی
)

# نصب با Chocolatey
foreach ($pkg in $chocoPackages) {
    choco install -y $pkg --no-progress
}

# نصب ابزارهای تخصصی با Scoop
$scoopPackages = @(
    "starship",     # پیش‌بار شیک
    "oh-my-posh",   # تم پاورشل
    "posh-git",     # وضعیت گیت در پاورشل
    "fd"            # جایگزین find
)

foreach ($pkg in $scoopPackages) {
    scoop install $pkg
}

# ----------------------------
# Step 3: نصب ماژول‌های پاورشل
# ----------------------------
Write-Host "⚡ نصب ماژول‌های پاورشل..." -ForegroundColor Cyan

# فعال‌سازی ماژول‌های لازم
Install-Module -Name posh-git -Scope CurrentUser -Force -AllowClobber
Install-Module -Name oh-my-posh -Scope CurrentUser -Force -AllowClobber

# ----------------------------
# Step 4: پیکربندی پروفایل پاورشل
# ----------------------------
Write-Host "📝 تنظیم پروفایل پاورشل..." -ForegroundColor Cyan

# ایجاد پروفایل اگر وجود ندارد
$profilePath = $PROFILE.CurrentUserAllHosts
if (!(Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

# محتوای پروفایل
$profileContent = @"
# -------------------------------------------------
# پروفایل پاورشل خودکار (توسط اسکریپت)
# -------------------------------------------------

# فعال‌سازی ماژول‌ها
Import-Module posh-git -Force
Import-Module oh-my-posh -Force
Invoke-Expression (starship init powershell)

# ----------------------------
# alias‌های کاربردی
# ----------------------------
Set-Alias ll Get-ChildItem -Attributes Force
Set-Alias la Get-ChildItem
Set-Alias l Get-ChildItem -Force
Set-Alias cp Copy-Item
Set-Alias mv Move-Item
Set-Alias rm Remove-Item
Set-Alias cls Clear-Host
Set-Alias ps Get-Process
Set-Alias eg explorer
Set-Alias cat bat
Set-Alias grep Select-String
Set-Alias sudo Start-Process -Verb RunAs

# alias‌های گیت
Set-Alias g git
Set-Alias ga git add
Set-Alias gco git checkout
Set-Alias gbr git branch
Set-Alias gcm git commit -m
Set-Alias gpush git push origin
Set-Alias gpull git pull origin
Set-Alias gstat git status
Set-Alias glog git log --oneline --graph --decorate

# ----------------------------
# فZF (جستجوی تعاملی)
# ----------------------------
function fzf-cd {
    \$dir = Get-ChildItem -Directory | Select-Object -ExpandProperty FullName | fzf --height 20%
    if (\$dir) { Set-Location \$dir }
}
Set-Alias fcd fzf-cd

function fzf-history {
    \$history = Get-History | Select-Object -ExpandProperty CommandLine
    \$selected = \$history | fzf --tac --height 20%
    if (\$selected) { Invoke-Expression \$selected }
}
Set-Alias fh fzf-history

# ----------------------------
# اصلاح خودکار خطاها با thefuck
# ----------------------------
function Fix-Cmd {
    param([string]\$Command)
    \$corrected = thefuck --alias -- \$Command 2>\$null
    if (\$corrected) { 
        Write-Host "✅ دستور اصلاح شد: \$corrected" -ForegroundColor Green
        Invoke-Expression \$corrected 
    }
}
Set-Alias fuck Fix-Cmd

# ----------------------------
# اتصال به هوش مصنوعی (OpenAI)
# ----------------------------
function Invoke-AI {
    param(
        [Parameter(Mandatory=\$true)]
        [string]\$Prompt
    )

    # کلید API را از متغیر محیطی بخواند
    \$apiKey = \$env:OPENAI_API_KEY
    if (-not \$apiKey) {
        Write-Host "❌ کلید API OpenAI یافت نشد! لطفاً متغیر محیطی OPENAI_API_KEY را تنظیم کنید." -ForegroundColor Red
        return
    }

    # ارسال درخواست به OpenAI API
    \$body = @{
        model = "gpt-3.5-turbo"
        messages = @( @{ role = "user"; content = \$Prompt } )
        max_tokens = 512
    } | ConvertTo-Json

    try {
        \$response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" `
            -Method Post `
            -Headers @{ "Authorization" = "Bearer \$apiKey"; "Content-Type" = "application/json" } `
            -Body \$body
        \$answer = \$response.choices[0].message.content
        Write-Host "`n🤖 پاسخ هوش مصنوعی:`n\$answer" -ForegroundColor Cyan
    }
    catch {
        Write-Host "❌ خطا در ارتباط با OpenAI: \$(\$_.Exception.Message)" -ForegroundColor Red
    }
}

Set-Alias ai Invoke-AI
"@

# ذخیره در پروفایل
$profileContent | Out-File -FilePath $profilePath -Encoding UTF8

# بارگذاری پروفایل
. $profilePath

# ----------------------------
# Step 5: پیکربندی ویندوز ترمینال
# ----------------------------
Write-Host "🎨 پیکربندی ویندوز ترمینال..." -ForegroundColor Cyan

# مسیر فایل تنظیمات ویندوز ترمینال
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# اگر ویندوز ترمینال نصب نیست، آن را نصب می‌کند
if (-not (Test-Path $settingsPath)) {
    Write-Host "🔄 ویندوز ترمینال نصب نیست. در حال نصب از Microsoft Store..." -ForegroundColor Yellow
    start-process "ms-store://pdp/?ProductId=9N0DX20HK701" -Wait
    Start-Sleep -Seconds 10
}

# تنظیمات جدید (اگر فایل وجود ندارد، ایجاد می‌کند)
if (Test-Path $settingsPath) {
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

    # افزودن تم رنگی "One Half Dark"
    $darkTheme = @{
        name = "One Half Dark"
        foreground = "#ABB2BF"
        background = "#282C34"
        cursorColor = "#528BFF"
        black = "#282C34"
        red = "#E06C75"
        green = "#98C379"
        yellow = "#D19A66"
        blue = "#61AFEF"
        purple = "#C678DD"
        cyan = "#56B6C2"
        white = "#ABB2BF"
        brightBlack = "#5C6370"
        brightRed = "#E06C75"
        brightGreen = "#98C379"
        brightYellow = "#D19A66"
        brightBlue = "#61AFEF"
        brightPurple = "#C678DD"
        brightCyan = "#56B6C2"
        brightWhite = "#FFFFFF"
    }

    # بررسی وجود تم
    $exists = $false
    foreach ($scheme in $settings.schemes) {
        if ($scheme.name -eq $darkTheme.name) {
            $exists = $true; break
        }
    }
    if (-not $exists) {
        $settings.schemes += $darkTheme
    }

    # تنظیم تم برای پروفایل پاورشل
    foreach ($profile in $settings.profiles.list) {
        if ($profile.commandline -like "*powershell*") {
            $profile.colorScheme = "One Half Dark"
            $profile.font.face = "Cascadia Code NF" # فونت Nerd Font
        }
    }

    # ذخیره تغییرات
    $settings | ConvertTo-Json -Depth 10 | Out-File $settingsPath -Encoding UTF8
    Write-Host "✅ تم ویندوز ترمینال با موفقیت به‌روز شد." -ForegroundColor Green
}
else {
    Write-Host "⚠️ مسیر تنظیمات ویندوز ترمینال یافت نشد." -ForegroundColor Yellow
}

# ----------------------------
# Step 6: دانلود فونت Nerd Font
# ----------------------------
Write-Host "🔤 نصب فونت Cascadia Code Nerd Font..." -ForegroundColor Cyan

$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/CascadiaCode.zip"
$fontPath = "$env:TEMP\CascadiaCode.zip"

# دانلود فونت
try {
    Invoke-WebRequest -Uri $fontUrl -OutFile $fontPath
    Expand-Archive -Path $fontPath -DestinationPath "$env:TEMP\CascadiaCode" -Force
    # نصب فونت (برای ویندوز 10/11)
    $fontFiles = Get-ChildItem "$env:TEMP\CascadiaCode" -Filter "*.ttf" -Recurse
    foreach ($font in $fontFiles) {
        Copy-Item -Path $font.FullName -Destination "$env:WINDIR\Fonts"
    }
    Write-Host "✅ فونت Cascadia Code NF نصب شد." -ForegroundColor Green
}
catch {
    Write-Host "❌ خطا در دانلود فونت: $($_.Exception.Message)" -ForegroundColor Red
}

# ----------------------------
# Step 7: راه‌اندازی نهایی
# ----------------------------
Write-Host "`n🎉 نصب و پیکربندی با موفقیت انجام شد!" -ForegroundColor Green
Write-Host "`n🧪 برای تست دستورات، موارد زیر را اجرا کنید:`n" -ForegroundColor Yellow
Write-Host "  • ll          (لیست فایل‌ها با رنگ)" -ForegroundColor White
Write-Host "  • fcd         (جستجوی دایرکتوری با fzf)" -ForegroundColor White
Write-Host "  • gstat       (وضعیت گیت)" -ForegroundColor White
Write-Host "  • ai \"هوش مصنوعی سلام کن\"   (پرس‌و‌جو از هوش مصنوعی)" -ForegroundColor White
Write-Host "`n📌 نکته: برای استفاده از هوش مصنوعی، کلید API OpenAI را در متغیر محیطی OPENAI_API_KEY تنظیم کنید.`n" -ForegroundColor Cyan

# باز کردن ویندوز ترمینال
Start-Process "wt"
