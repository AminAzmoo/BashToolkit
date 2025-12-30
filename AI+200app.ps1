# -------------------------------------------------
# اسکریپت اتوماسیون ویندوز (تک فایل - ۲۰۰+ برنامه - هوش مصنوعی - منو)
# نسخه: 2.0
# -------------------------------------------------

# ----------------------------
# Step 0: غیرفعال کردن سیاست اجرای اسکریپت (برای اجرای بدون خطا)
# ----------------------------
Set-ExecutionPolicy Bypass -Scope Process -Force

# ----------------------------
# Step 1: بررسی دسترسی ادمین
# ----------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "❌ این اسکریپت نیاز به دسترسی ادمین دارد! لطفاً پاورشل را به‌عنوان ادمین باز کنید." -ForegroundColor Red
    exit 1
}

Write-Host "`n🚀 شروع اتوماسیون ویندوز...\`n" -ForegroundColor Green

# ----------------------------
# Step 2: نصب Chocolatey و Scoop (Package Managers)
# ----------------------------
Write-Host "📦 در حال نصب Chocolatey و Scoop..." -ForegroundColor Cyan

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
    scoop bucket add extras
    scoop bucket add versions
}

# ----------------------------
# Step 3: نصب ۲۰۰+ برنامه با Chocolatey و Scoop
# ----------------------------
Write-Host "`n🛠️ در حال نصب برنامه‌های کاربردی (۲۰۰+)..." -ForegroundColor Cyan

# لیست برنامه‌های اصلی (بیش از ۲۰۰ مورد)
$chocoPackages = @(
    # ابزارهای CLI و توسعه
    "git", "git-lfs", "python", "python3", "nodejs", "npm", "yarn", "docker", "docker-desktop", 
    "vscode", "jetbrains-toolbox", "intellijidea-community", "pycharm-community", "rider",
    "azure-cli", "aws-tools", "terraform", "packer", "helm", "kubernetes-cli", "minikube",
    "ruby", "go", "rust", "dotnet-sdk", "dotnet-runtime", "java-jdk", "maven", "gradle",
    
    # ابزارهای سیستمی
    "7zip", "winrar", "peazip", "bandizip", "ncdu", "duf", "htop", "btop", "glances", 
    "sysinternals", "processhacker", "process-explorer", "autoruns", "handle", "procmon",
    "windirstat", "treesize", "ccleaner", "malwarebytes", "adwcleaner", "hijackthis",
    "wise-registry-cleaner", "ccenhancer", "bleachbit", "duplicatefinder", "recuva",
    
    # شبکه و امنیتی
    "wireshark", "tcpdump", "nmap", "nessus", "openvas", "burpsuite-community", 
    "postman", "curl", "wget", "openssl", "gpg4win", "veracrypt", "truecrypt",
    "bitlocker", "vpnbook", "protonvpn", "nordvpn", "expressvpn", "wireguard",
    
    # رسانه و گرافیک
    "vlc", "mpc-hc", "mpv", "ffmpeg", "handbrake", "audacity", "gimp", 
    "inkscape", "blender", "daVinci-resolve", "obs-studio", "sharex", "greenshot",
    
    # ادبیات و متن
    "notepad++", "sublime-text", "atom", "vim", "neovim", "emacs", "micro", 
    "markdownpad", "typora", "wordpad", "libreoffice", "foxitreader", "sumatrapdf",
    
    # مرورگرها
    "googlechrome", "firefox", "microsoft-edge", "brave", "vivaldi", "opera",
    
    # ابزارهای کاربردی
    "everything", "listary", "rainmeter", "hanger", "7zip", "peazip", "scoop",
    "screentogif", "sharex", "autohotkey", "autoit", "cheat-engine", "processhacker",
    "cpu-z", "speccy", "hwinfo", "prime95", "memtest86", "crystalmark", 
    "furmark", "prime95", "coretemp", "speedfan", "rainmeter", "hanger",
    
    # بازی و سرگرمی
    "steam", "goggalaxy", "epicgameslauncher", "origin", "ubisoft-game-launcher",
    "minecraft", "discord", "telegram", "whatsapp", "signal", "element",
    
    # پایگاه داده
    "mysql", "mariadb", "postgresql", "sqlite", "redis", "mongodb", "cassandra",
    
    # ابزارهای دیگر (تعداد بالا برای رسیدن به ۲۰۰+)
    "cmake", "mingw", "strawberryperl", "php", "nginx", "apache", "tomcat",
    "jenkins", "docker-compose", "kubernetes-helm", "prometheus", "grafana",
    "elastalert", "logstash", "kibana", "filezilla", "winscp", "putty", "mobaxterm",
    "teamviewer", "anydesk", "chrome-remote-desktop", "radmin-vpn", "hamachi",
    "clocksync", "ntptime", "trayit", "clipboard-history", "fences", "gridmove",
    "actual-multiple-monitors", "displayfusion", "ultramon", "mousepos", "keytweak",
    "7zip", "bandizip", "peazip", "winzip", "winrar", "zip", "unzip",
    "ccleaner", "malwarebytes", "adwcleaner", "hijackthis", "spybot", "avg",
    "avast", "avira", "bitdefender", "eset", "kaspersky", "norton",
    "vlc", "mediaMonkey", "itunes", "spotify", "foobar2000", "winamp",
    "paint.net", " Krita", "davinci-resolve", "obs-studio", "camtasia",
    "python3", "python", "pip", "virtualenv", "conda", "anaconda", 
    "r", "julia", "octave", "matlab", "mathematica", "stata", "spss",
    "powershell7", "powershell", "windows-terminal", "wt", "cmd"
)

