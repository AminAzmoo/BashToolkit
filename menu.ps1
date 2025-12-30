# ============================================================================
# ALL-IN-ONE POWERSHELL SCRIPT (English)
# Features:
#   - Install 100+ apps selectively via interactive menu
#   - Deep Windows optimization (cleanup, telemetry, registry)
#   - AI chat (OpenAI)
#   - Stylish terminal interface
#   - Single file, no redundant installations
# ============================================================================

# ----------------------------
# Step 0: Bypass Execution Policy & Check Admin
# ----------------------------
Set-ExecutionPolicy Bypass -Scope Process -Force

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "❌ Run as Administrator!" -ForegroundColor Red
    exit 1
}

# ----------------------------
# Step 1: Check & Install Package Managers (Only if Missing)
# ----------------------------
Write-Host "`n🚀 Initializing system tools..." -ForegroundColor Cyan

$chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue
$scoopInstalled = Get-Command scoop -ErrorAction SilentlyContinue

if (-not $chocoInstalled) {
    Write-Host "📦 Installing Chocolatey..." -ForegroundColor Yellow
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
    Write-Host "✅ Chocolatey already installed." -ForegroundColor Green
}

if (-not $scoopInstalled) {
    Write-Host "📦 Installing Scoop..." -ForegroundColor Yellow
    iex (iwr -useb get.scoop.sh | iex)
    scoop bucket add main > $null
    scoop bucket add extras > $null
    scoop bucket add versions > $null
} else {
    Write-Host "✅ Scoop already installed." -ForegroundColor Green
}

