# Подключаем файл с переводами
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$SCRIPT_DIR\gosms_translations.ps1"

# Цвета для вывода
$RED = [System.ConsoleColor]::Red
$GREEN = [System.ConsoleColor]::Green
$YELLOW = [System.ConsoleColor]::Yellow
$BLUE = [System.ConsoleColor]::Blue
$CYAN = [System.ConsoleColor]::Cyan

# Определение конфигурационного файла
$CONFIG_FILE = "$env:USERPROFILE\.gosms.conf"

# Загружаем язык из конфигурации
if (Test-Path $CONFIG_FILE) {
    $LANG = (Get-Content $CONFIG_FILE | Where-Object { $_ -match '^language=' }) -replace '^language=', ''
    $TOKEN_FROM_FILE = (Get-Content $CONFIG_FILE | Where-Object { $_ -match '^token=' }) -replace '^token=', ''
}

# Если язык не установлен, используем английский по умолчанию
$LANG = if ($LANG) { $LANG } else { "en" }

$BASE_URL = "https://api.gosms.ru/v1/sms/send"

# Функция для проверки формата JWT токена
function Check-ApiKey {
    param (
        [string]$key
    )
    
    # Проверяем, что ключ не пустой
    if ([string]::IsNullOrEmpty($key)) {
        Write-Host "❌ $(Get-Text $LANG 'invalid_api_key')" -ForegroundColor $RED
        return $false
    }
    
    # Проверяем формат JWT (три части, разделенные точками)
    if (-not ($key -match '^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$')) {
        Write-Host "❌ $(Get-Text $LANG 'invalid_api_key')" -ForegroundColor $RED
        return $false
    }
    
    return $true
}

function Setup-Language {
    Clear-Host
    Write-Host "`n$(Get-Text 'en' 'select_language')" -ForegroundColor $BLUE
    Write-Host "1) $(Get-Text 'en' 'russian')"
    Write-Host "2) $(Get-Text 'en' 'english')"
    $lang_choice = Read-Host "Выберите номер / Select number (1-2)"

    switch ($lang_choice) {
        "1" { $script:LANG = "ru" }
        "2" { $script:LANG = "en" }
        default { $script:LANG = "en" }
    }

    # Сохраняем выбранный язык в конфигурацию
    Set-Content -Path $CONFIG_FILE -Value "language=$LANG"
}

function Setup-ApiKey {
    Clear-Host
    Write-Host "`n$(Get-Text $LANG 'api_key_instructions')" -ForegroundColor $YELLOW
    Write-Host ""

    # Запрос API ключа
    while ($true) {
        $api_key = Read-Host "$(Get-Text $LANG 'enter_api_key')"
        
        if (Check-ApiKey $api_key) {
            Add-Content -Path $CONFIG_FILE -Value "token=$api_key"
            Write-Host "✅ $(Get-Text $LANG 'api_key_saved')" -ForegroundColor $GREEN
            break
        }
    }
}

function Show-Usage {
    Write-Host "$(Get-Text 'en' 'app_name')" -ForegroundColor $CYAN
    Write-Host "$(Get-Text 'en' 'usage')" -ForegroundColor $CYAN
    Write-Host ""
    Write-Host "$(Get-Text $LANG 'usage')"
    Write-Host "  $(Get-Text $LANG 'command_format')"
    Write-Host ""
    Write-Host "$(Get-Text $LANG 'commands')"
    Write-Host "  sendsms    $(Get-Text $LANG 'send_sms')"
    Write-Host "  --edit     $(Get-Text $LANG 'edit_settings')"
    Write-Host "  --uninstall $(Get-Text $LANG 'uninstall')"
    Write-Host "  -h, --help $(Get-Text $LANG 'show_help')"
    Write-Host ""
    Write-Host "$(Get-Text $LANG 'options')"
    Write-Host "  -num <номер>       $(Get-Text $LANG 'phone')"
    Write-Host "  --text <текст>     $(Get-Text $LANG 'text')"
    Write-Host "  --device <id>      $(Get-Text $LANG 'device')"
    Write-Host "  --sim <номер>      $(Get-Text $LANG 'sim')"
    Write-Host ""
    Write-Host "$(Get-Text $LANG 'examples')"
    Write-Host "  $(Get-Text $LANG 'example_simple')"
    Write-Host "  $(Get-Text $LANG 'example_full')"
    Write-Host "  $(Get-Text $LANG 'example_edit')"
    Write-Host ""
    Write-Host "$(Get-Text $LANG 'config')"
    Write-Host "  $(Get-Text $LANG 'token_stored') $CONFIG_FILE"
    Write-Host "  $(Get-Text $LANG 'token_edit') gosms --edit"
}

function Edit-Settings {
    # Если конфигурационный файл не существует, запускаем первоначальную настройку
    if (-not (Test-Path $CONFIG_FILE)) {
        Setup-Language
        Setup-ApiKey
        return
    }

    # Получаем текущий токен
    $CURRENT_TOKEN = (Get-Content $CONFIG_FILE | Where-Object { $_ -match '^token=' }) -replace '^token=', ''

    Write-Host "$(Get-Text $LANG 'api_key_instructions')" -ForegroundColor $YELLOW
    $NEW_TOKEN = Read-Host "$(Get-Text $LANG 'enter_api_key')"
    
    if ($NEW_TOKEN) {
        # Сохраняем токен, сохраняя язык
        if (Test-Path $CONFIG_FILE) {
            $content = Get-Content $CONFIG_FILE
            $content = $content -replace '^token=.*', "token=$NEW_TOKEN"
            Set-Content -Path $CONFIG_FILE -Value $content
        }
        Write-Host "✅ $(Get-Text $LANG 'settings_updated')" -ForegroundColor $GREEN
    }
    else {
        Write-Host "⚠️ $(Get-Text $LANG 'settings_not_changed')" -ForegroundColor $YELLOW
    }
}

