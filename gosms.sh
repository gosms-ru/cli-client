#!/bin/bash

# Определение операционной системы
OS="$(uname -s)"
case "${OS}" in
    Linux*)     PLATFORM="linux";;
    Darwin*)    PLATFORM="macos";;
    CYGWIN*)    PLATFORM="windows";;
    MINGW*)     PLATFORM="windows";;
    *)          PLATFORM="unknown";;
esac

# Определение пути к скрипту с учетом платформы
if [ "$PLATFORM" = "windows" ]; then
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
else
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
fi

# Подключаем файл с переводами
source "$SCRIPT_DIR/gosms_translations.sh"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Проверяем поддержку цветов
if [ -t 1 ]; then
    # Терминал поддерживает цвета
    :
else
    # Терминал не поддерживает цвета
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    NC=''
fi

# Определение конфигурационного файла с учетом платформы
if [ "$PLATFORM" = "windows" ]; then
    CONFIG_FILE="$USERPROFILE/.gosms.conf"
else
    CONFIG_FILE="$HOME/.gosms.conf"
fi

# Загружаем язык из конфигурации
if [[ -f "$CONFIG_FILE" ]]; then
    if [ "$PLATFORM" = "windows" ]; then
        LANG=$(grep '^language=' "$CONFIG_FILE" | cut -d '=' -f2- | tr -d '\r')
        TOKEN_FROM_FILE=$(grep '^token=' "$CONFIG_FILE" | cut -d '=' -f2- | tr -d '\r')
    else
        LANG=$(grep '^language=' "$CONFIG_FILE" | cut -d '=' -f2-)
        TOKEN_FROM_FILE=$(grep '^token=' "$CONFIG_FILE" | cut -d '=' -f2-)
    fi
fi

# Если язык не установлен, используем английский по умолчанию
LANG=${LANG:-"en"}

BASE_URL="https://api.gosms.ru/v1/sms/send"

# Функция для проверки формата JWT токена
check_api_key() {
    local key=$1
    
    # Проверяем, что ключ не пустой
    if [[ -z "$key" ]]; then
        echo -e "${RED}❌ $(get_text "$LANG" "invalid_api_key")${NC}"
        return 1
    fi
    
    # Проверяем формат JWT (три части, разделенные точками)
    if ! [[ "$key" =~ ^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]]; then
        echo -e "${RED}❌ $(get_text "$LANG" "invalid_api_key")${NC}"
        return 1
    fi
    
    return 0
}

function setup_language() {
    clear
    echo ""
    echo -e "${BLUE}$(get_text "en" "select_language")${NC}"
    echo "1) $(get_text "en" "russian")"
    echo "2) $(get_text "en" "english")"
    read -p "Выберите номер / Select number (1-2): " lang_choice

    case $lang_choice in
        1) LANG="ru" ;;
        2) LANG="en" ;;
        *) LANG="en" ;; # По умолчанию английский
    esac

    # Сохраняем выбранный язык в конфигурацию
    echo "language=$LANG" > "$CONFIG_FILE"
}

function setup_api_key() {
    clear
    
    echo ""
    echo -e "${YELLOW}$(get_text "$LANG" "api_key_instructions")${NC}"
    echo ""

    # Запрос API ключа
    while true; do
        read -p "$(get_text "$LANG" "enter_api_key")" api_key
        
        if check_api_key "$api_key"; then
            echo "token=$api_key" >> "$CONFIG_FILE"
            chmod 600 "$CONFIG_FILE"
            echo -e "${GREEN}✅ $(get_text "$LANG" "api_key_saved")${NC}"
            break
        fi
    done
}

function usage() {
    echo -e "${CYAN}$(get_text "en" "app_name")${NC}"
    echo -e "${CYAN}$(get_text "en" "usage")${NC}"
    echo ""
    echo "$(get_text "$LANG" "usage")"
    echo "  $(get_text "$LANG" "command_format")"
    echo ""
    echo "$(get_text "$LANG" "commands")"
    echo "  sendsms    $(get_text "$LANG" "send_sms")"
    echo "  --edit     $(get_text "$LANG" "edit_settings")"
    echo "  --uninstall $(get_text "$LANG" "uninstall")"
    echo "  -h, --help $(get_text "$LANG" "show_help")"
    echo ""
    echo "$(get_text "$LANG" "options")"
    echo "  -num <номер>       $(get_text "$LANG" "phone")"
    echo "  --text <текст>     $(get_text "$LANG" "text")"
    echo "  --device <id>      $(get_text "$LANG" "device")"
    echo "  --sim <номер>      $(get_text "$LANG" "sim")"
    echo ""
    echo "$(get_text "$LANG" "examples")"
    echo "  $(get_text "$LANG" "example_simple")"
    echo "  $(get_text "$LANG" "example_full")"
    echo "  $(get_text "$LANG" "example_edit")"
    echo ""
    echo "$(get_text "$LANG" "config")"
    echo "  $(get_text "$LANG" "token_stored") ~/.gosms.conf"
    echo "  $(get_text "$LANG" "token_edit") gosms --edit"
}

