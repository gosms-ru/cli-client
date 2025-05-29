#!/bin/bash

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
    if curl -sSL "$REPO_URL/$file" -o "$target"; then
        echo -e "${GREEN}✅ $file успешно загружен${NC}"
        return 0
    else
        echo -e "${RED}❌ Ошибка при загрузке $file${NC}"
        return 1
    fi
}

# Проверка наличия curl
if ! command -v curl &> /dev/null; then
    echo -e "${RED}❌ curl не установлен. Пожалуйста, установите curl и попробуйте снова.${NC}"
    exit 1
fi

echo -e "${BLUE}Начинаем установку GoSMS CLI...${NC}"

# Создаем временную директорию
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Загружаем необходимые файлы
download_file "gosms.sh" "gosms.sh"
download_file "translations.sh" "translations.sh"

# Проверяем успешность загрузки
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка при загрузке файлов${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Делаем файлы исполняемыми
chmod +x gosms.sh
chmod +x translations.sh

# Перемещаем файлы в /usr/local/bin
echo -e "${BLUE}Установка файлов в систему...${NC}"
sudo mv gosms.sh /usr/local/bin/gosms
sudo mv translations.sh /usr/local/bin/gosms_translations.sh

# Очищаем временную директорию
rm -rf "$TEMP_DIR"

# Подключаем файл с переводами
source /usr/local/bin/gosms_translations.sh

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

# Вывод логотипа
clear
echo -e "${CYAN}$(get_text "en" "logo")${NC}"

# Выбор языка
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
CONFIG_FILE="$HOME/.gosms.conf"
echo "language=$LANG" > "$CONFIG_FILE"

# Вывод инструкций по получению API ключа
clear
echo -e "${CYAN}$(get_text "$LANG" "logo")${NC}"
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

echo -e "${GREEN}✅ $(get_text "$LANG" "cli_installed")${NC}"
echo -e "${YELLOW}$(get_text "$LANG" "example_command")${NC}"
echo -e "${YELLOW}$(get_text "$LANG" "example_edit")${NC}" 