function Uninstall-GoSMS {
    # Запрос подтверждения
    $confirm = Read-Host "$(Get-Text $LANG 'uninstall_confirm')"

    if ($confirm -notmatch '^[yY]$') {
        Write-Host "$(Get-Text $LANG 'uninstall_cancelled')" -ForegroundColor $YELLOW
        exit 0
    }

    Write-Host "$(Get-Text $LANG 'uninstalling')" -ForegroundColor $BLUE

    # Удаление файлов
    Write-Host "$(Get-Text $LANG 'removing_files')" -ForegroundColor $BLUE
    $INSTALL_DIR = "C:\Program Files\GoSMS"
    Remove-Item -Force "$INSTALL_DIR\gosms.ps1" -ErrorAction SilentlyContinue
    Remove-Item -Force "$INSTALL_DIR\gosms_translations.ps1" -ErrorAction SilentlyContinue

    # Удаление алиаса из профиля PowerShell
    $profilePath = $PROFILE
    if (Test-Path $profilePath) {
        $content = Get-Content $profilePath
        $content = $content | Where-Object { $_ -notmatch 'Set-Alias -Name gosms' }
        Set-Content -Path $profilePath -Value $content
    }

    # Удаление конфигурации
    Write-Host "$(Get-Text $LANG 'removing_config')" -ForegroundColor $BLUE
    Remove-Item -Force $CONFIG_FILE -ErrorAction SilentlyContinue

    Write-Host "✅ $(Get-Text $LANG 'uninstall_complete')" -ForegroundColor $GREEN
    exit 0
}

# Обработка аргументов
$args = $args -join ' '
if ($args -match '^-h$|^--help$') {
    Show-Usage
    exit 0
}
elseif ($args -match '^--edit$') {
    Edit-Settings
}
elseif ($args -match '^--uninstall$') {
    Uninstall-GoSMS
}
elseif ($args -match '^sendsms') {
    # Проверяем наличие токена
    if (-not $TOKEN_FROM_FILE) {
        Write-Host "❌ $(Get-Text $LANG 'token_not_found')" -ForegroundColor $RED
        Write-Host "$(Get-Text $LANG 'run_edit_first')" -ForegroundColor $YELLOW
        exit 1
    }

    # Парсинг аргументов
    $PHONE = ""
    $TEXT = ""
    $DEVICE = ""
    $SIM = ""

    $args = $args -replace '^sendsms\s+', ''
    $args = $args -split '\s+'

    for ($i = 0; $i -lt $args.Count; $i++) {
        switch ($args[$i]) {
            '-num' { $PHONE = $args[++$i] }
            '--text' { $TEXT = $args[++$i] }
            '--device' { $DEVICE = $args[++$i] }
            '--sim' { $SIM = $args[++$i] }
            '-h' { Show-Usage; exit 0 }
            '--help' { Show-Usage; exit 0 }
            default { Write-Host "$(Get-Text $LANG 'unknown_param') $($args[$i])" -ForegroundColor $RED; Show-Usage; exit 1 }
        }
    }

    # Проверка обязательных параметров
    if (-not $PHONE -or -not $TEXT) {
        Write-Host "❌ $(Get-Text $LANG 'required_params')" -ForegroundColor $RED
        Show-Usage
        exit 1
    }

    # Проверка SIM без DEVICE
    if ($SIM -and -not $DEVICE) {
        Write-Host "❌ $(Get-Text $LANG 'sim_without_device')" -ForegroundColor $RED
        Show-Usage
        exit 1
    }

    # Формирование JSON для запроса
    $JSON_DATA = @{
        message = $TEXT
        phone_number = $PHONE
    }

    if ($DEVICE) {
        $JSON_DATA.device_id = $DEVICE
        if ($SIM) {
            $JSON_DATA.to_sim = [int]$SIM
        }
    }

    # Отправка запроса
    try {
        $response = Invoke-RestMethod -Uri $BASE_URL `
            -Method Post `
            -Headers @{
                "Content-Type" = "application/json"
                "Authorization" = "Bearer $TOKEN_FROM_FILE"
            } `
            -Body ($JSON_DATA | ConvertTo-Json)

        Write-Host "📡 HTTP/200" -ForegroundColor $GREEN
        $response | ConvertTo-Json
    }
    catch {
        Write-Host "📡 HTTP/$($_.Exception.Response.StatusCode.value__)" -ForegroundColor $RED
        Write-Host $_.Exception.Response.StatusDescription -ForegroundColor $RED
    }
}
else {
    Write-Host "$(Get-Text $LANG 'app_name')" -ForegroundColor $CYAN
    Write-Host "$(Get-Text $LANG 'usage')" -ForegroundColor $CYAN
    Show-Usage
} 