# ----------------------------
# Step 2: Define 100+ Apps (Categorized)
# ----------------------------
$allApps = @{
    "Development" = @(
        @{ ID = "git";          Name = "Git";          Desc = "Version control" }
        @{ ID = "github-cli";   Name = "GitHub CLI";   Desc = "CLI for GitHub" }
        @{ ID = "nodejs";       Name = "Node.js";      Desc = "JavaScript runtime" }
        @{ ID = "python";       Name = "Python";       Desc = "Programming language" }
        @{ ID = "vscode";       Name = "VS Code";      Desc = "Code editor" }
        @{ ID = "docker-desktop"; Name = "Docker";     Desc = "Containerization" }
        @{ ID = "jetbrains-toolbox"; Name = "JetBrains Toolbox"; Desc = "IDEs bundle" }
        @{ ID = "intellijidea-ultimate"; Name = "IntelliJ IDEA"; Desc = "Java IDE" }
        @{ ID = "pycharm-professional"; Name = "PyCharm"; Desc = "Python IDE" }
        @{ ID = "rider";        Name = "Rider";        Desc = ".NET IDE" }
        @{ ID = "azure-cli";    Name = "Azure CLI";    Desc = "Azure tools" }
        @{ ID = "aws-cli";      Name = "AWS CLI";      Desc = "AWS tools" }
        @{ ID = "terraform";    Name = "Terraform";    Desc = "Infrastructure as code" }
        @{ ID = "cmake";        Name = "CMake";        Desc = "Build system" }
        @{ ID = "mingw";        Name = "MinGW";        Desc = "C/C++ compiler" }
    )
    "System Tools" = @(
        @{ ID = "7zip";         Name = "7-Zip";        Desc = "File archiver" }
        @{ ID = "winrar";       Name = "WinRAR";       Desc = "File compression" }
        @{ ID = "everything";   Name = "Everything";   Desc = "Instant file search" }
        @{ ID = "hwinfo";       Name = "HWInfo";       Desc = "Hardware diagnostics" }
        @{ ID = "cpu-z";        Name = "CPU-Z";        Desc = "CPU information" }
        @{ ID = "speccy";       Name = "Speccy";       Desc = "System specs" }
        @{ ID = "ccleaner";     Name = "CCleaner";     Desc = "System cleaner" }
        @{ ID = "malwarebytes"; Name = "Malwarebytes"; Desc = "Anti-malware" }
        @{ ID = "processhacker";Name = "Process Hacker"; Desc = "Task manager alternative" }
        @{ ID = "handle";       Name = "Handle";       Desc = "Process handle viewer" }
        @{ ID = "procmon";      Name = "Process Monitor"; Desc = "System monitor" }
        @{ ID = "windirstat";   Name = "WinDirStat";   Desc = "Disk usage analyzer" }
        @{ ID = "treesize";     Name = "TreeSize";     Desc = "Disk analyzer" }
    )
    "Network & Security" = @(
        @{ ID = "wireshark";    Name = "Wireshark";    Desc = "Network analyzer" }
        @{ ID = "nmap";         Name = "Nmap";         Desc = "Network scanner" }
        @{ ID = "putty";        Name = "PuTTY";        Desc = "SSH client" }
        @{ ID = "filezilla";    Name = "FileZilla";    Desc = "FTP client" }
        @{ ID = "veracrypt";    Name = "VeraCrypt";    Desc = "Disk encryption" }
        @{ ID = "protonvpn";    Name = "Proton VPN";   Desc = "VPN service" }
        @{ ID = "nordvpn";      Name = "NordVPN";      Desc = "VPN service" }
        @{ ID = "expressvpn";   Name = "ExpressVPN";   Desc = "VPN service" }
        @{ ID = "clamav";       Name = "ClamAV";       Desc = "Antivirus" }
        @{ ID = "openvpn";      Name = "OpenVPN";      Desc = "Open-source VPN" }
        @{ ID = "tor";          Name = "Tor Browser";  Desc = "Privacy browser" }
        @{ ID = "bitwarden";    Name = "Bitwarden";    Desc = "Password manager" }
    )
    "Media & Design" = @(
        @{ ID = "vlc";         Name = "VLC";          Desc = "Media player" }
        @{ ID = "ffmpeg";       Name = "FFmpeg";        Desc = "Video/audio tools" }
        @{ ID = "obs-studio";   Name = "OBS Studio";   Desc = "Live streaming" }
        @{ ID = "audacity";     Name = "Audacity";     Desc = "Audio editor" }
        @{ ID = "gimp";         Name = "GIMP";         Desc = "Image editor" }
        @{ ID = "inkscape";     Name = "Inkscape";     Desc = "Vector graphics" }
        @{ ID = "blender";      Name = "Blender";      Desc = "3D modeling" }
        @{ ID = "daVinci-resolve"; Name = "DaVinci Resolve"; Desc = "Video editing" }
        @{ ID = "handbrake";    Name = "HandBrake";    Desc = "Video converter" }
        @{ ID = "sharex";       Name = "ShareX";       Desc = "Screenshot tool" }
        @{ ID = "greenshot";    Name = "Greenshot";    Desc = "Screenshot tool" }
    )
    "Gaming" = @(
        @{ ID = "steam";        Name = "Steam";        Desc = "Gaming platform" }
        @{ ID = "epicgameslauncher"; Name = "Epic Games"; Desc = "Game launcher" }
        @{ ID = "goggalaxy";    Name = "GOG Galaxy";   Desc = "DRM-free games" }
        @{ ID = "discord";      Name = "Discord";      Desc = "Gaming chat" }
        @{ ID = "rainmeter";    Name = "Rainmeter";    Desc = "Desktop customization" }
        @{ ID = "cheat-engine"; Name = "Cheat Engine"; Desc = "Memory editor" }
    )
    "AI & Data Science" = @(
        @{ ID = "python";       Name = "Python";       Desc = "Base for AI" }
        @{ ID = "miniconda";    Name = "Miniconda";    Desc = "Python distro" }
        @{ ID = "tensorflow";   Name = "TensorFlow";   Desc = "ML library (pip)"; InstallVia = "pip" }
        @{ ID = "pytorch";      Name = "PyTorch";      Desc = "DL framework (pip)"; InstallVia = "pip" }
        @{ ID = "jupyter";      Name = "Jupyter";      Desc = "Notebook (pip)"; InstallVia = "pip" }
        @{ ID = "huggingface";  Name = "Hugging Face"; Desc = "ML models (pip)"; InstallVia = "pip" }
    )
    "Databases" = @(
        @{ ID = "mysql";        Name = "MySQL";        Desc = "Database" }
        @{ ID = "postgresql";   Name = "PostgreSQL";   Desc = "Database" }
        @{ ID = "mongodb";      Name = "MongoDB";      Desc = "NoSQL database" }
        @{ ID = "redis";        Name = "Redis";        Desc = "In-memory DB" }
        @{ ID = "sqlite";       Name = "SQLite";       Desc = "Embedded DB" }
    )
    "Office & Productivity" = @(
        @{ ID = "libreoffice";  Name = "LibreOffice";  Desc = "Office suite" }
        @{ ID = "notepad++";    Name = "Notepad++";    Desc = "Text editor" }
        @{ ID = "sublimetext3"; Name = "Sublime Text"; Desc = "Code editor" }
        @{ ID = "foxitreader";  Name = "Foxit Reader"; Desc = "PDF reader" }
        @{ ID = "sumatrapdf";   Name = "Sumatra PDF";  Desc = "PDF viewer" }
    )
    "Browsers" = @(
        @{ ID = "googlechrome"; Name = "Chrome";       Desc = "Web browser" }
        @{ ID = "firefox";      Name = "Firefox";      Desc = "Web browser" }
        @{ ID = "microsoft-edge"; Name = "Edge";        Desc = "Web browser" }
        @{ ID = "brave";        Name = "Brave";        Desc = "Privacy browser" }
        @{ ID = "vivaldi";      Name = "Vivaldi";      Desc = "Customizable browser" }
    )
    "Utilities" = @(
        @{ ID = "curl";         Name = "cURL";         Desc = "Data transfer tool" }
        @{ ID = "wget";         Name = "Wget";         Desc = "Download manager" }
        @{ ID = "htop";         Name = "htop";         Desc = "Process viewer" }
        @{ ID = "ncdu";         Name = "ncdu";         Desc = "Disk usage analyzer" }
        @{ ID = "fzf";          Name = "fzf";          Desc = "Fuzzy finder" }
        @{ ID = "bat";          Name = "bat";          Desc = "Cat with syntax highlighting" }
        @{ ID = "ripgrep";      Name = "ripgrep";      Desc = "Search tool" }
        @{ ID = "fd";           Name = "fd";           Desc = "Find alternative" }
    )
}