function edit_settings() {
    # Если конфигурационный файл не существует, запускаем первоначальную настройку
    if [[ ! -f "$CONFIG_FILE" ]]; then
        setup_language
        setup_api_key
        return
    fi

    # Получаем текущий токен
    CURRENT_TOKEN=""
    if [[ -f "$CONFIG_FILE" ]]; then
        if [ "$PLATFORM" = "windows" ]; then
            CURRENT_TOKEN=$(grep '^token=' "$CONFIG_FILE" | cut -d '=' -f2- | tr -d '\r')
        else
            CURRENT_TOKEN=$(grep '^token=' "$CONFIG_FILE" | cut -d '=' -f2-)
        fi
    fi

    echo -e "${YELLOW}$(get_text "$LANG" "api_key_instructions")${NC}"
    read -p "$(get_text "$LANG" "enter_api_key")" NEW_TOKEN
    
    if [[ -n "$NEW_TOKEN" ]]; then
        # Сохраняем токен, сохраняя язык
        if [[ -f "$CONFIG_FILE" ]]; then
            if [ "$PLATFORM" = "windows" ]; then
                sed -i 's/^token=.*/token='"$NEW_TOKEN"'/' "$CONFIG_FILE"
            else
                sed -i.bak 's/^token=.*/token='"$NEW_TOKEN"'/' "$CONFIG_FILE"
                rm -f "${CONFIG_FILE}.bak"
            fi
        fi
        echo "token=$NEW_TOKEN" >> "$CONFIG_FILE"
        chmod 600 "$CONFIG_FILE"
        echo -e "${GREEN}✅ $(get_text "$LANG" "settings_updated")${NC}"
    else
        echo -e "${YELLOW}⚠️ $(get_text "$LANG" "settings_not_changed")${NC}"
    fi
}

function uninstall() {
    # Запрос подтверждения
    read -p "$(get_text "$LANG" "uninstall_confirm")" confirm

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo -e "${YELLOW}$(get_text "$LANG" "uninstall_cancelled")${NC}"
        exit 0
    fi

    echo -e "${BLUE}$(get_text "$LANG" "uninstalling")${NC}"

    # Удаление файлов
    echo -e "${BLUE}$(get_text "$LANG" "removing_files")${NC}"
    if [ "$PLATFORM" = "windows" ]; then
        rm -f "$INSTALL_DIR/gosms"
        rm -f "$INSTALL_DIR/gosms_translations.sh"
    else
        sudo rm -f "$INSTALL_DIR/gosms"
        sudo rm -f "$INSTALL_DIR/gosms_translations.sh"
    fi

    # Удаление конфигурации
    echo -e "${BLUE}$(get_text "$LANG" "removing_config")${NC}"
    rm -f "$CONFIG_FILE"

    echo -e "${GREEN}✅ $(get_text "$LANG" "uninstall_complete")${NC}"
    exit 0
}

# Обработка флагов помощи
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
    exit 0
elif [[ "$1" == "--edit" ]]; then
    edit_settings
elif [[ "$1" == "--uninstall" ]]; then
    uninstall
elif [[ "$1" == "sendsms" ]]; then
    # Проверяем наличие токена
    if [[ -z "$TOKEN_FROM_FILE" ]]; then
        echo -e "${RED}❌ $(get_text "$LANG" "token_not_found")${NC}"
        echo -e "${YELLOW}$(get_text "$LANG" "run_edit_first")${NC}"
        exit 1
    fi

    shift
    PHONE=""
    TEXT=""
    DEVICE=""
    SIM=""
    
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -num) PHONE="$2"; shift ;;
            --text) TEXT="$2"; shift ;;
            --device) DEVICE="$2"; shift ;;
            --sim) SIM="$2"; shift ;;
            -h|--help) usage; exit 0 ;;
            *) echo -e "${RED}$(get_text "$LANG" "unknown_param") $1${NC}"; usage; exit 1 ;;
        esac
        shift
    done

    # Проверка обязательных параметров
    if [[ -z "$PHONE" || -z "$TEXT" ]]; then
        echo -e "${RED}❌ $(get_text "$LANG" "required_params")${NC}"
        usage
        exit 1
    fi

    # Проверка SIM без DEVICE
    if [[ -n "$SIM" && -z "$DEVICE" ]]; then
        echo -e "${RED}❌ $(get_text "$LANG" "sim_without_device")${NC}"
        usage
        exit 1
    fi

    # Формирование JSON для запроса
    JSON_DATA="{\"message\":\"$TEXT\",\"phone_number\":\"$PHONE\""
    
    if [[ -n "$DEVICE" ]]; then
        JSON_DATA="$JSON_DATA,\"device_id\":\"$DEVICE\""
        if [[ -n "$SIM" ]]; then
            JSON_DATA="$JSON_DATA,\"to_sim\":$SIM"
        fi
    fi
    
    JSON_DATA="$JSON_DATA}"

    # Отправка запроса
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN_FROM_FILE" \
        -d "$JSON_DATA")

    # Разделение ответа на тело и код статуса
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

    # Вывод результата
    if [[ $HTTP_CODE -ge 200 && $HTTP_CODE -lt 300 ]]; then
        echo -e "${GREEN}📡 HTTP/$HTTP_CODE${NC}"
    else
        echo -e "${RED}📡 HTTP/$HTTP_CODE${NC}"
    fi
    
    # Проверяем наличие ошибок в ответе
    if echo "$RESPONSE_BODY" | jq -e '.errors' >/dev/null 2>&1; then
        echo -e "${RED}$RESPONSE_BODY${NC}" | jq '.' 2>/dev/null || echo -e "${RED}$RESPONSE_BODY${NC}"
    else
        echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"
    fi
else
    echo -e "${CYAN}$(get_text "$LANG" "app_name")${NC}"
    echo -e "${CYAN}$(get_text "$LANG" "usage")${NC}"
    usage
fi 