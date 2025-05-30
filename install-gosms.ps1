# Проверка на права администратора
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Для установки требуются права администратора. Пожалуйста, запустите PowerShell от имени администратора." -ForegroundColor Yellow
    exit 1
}

# Цвета для вывода
$RED = [System.ConsoleColor]::Red
$GREEN = [System.ConsoleColor]::Green
$YELLOW = [System.ConsoleColor]::Yellow
$BLUE = [System.ConsoleColor]::Blue
$CYAN = [System.ConsoleColor]::Cyan

# Функция для генерации логотипа
function Generate-Logo {
    Write-Host "
╔═══════════════════════════════════════════════════╗
║                                                   ║
║  ██████═╗  ██████╗ ███████╗███╗   ███╗███████╗    ║
║  ██╔════╝ ██╔═══██╗██╔════╝████╗ ████║██╔════╝    ║
║  ██║  ███╗██║   ██║███████╗██╔████╔██║███████╗    ║
║  ██║   ██║██║   ██║╚════██║██║╚██╔╝██║╚════██║    ║
║  ╚██████╔╝╚██████╔╝███████║██║ ╚═╝ ██║███████║    ║
║   ╚═════╝  ╚═════╝ ╚══════╝╚═╝     ╚═╝╚══════╝    ║
║                                                   ║
╚═══════════════════════════════════════════════════╝" -ForegroundColor Cyan
}

# Базовый URL репозитория
$REPO_URL = "https://raw.githubusercontent.com/gosms-ru/cli-client/developer"

# Функция для загрузки файла
function Download-File {
    param (
        [string]$file,
        [string]$target
    )
    Write-Host "Загрузка $file..." -ForegroundColor Blue
    try {
        Invoke-WebRequest -Uri "$REPO_URL/$file" -OutFile "$target"
        Write-Host "✅ $file успешно загружен" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Ошибка при загрузке $file" -ForegroundColor Red
        return $false
    }
}

# Создаем временную директорию
$TEMP_DIR = Join-Path $env:TEMP "gosms_install"
New-Item -ItemType Directory -Force -Path $TEMP_DIR | Out-Null
Set-Location $TEMP_DIR

# Загружаем необходимые файлы
$success = $true
$success = $success -and (Download-File "gosms.sh" "gosms.sh")
$success = $success -and (Download-File "translations.sh" "translations.sh")

if (-not $success) {
    Write-Host "❌ Ошибка при загрузке файлов" -ForegroundColor Red
    Remove-Item -Recurse -Force $TEMP_DIR
    exit 1
}

# Создаем директорию установки
$INSTALL_DIR = "C:\Program Files\GoSMS"
if (-not (Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Force -Path $INSTALL_DIR | Out-Null
}

# Копируем файлы
Write-Host "Копирование файлов..." -ForegroundColor Blue
Copy-Item "gosms.sh" "$INSTALL_DIR\gosms.ps1" -Force
Copy-Item "translations.sh" "$INSTALL_DIR\gosms_translations.ps1" -Force

# Создаем алиас в PowerShell
$profilePath = $PROFILE
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Force -Path $profilePath | Out-Null
}

$aliasCommand = "Set-Alias -Name gosms -Value '$INSTALL_DIR\gosms.ps1'"
if (-not (Select-String -Path $profilePath -Pattern "Set-Alias -Name gosms" -Quiet)) {
    Add-Content -Path $profilePath -Value "`n$aliasCommand"
}

# Очищаем временную директорию
Remove-Item -Recurse -Force $TEMP_DIR

# Создаем конфигурационный файл
$CONFIG_FILE = "$env:USERPROFILE\.gosms.conf"
if (-not (Test-Path $CONFIG_FILE)) {
    New-Item -ItemType File -Force -Path $CONFIG_FILE | Out-Null
}

# Выбор языка
Generate-Logo
Write-Host "`nВыберите язык / Select language:" -ForegroundColor Blue
Write-Host "1) Русский"
Write-Host "2) English"
$lang_choice = Read-Host "Выберите номер / Select number (1-2)"

switch ($lang_choice) {
    "1" { $LANG = "ru" }
    "2" { $LANG = "en" }
    default { $LANG = "en" }
}

# Сохраняем язык
Set-Content -Path $CONFIG_FILE -Value "language=$LANG"

# Запрос API ключа
Write-Host "`nВведите ваш API ключ:" -ForegroundColor Yellow
$api_key = Read-Host "API Key"

# Проверка формата API ключа
if ($api_key -match '^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$') {
    Add-Content -Path $CONFIG_FILE -Value "token=$api_key"
    Write-Host "✅ API ключ успешно сохранен" -ForegroundColor Green
}
else {
    Write-Host "❌ Неверный формат API ключа" -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ GoSMS CLI успешно установлен" -ForegroundColor Green
Write-Host "Для использования команды 'gosms' перезапустите PowerShell" -ForegroundColor Yellow
Write-Host "Пример использования: gosms sendsms -num +79001234567 --text 'Тестовое сообщение'" -ForegroundColor Yellow

# Ждем нажатия Enter перед выходом
Read-Host "Нажмите Enter для выхода" 