# Flatten app list for easy access
$flatApps = @()
foreach ($category in $allApps.Keys) {
    foreach ($app in $allApps[$category]) {
        $app.Category = $category
        $flatApps += $app
    }
}

# ----------------------------
# Step 3: Stylish Terminal Banner
# ----------------------------
function Show-Banner {
    Clear-Host
    Write-Host "`n███████╗ █████╗ ███╗   ██╗██████╗  █████╗ ██████╗ ███████╗██████╗ `n" -ForegroundColor Magenta
    Write-Host "██╔══════╝██╔══██╗████╗  ██║██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗`n" -ForegroundColor Magenta
    Write-Host "███████╗ ███████║██╔██╗ ██║██║  ██║███████║██████╔╝█████╗  ██████╔╝`n" -ForegroundColor Magenta
    Write-Host "╚══════╝ ██╔══██║██║╚██╗██║██║   ██║██╔══██║██╔══██╗██╔══╝  ██╔══██╗`n" -ForegroundColor Magenta
    Write-Host "███████╗██║  ██║██║ ╚████║██████╔╝██║  ██║██║  ██║███████╗██║  ██║`n" -ForegroundColor Magenta
    Write-Host "╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝`n" -ForegroundColor Magenta
    Write-Host "=================================================`n" -ForegroundColor Cyan
    Write-Host "  ALL-IN-ONE SCRIPT | 100+ APPS | OPTIMIZATION | AI`n" -ForegroundColor Yellow
    Write-Host "=================================================`n" -ForegroundColor Cyan
}

# ----------------------------
# Step 4: Core Functions
# ----------------------------

# Main Menu
function Show-MainMenu {
    Show-Banner
    Write-Host "📋 MAIN MENU`n" -ForegroundColor Cyan
    Write-Host "----------------------------------" -ForegroundColor Gray

    $categories = $allApps.Keys | Sort-Object
    $counter = 1
    foreach ($cat in $categories) {
        Write-Host "$counter. $cat"
        $counter++
    }
    Write-Host "$counter. System Optimization"
    Write-Host ($counter + 1). "AI Chat (OpenAI)"
    Write-Host ($counter + 2). "Exit"

    $choice = Read-Host "`n➤ Select option (1-$($counter + 2))"
    $index = [int]$choice

    if ($index -ge 1 -and $index -le $categories.Count) {
        $selectedCat = $categories[$index - 1]
        Show-AppMenu -Category $selectedCat
    }
    elseif ($index -eq ($categories.Count + 1)) {
        Optimize-System
    }
    elseif ($index -eq ($categories.Count + 2)) {
        AI-Chat
    }
    elseif ($index -eq ($categories.Count + 3)) {
        Exit
    }
    else {
        Write-Host "❌ Invalid choice!" -ForegroundColor Red
        Pause
        Show-MainMenu
    }
}

# App Selection Menu
function Show-AppMenu {
    param($Category)
    Show-Banner
    Write-Host "📦 $Category APPS`n" -ForegroundColor Cyan
    Write-Host "----------------------------------" -ForegroundColor Gray

    $apps = $flatApps | Where-Object { $_.Category -eq $Category }
    $counter = 1
    foreach ($app in $apps) {
        Write-Host "$counter. $($app.Name) - $($app.Desc)"
        $counter++
    }
    Write-Host "$counter. Back to Main Menu"
    Write-Host ($counter + 1). "Exit"

    $choice = Read-Host "`n➤ Select app(s) (e.g., '1,3' for multiple). Type 'back' to return."
    if ($choice -eq "back") {
        Show-MainMenu
        return
    }
    elseif ($choice -eq ($counter + 1).ToString()) {
        Exit
    }

    $selectedIndexes = $choice -split ',' | ForEach-Object { 
        if ($_ -eq "back") { Show-MainMenu; return }
        [int]$_
    }

    foreach ($idx in $selectedIndexes) {
        if ($idx -ge 1 -and $idx -lt $counter) {
            $app = $apps[$idx - 1]
            Install-App -App $app
        }
        else {
            Write-Host "⚠️ Invalid selection: $idx" -ForegroundColor Yellow
        }
    }

    Write-Host "`n✅ Selected apps installed." -ForegroundColor Green
    Pause
    Show-AppMenu -Category $Category
}