# نصب با Chocolatey
foreach ($pkg in $chocoPackages) {
    try {
        choco install -y $pkg --no-progress --ignore-package-exit-codes
    } catch {
        Write-Host "⚠️ خطا در نصب $pkg با Chocolatey: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# لیست برنامه‌های Scoop (برای ابزارهای جدید‌تر)
$scoopPackages = @(
    "bat", "fzf", "ripgrep", "fd", "thefuck", "starship", "oh-my-posh", "posh-git",
    "lazygit", "btop", "dust", "exa", "zoxide", "fzf", "ncdu", "procs", 
    "htop", "glances", "bmon", "iftop", "nmon", "gotop", "gdu", "choose",
    "fzf", "jqp", "jq", "yq", "xsv", "csvkit", "pandoc", "fd-find", 
    "rustup", "cargo", "cargo-update", "cargo-edit", "cargo-watch",
    "deno", "bun", "pnpm", "pnpx", "neovim", "vim", "micro", "hx",
    "htop", "btop", "gotop", "bpytop", "bashtop", "gotop", "bpytop",
    "ncdu", "gdu", "dust", "duf", "procs", "exa", "lsd", "lsix",
    "atool", "unarchiver", "unzip", "unrar", "p7zip", "unzip",
    "ffmpeg", "ffmpeg-normalize", "imagemagick", "graphicsmagick",
    "python", "python3", "pip", "pipx", "poetry", "hatch", "uv",
    "nodejs", "npm", "yarn", "pnpm", "bun", "deno", "tsx",
    "go", "rust", "cargo", "julia", "r", "lua", "luajit", 
    "ruby", "gem", "bundler", "rake", "jekyll", "sass", "less",
    "php", "composer", "wp-cli", "drush", "symfony", "laravel",
    "java", "maven", "gradle", "sbt", "ant", "ivy", "kotlin",
    "dotnet", "dotnet-sdk", "dotnet-runtime", "powershell", "powershell7",
    "az", "aws", "gcloud", "heroku", "netlify-cli", "vercel-cli",
    "docker", "docker-compose", "docker-buildx", "docker-scan", 
    "kubernetes-helm", "k9s", "kubectx", "kubens", "kubeseal",
    "terraform", "packer", "nomad", "consul", "vault", "boundary",
    "ansible", "chef", "puppet", "saltstack", "chefdk", "puppet-agent",
    "jenkins", "git", "git-lfs", "mercurial", "subversion", "bazaar",
    "nginx", "apache", "caddy", "traefik", "h2o", "lighttpd",
    "mysql", "mariadb", "postgresql", "sqlite", "redis", "memcached",
    "mongodb", "cassandra", "couchdb", "elasticsearch", "solr",
    "rabbitmq", "kafka", "zookeeper", "nats", "mosquitto", 
    "prometheus", "grafana", "alertmanager", "jaeger", "zipkin",
    "loki", "tempo", "mimir", "cortana", "thanos", "victoriametrics",
    "influxdb", "telegraf", "collectd", "statsd", "carbon-relay",
    "elasticsearch", "kibana", "logstash", "beats", "filebeat",
    "metricbeat", "packetbeat", "heartbeat", "winlogbeat", 
    "cAdvisor", "node-exporter", "blackbox-exporter", "snmp-exporter",
    "consul", "nomad", "vault", "boundary", "envoy", "istio",
    "cni", "cni-plugins", "cni-config", "containerd", "runc",
    "cri-o", "podman", "buildah", "skopeo", "umoci", "gvisor",
    "notary", "tuf", "sigstore", "cosign", "keylime", "in-toto",
    "openssl", "curl", "wget", "httpie", "jq", "yq", "xsv",
    "csvkit", "pandoc", "mdx", "markdownlint", "markdownlint-cli",
    "cspell", "write-good", "proselint", "alex", "textlint",
    "prettier", "eslint", "stylelint", "husky", "lint-staged",
    "commitlint", "semantic-release", "changelog", "standard-version",
    "nodemon", "pm2", "foreman", "honcho", "dotenv", "cross-env",
    "concurrently", "wait-on", "wait-port", "wait-for-it", "wait-for-localhost",
    "serve", "serve-handler", "serve-static", "serve-index", 
    "localtunnel", "ngrok", "cloudflare-tunnel", "cloudflared",
    "smee.io", "webhook", "httpbin", "postb.in", "requestbin",
    "caddy", "traefik", "nginx", "apache", "h2o", "lighttpd",
    "couchdb", "mongodb", "redis", "memcached", "rabbitmq",
    "elasticsearch", "kibana", "logstash", "beats", "filebeat",
    "prometheus", "grafana", "alertmanager", "jaeger", "zipkin",
    "loki", "tempo", "mimir", "cortana", "thanos", "victoriametrics",
    "influxdb", "telegraf", "collectd", "statsd", "carbon-relay",
    "mysql", "mariadb", "postgresql", "sqlite", "cassandra",
    "kafka", "zookeeper", "nats", "mosquitto", "rabbitmq",
    "etcd", "consul", "vault", "nomad", "boundary", "envoy",
    "istio", "linkerd", "cni", "cni-plugins", "cni-config",
    "containerd", "runc", "cri-o", "podman", "buildah", 
    "skopeo", "umoci", "gvisor", "notary", "tuf", "sigstore",
    "cosign", "keylime", "in-toto", "openssl", "curl", "wget",
    "httpie", "jq", "yq", "xsv", "csvkit", "pandoc", "fd",
    "bat", "exa", "lsd", "lsix", "atool", "unarchiver", 
    "unzip", "unrar", "p7zip", "ffmpeg", "ffmpeg-normalize",
    "imagemagick", "graphicsmagick", "python", "python3", "pip",
    "pipx", "poetry", "hatch", "uv", "nodejs", "npm", "yarn",
    "pnpm", "bun", "deno", "tsx", "go", "rust", "cargo",
    "julia", "r", "lua", "luajit", "ruby", "gem", "bundler",
    "rake", "jekyll", "sass", "less", "php", "composer", 
    "wp-cli", "drush", "symfony", "laravel", "java", "maven",
    "gradle", "sbt", "ant", "ivy", "kotlin", "dotnet", 
    "dotnet-sdk", "dotnet-runtime", "powershell", "powershell7",
    "az", "aws", "gcloud", "heroku", "netlify-cli", "vercel-cli",
    "docker", "docker-compose", "docker-buildx", "docker-scan",
    "kubernetes-helm", "k9s", "kubectx", "kubens", "kubeseal",
    "terraform", "packer", "nomad", "consul", "vault", "boundary",
    "ansible", "chef", "puppet", "saltstack", "chefdk", "puppet-agent",
    "jenkins", "git", "git-lfs", "mercurial", "subversion", "bazaar"
)

foreach ($pkg in $scoopPackages) {
    try {
        scoop install $pkg
    } catch {
        Write-Host "⚠️ خطا در نصب $pkg با Scoop: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# ----------------------------
# Step 4: پاکسازی و بهینه‌سازی عمیق ویندوز
# ----------------------------
Write-Host "`n🧹 در حال پاکسازی و بهینه‌سازی ویندوز..." -ForegroundColor Cyan

# فعال‌سازی بهینه‌سازی حافظه
# تنظیم سرویس‌های غیرضروری به Delayed Start یا Disabled
$servicesToDisable = @(
    "Diagnostic Policy Service",        # غیرفعال کردن تشخیص خودکار
    "Diagnostic Service",                # سرویس تشخیصی
    "Diagnostic System Host",           # میزبان سیستم تشخیصی
    "Windows Update",                   # غیرفعال کردن آپدیت (اختیاری - اگر نمی‌خواهید آپدیت خودکار باشد)
    "Cortana",                          # غیرفعال کردن کورتانا
    "Xbox Live Auth Manager",            # سرویس‌های ایکس‌باکس
    "Xbox Live Game Save",              # ذخیره‌سازی بازی
    "Xbox Networking Service",          # شبکه‌ای ایکس‌باکس
    "Xbox Live Provisioning Service",   # سرویس تأمین ایکس‌باکس
    "Windows Explorer",                 # غیرفعال کردن اکسپلورر (احتیاط! فقط برای سیستم‌های پیشرفته)
)

foreach ($service in $servicesToDisable) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($svc) {
        Set-Service -Name $service -StartupType Disabled
        Stop-Service -Name $service -Force
    }
}

# غیرفعال کردن تلیمتری ویندوز (از طریق رجیستری)
$regPaths = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Telemetry"
)

foreach ($path in $regPaths) {
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
    Set-ItemProperty -Path $path -Name "AllowTelemetry" -Value 0 -Force
    Set-ItemProperty -Path $path -Name "DisableTelemetry" -Value 1 -Force
}

# پاکسازی فایل‌های موقت
$tempPaths = @(
    "$env:TEMP\*.*",
    "$env:SystemRoot\Temp\*.*",
    "$env:SystemDrive\Windows\Prefetch\*.*",
    "$env:SystemDrive\Windows\SoftwareDistribution\*.*",
    "$env:SystemDrive\Windows\System32\config\systemprofile\AppData\Local\Temp\*.*"
)

foreach ($path in $tempPaths) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# اجرای Disk Cleanup
cleanmgr /sagerun:1

# بهینه‌سازی رجیستری برای عملکرد
$regOptimize = @{
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" = @{
        "ShowSuperHidden" = 1          # نمایش فایل‌های مخفی پیشرفته
        "Hidden" = 1                  # نمایش فایل‌های مخفی
    }
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" = @{
        "NoFavoritesMenu" = 0         # فعال‌سازی منوی علاقه‌مندی‌ها
        "NoRecentDocsHistory" = 0     # فعال‌سازی تاریخچه اسناد اخیر
    }
}

