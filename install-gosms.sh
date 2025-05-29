#!/bin/bash

# Включаем режим отладки
set -x

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Базовый URL репозитория
REPO_URL="https://raw.githubusercontent.com/gosms-ru/cli-client/main"

# Функция для загрузки файла
download_file() {
    local file=$1
    local target=$2
    echo -e "${BLUE}Загрузка $file...${NC}"
    wget -q "$REPO_URL/$file" -O "$target"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $file успешно загружен${NC}"
        return 0
    else
        echo -e "${RED}❌ Ошибка при загрузке $file${NC}"
        return 1
    fi
}

# Проверка наличия wget
if ! command -v wget &> /dev/null; then
    echo -e "${RED}❌ wget не установлен. Устанавливаем...${NC}"
    apt-get update && apt-get install -y wget
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Не удалось установить wget${NC}"
        exit 1
    fi
fi

echo -e "${BLUE}Начинаем установку GoSMS CLI...${NC}"

# Создаем директорию для установки
INSTALL_DIR="/opt/gosms"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Загружаем необходимые файлы
download_file "gosms.sh" "gosms.sh"
download_file "translations.sh" "translations.sh"

# Проверяем успешность загрузки
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка при загрузке файлов${NC}"
    exit 1
fi

# Делаем файлы исполняемыми
chmod +x gosms.sh
chmod +x translations.sh

# Создаем символические ссылки
echo -e "${BLUE}Создаем символические ссылки...${NC}"
ln -sf "$INSTALL_DIR/gosms.sh" /usr/local/bin/gosms
ln -sf "$INSTALL_DIR/translations.sh" /usr/local/bin/gosms_translations.sh

# Устанавливаем права
chmod 755 /usr/local/bin/gosms
chmod 755 /usr/local/bin/gosms_translations.sh

echo -e "${GREEN}✅ Файлы установлены в $INSTALL_DIR${NC}"

# Подключаем файл с переводами
source /usr/local/bin/gosms_translations.sh

# Функция для проверки формата JWT токена
check_api_key() {
    local key=$1
    
    # Проверяем, что ключ не пустой
    if [[ -z "$key" ]]; then
        if [ "$LANG" = "ru" ]; then
            echo -e "${RED}❌ API ключ не может быть пустым${NC}"
        else
            echo -e "${RED}❌ API key cannot be empty${NC}"
        fi
        return 1
    fi
    
    # Проверяем формат JWT (три части, разделенные точками)
    if ! [[ "$key" =~ ^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]]; then
        if [ "$LANG" = "ru" ]; then
            echo -e "${RED}❌ Неверный формат API ключа. Ожидается формат: xxxxx.yyyyy.zzzzz${NC}"
        else
            echo -e "${RED}❌ Invalid API key format. Expected format: xxxxx.yyyyy.zzzzz${NC}"
        fi
        return 1
    fi
    
    return 0
}

# Функция для выбора языка
select_language() {
    clear
    echo -e "${CYAN}$(get_text "en" "logo")${NC}"
    echo ""
    echo -e "${BLUE}Выберите язык / Select language:${NC}"
    echo "1) Русский"
    echo "2) English"
    
    while true; do
        read -p "Выберите номер / Select number (1-2): " lang_choice
        case $lang_choice in
            1) echo "ru"; break ;;
            2) echo "en"; break ;;
            *) echo -e "${RED}❌ Неверный выбор. Пожалуйста, выберите 1 или 2${NC}" ;;
        esac
    done
}

# Функция для запроса API ключа
request_api_key() {
    local lang=$1
    local config_file=$2
    
    clear
    echo -e "${CYAN}$(get_text "$lang" "logo")${NC}"
    echo ""
    echo -e "${YELLOW}$(get_text "$lang" "api_key_instructions")${NC}"
    echo ""

    max_attempts=3
    attempt=0

    while [ $attempt -lt $max_attempts ]; do
        read -p "$(get_text "$lang" "enter_api_key")" api_key
        
        if check_api_key "$api_key"; then
            echo "token=$api_key" >> "$config_file"
            chmod 600 "$config_file"
            echo -e "${GREEN}✅ $(get_text "$lang" "api_key_saved")${NC}"
            return 0
        fi
        
        attempt=$((attempt + 1))
        if [ $attempt -eq $max_attempts ]; then
            echo -e "${YELLOW}$(get_text "$lang" "token_not_entered")${NC}"
            echo -e "${YELLOW}gosms --edit${NC}"
            return 1
        fi
    done
}

# Основной процесс установки
CONFIG_FILE="$HOME/.gosms.conf"

# Выбор языка
LANG=$(select_language)
echo "language=$LANG" > "$CONFIG_FILE"

# Запрос API ключа
request_api_key "$LANG" "$CONFIG_FILE"

echo -e "${GREEN}✅ $(get_text "$LANG" "cli_installed")${NC}"
echo -e "${YELLOW}$(get_text "$LANG" "example_command")${NC}"
echo -e "${YELLOW}$(get_text "$LANG" "example_edit")${NC}"

# Ждем нажатия Enter перед выходом
read -p "$(get_text "$LANG" "press_enter")"

# Отключаем режим отладки
set +x 