# Install App
function Install-App {
    param($App)
    Write-Host "`n🛠️ Installing $($App.Name)..." -ForegroundColor Yellow

    # Install via Chocolatey
    if ($App.ID -and -not $App.InstallVia) {
        try {
            choco install -y $App.ID --no-progress
            Write-Host "✅ $($App.Name) installed." -ForegroundColor Green
        } catch {
            Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # Install via Pip (Python libraries)
    if ($App.InstallVia -eq "pip") {
        try {
            pip install $App.ID
            Write-Host "✅ $($App.Name) installed via Pip." -ForegroundColor Green
        } catch {
            Write-Host "❌ Pip error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# System Optimization
function Optimize-System {
    Show-Banner
    Write-Host "`n🧹 SYSTEM OPTIMIZATION MENU`n" -ForegroundColor Cyan
    Write-Host "----------------------------------" -ForegroundColor Gray
    Write-Host "1. Clean temporary files"
    Write-Host "2. Disable Windows telemetry"
    Write-Host "3. Optimize registry settings"
    Write-Host "4. Back to Main Menu"
    Write-Host "5. Exit"

    $choice = Read-Host "`n➤ Select option (1-5)"
    switch ($choice) {
        "1" {
            Write-Host "`n🧹 Cleaning temp files..." -ForegroundColor Yellow
            cleanmgr /sagerun:1
            Write-Host "✅ Cleanup complete." -ForegroundColor Green
            Pause
            Optimize-System
        }
        "2" {
            Write-Host "`n🔒 Disabling telemetry..." -ForegroundColor Yellow
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Telemetry" -Name "DisableTelemetry" -Value 1 -Force
            Write-Host "✅ Telemetry disabled." -ForegroundColor Green
            Pause
            Optimize-System
        }
        "3" {
            Write-Host "`n⚙️ Optimizing registry..." -ForegroundColor Yellow
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 0 -Force
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Value 0 -Force
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x01,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00)) -Force
            Write-Host "✅ Registry optimized." -ForegroundColor Green
            Pause
            Optimize-System
        }
        "4" { Show-MainMenu }
        "5" { Exit }
        default {
            Write-Host "❌ Invalid choice!" -ForegroundColor Red
            Pause
            Optimize-System
        }
    }
}

# AI Chat (OpenAI)
function AI-Chat {
    Show-Banner
    Write-Host "`n🤖 AI CHAT (OpenAI)`n" -ForegroundColor Magenta
    Write-Host "----------------------------------" -ForegroundColor Gray

    $apiKey = $env:OPENAI_API_KEY
    if (-not $apiKey) {
        Write-Host "❌ OpenAI API key not set!" -ForegroundColor Red
        $keyInput = Read-Host "➤ Enter your OpenAI API key (or press Enter to skip)"
        if ($keyInput -ne "") {
            [System.Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $keyInput, "User")
            $env:OPENAI_API_KEY = $keyInput
            Write-Host "✅ API key saved." -ForegroundColor Green
        } else {
            Write-Host "⚠️ AI features disabled." -ForegroundColor Yellow
            Pause
            Show-MainMenu
            return
        }
    }

    $prompt = Read-Host "`n➤ Enter your question"
    if ($prompt -eq "") {
        Show-MainMenu
        return
    }

    $body = @{
        model = "gpt-3.5-turbo"
        messages = @( @{ role = "user"; content = $prompt } )
        max_tokens = 1024
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" `
            -Method Post `
            -Headers @{ "Authorization" = "Bearer $apiKey"; "Content-Type" = "application/json" } `
            -Body $body
        $answer = $response.choices[0].message.content
        Write-Host "`n🤖 AI Response:`n$answer" -ForegroundColor Cyan
    } catch {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    $again = Read-Host "`n➤ Ask another question? (y/n)"
    if ($again -eq "y") {
        AI-Chat
    } else {
        Show-MainMenu
    }
}

# ----------------------------
# Step 5: Start Script
# ----------------------------
Show-MainMenu