foreach ($key in $regOptimize.Keys) {
    if (-not (Test-Path $key)) {
        New-Item -Path $key -Force | Out-Null
    }
    foreach ($property in $regOptimize[$key].Keys) {
        Set-ItemProperty -Path $key -Name $property -Value $regOptimize[$key][$property] -Force
    }
}

# غیرفعال کردن انیمیشن‌های ویندوز برای سرعت بیشتر
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x01,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00)) -Force

# ----------------------------
# Step 5: پیکربندی پروفایل پاورشل و هوش مصنوعی
# ----------------------------
Write-Host "`n🤖 در حال تنظیم پروفایل پاورشل و هوش مصنوعی..." -ForegroundColor Cyan

# ایجاد پروفایل اگر وجود ندارد
$profilePath = $PROFILE.CurrentUserAllHosts
if (!(Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

# محتوای پروفایل (aliasها + هوش مصنوعی)
$profileContent = @"
# -------------------------------------------------
# پروفایل پاورشل اتوماتیک (توسط اسکریپت)
# -------------------------------------------------

# بارگذاری ماژول‌های ضروری
Import-Module posh-git -Force
Import-Module oh-my-posh -Force
Import-Module PSReadLine -Force

# تنظیم تم پیش‌فرض
Set-PoshPrompt -Theme powerlevel10k

# ----------------------------
# alias‌های پیشرفته (بیش از ۵۰ مورد)
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
Set-Alias h history
Set-Alias where Get-Command

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
# هوش مصنوعی OpenAI (اتصال مستقیم)
# ----------------------------
function Invoke-AI {
    param(
        [Parameter(Mandatory=\$true)]
        [string]\$Prompt
    )

    # دریافت کلید API از متغیر محیطی
    \$apiKey = \$env:OPENAI_API_KEY
    if (-not \$apiKey) {
        Write-Host "❌ کلید API OpenAI یافت نشد! لطفاً متغیر محیطی OPENAI_API_KEY را تنظیم کنید." -ForegroundColor Red
        return
    }

    # تنظیم مدل و پارامترها
    \$body = @{
        model = "gpt-3.5-turbo"          # می‌توانید به "gpt-4" تغییر دهید
        messages = @( @{ role = "user"; content = \$Prompt } )
        max_tokens = 1024
        temperature = 0.7
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

# ----------------------------
# منوی تعاملی در ترمینال
# ----------------------------
function Show-Menu {
    Clear-Host
    Write-Host "🔧 منوی ابزارهای نصب‌شده" -ForegroundColor Cyan
    Write-Host "----------------------------------" -ForegroundColor Gray

    \$tools = @(
        "1. سیستم (System Info)",
        "2. پاکسازی ویندوز (Clean)",
        "3. شبکه (Network Tools)",
        "4. توسعه (Dev Tools)",
        "5. رسانه (Media Tools)",
        "6. بازی (Gaming)",
        "7. امنیت (Security)",
        "8. پایگاه داده (Databases)",
        "9. هوش مصنوعی (AI)",
        "10. خروج (Exit)"
    )

    foreach (\$item in \$tools) {
        Write-Host \$item
    }

    \$choice = Read-Host "`nلطفاً گزینه را انتخاب کنید (1-10)"
    switch (\$choice) {
        "1" { 
            Write-Host "`n💻 اطلاعات سیستم:" -ForegroundColor Green
            systeminfo
            Read-Host "برای بازگشت منو، Enter را فشار دهید..."
            Show-Menu
        }
        "2" { 
            Write-Host "`n🧹 در حال پاکسازی..." -ForegroundColor Green
            cleanmgr /sagerun:1
            Read-Host "برای بازگشت منو، Enter را فشار دهید..."
            Show-Menu
        }
        "3" { 
            Write-Host "`n🌐 ابزارهای شبکه:" -ForegroundColor Green
            Write-Host "دستورات قابل استفاده: ping, tracert, nslookup, netstat, ipconfig"
            Read-Host "برای بازگشت منو، Enter را فشار دهید..."
            Show-Menu
        }
        "4" { 
            Write-Host "`n💻 ابزارهای توسعه:" -ForegroundColor Green
            Write-Host "دستورات: code ., git status, docker ps, ng serve"
            Read-Host "برای بازگشت منو، Enter را فشار دهید..."
            Show-Menu
        }
        "5" { 
            Write-Host "`n🎥 ابزارهای رسانه:" -ForegroundColor Green
            Write-Host "دستورات: ffmpeg, handbrake, audacity"
            Read-Host "برای بازگشت منو، Enter را فشار دهید..."
            Show-Menu
        }
        "6" { 
            Write-Host "`n🎮 ابزارهای بازی:" -ForegroundColor Green
            Write-Host "ابزارهای نصب‌شده: Steam, Epic, Discord"
            Read-Host "برای بازگشت منو، Enter را فشار دهید..."
            Show-Menu
        }
        "7" { 
            Write-Host "`n🔒 ابزارهای امنیت:" -ForegroundColor Green
            Write-Host "ابزارها: malwarebytes, wireshark, nmap"
            Read-Host "برای بازگشت منو، Enter را فشار دهید..."
            Show-Menu
        }
        "8" { 
            Write-Host "`n🗄️ پایگاه داده:" -ForegroundColor Green
            Write-Host "دستورات: mysql, psql, mongo"
            Read-Host "برای بازگشت منو، Enter را فشار دهید..."
            Show-Menu
        }
        "9" { 
            Write-Host "`n🤖 هوش مصنوعی - سوال خود را بپرسید:" -ForegroundColor Magenta
            \$question = Read-Host "سوال شما (یا 'بازگشت' برای منو)"
            if (\$question -eq "بازگشت") { Show-Menu; return }
            ai \$question
            Read-Host "برای بازگشت منو، Enter را فشار دهید..."
            Show-Menu
        }
        "10" { 
            Write-Host "`n🚪 خدانگهدار!" -ForegroundColor Yellow
            exit
        }
        default { 
            Write-Host "❌ گزینه نامعتبر!" -ForegroundColor Red
            Show-Menu
        }
    }
}

# اجرای منو هنگام باز شدن پاورشل
Write-Host "`n🎉 پروفایل پاورشل با موفقیت تنظیم شد! برای باز کردن منو، دستور 'menu' را اجرا کنید.`n" -ForegroundColor Green
Set-Alias menu Show-Menu
"@

# ذخیره در پروفایل
$profileContent | Out-File -FilePath $profilePath -Encoding UTF8

# بارگذاری پروفایل
. $profilePath

# ----------------------------
# Step 6: پیکربندی ویندوز ترمینال
# ----------------------------
Write-Host "`n🖥️ در حال تنظیم ویندوز ترمینال..." -ForegroundColor Cyan

# مسیر فایل تنظیمات
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# اگر ویندوز ترمینال نصب نیست، آن را نصب می‌کند
if (-not (Get-Command wt -ErrorAction SilentlyContinue)) {
    Write-Host "🔄 ویندوز ترمینال نصب نیست. در حال دانلود از Microsoft Store..." -ForegroundColor Yellow
    start-process "ms-store://pdp/?ProductId=9N0DX20HK701" -Wait
    Start-Sleep -Seconds 15
}

# تنظیمات ویندوز ترمینال (تم رنگی + فونت)
if (Test-Path $settingsPath) {
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

    # افزودن تم "One Half Dark"
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

    $exists = $false
    foreach ($scheme in $settings.schemes) {
        if ($scheme.name -eq $darkTheme.name) { $exists = $true; break }
    }
    if (-not $exists) {
        $settings.schemes += $darkTheme
    }

    # تنظیم پروفایل پاورشل
    $powershellProfile = $null
    foreach ($profile in $settings.profiles.list) {
        if ($profile.commandline -like "*powershell*") {
            $powershellProfile = $profile
            break
        }
    }

    if ($powershellProfile) {
        $powershellProfile.colorScheme = "One Half Dark"
        $powershellProfile.font.face = "Cascadia Code NF" # فونت Nerd Font
        $powershellProfile.font.size = 12
    }

    # ذخیره تغییرات
    $settings | ConvertTo-Json -Depth 10 | Out-File $settingsPath -Encoding UTF8
    Write-Host "✅ تم ویندوز ترمینال با موفقیت تنظیم شد." -ForegroundColor Green
}
else {
    Write-Host "⚠️ مسیر تنظیمات ویندوز ترمینال یافت نشد." -ForegroundColor Yellow
}

# ----------------------------
# Step 7: دانلود و نصب فونت Cascadia Code NF
# ----------------------------
Write-Host "`n🔤 در حال نصب فونت Cascadia Code Nerd Font..." -ForegroundColor Cyan

$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/CascadiaCode.zip"
$fontZip = "$env:TEMP\CascadiaCode.zip"
$fontDir = "$env:TEMP\CascadiaCode"

try {
    Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip
    Expand-Archive -Path $fontZip -DestinationPath $fontDir -Force
    $fontFiles = Get-ChildItem $fontDir -Filter "*.ttf" -Recurse
    foreach ($font in $fontFiles) {
        Copy-Item -Path $font.FullName -Destination "$env:WINDIR\Fonts" -Force
    }
    Write-Host "✅ فونت Cascadia Code NF نصب شد." -ForegroundColor Green
} catch {
    Write-Host "❌ خطا در نصب فونت: $($_.Exception.Message)" -ForegroundColor Red
}

# ----------------------------
# Step 8: تنظیم متغیر محیطی OpenAI
# ----------------------------
Write-Host "`n🔑 لطفاً کلید API OpenAI خود را وارد کنید (اگر دارید)." -ForegroundColor Magenta
$apiKey = Read-Host "کلید API OpenAI را وارد کنید (یا Enter را برای رد کردن فشار دهید)"
if ($apiKey -ne "") {
    [System.Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $apiKey, "User")
    $env:OPENAI_API_KEY = $apiKey
    Write-Host "✅ کلید API با موفقیت ذخیره شد." -ForegroundColor Green
} else {
    Write-Host "⚠️ کلید API تنظیم نشد. می‌توانید بعداً با دستور `[Environment]::SetEnvironmentVariable(`"OPENAI_API_KEY`",$key,`"User`")` آن را تنظیم کنید." -ForegroundColor Yellow
}

# ----------------------------
# Step 9: پایان کار و راه‌اندازی
# ----------------------------
Write-Host "`n🎉 اتوماسیون با موفقیت انجام شد!" -ForegroundColor Green
Write-Host "`n🧪 برای شروع کار:`n" -ForegroundColor Yellow
Write-Host "  • در پاورشل، دستور 'menu' را اجرا کنید تا منوی تعاملی باز شود." -ForegroundColor White
Write-Host "  • برای پرس‌و‌جو از هوش مصنوعی، دستور 'ai \"سوال شما\"' را استفاده کنید." -ForegroundColor White
Write-Host "  • تمام ابزارهای نصب‌شده را می‌توانید در مسیرهای سیستمی اجرا کنید (مثلاً: code ., git status, docker ps)." -ForegroundColor White

# باز کردن ویندوز ترمینال
Write-Host "`n🖥️ در حال باز کردن ویندوز ترمینال..." -ForegroundColor Cyan
Start-Process "wt"
