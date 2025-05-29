#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Базовый URL репозитория
REPO_URL="https://raw.githubusercontent.com/your-repo/gosms/main"

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

echo -e "${GREEN}✅ GoSMS CLI успешно установлен!${NC}"
echo -e "${YELLOW}Для начала работы выполните:${NC}"
echo -e "  gosms --edit    # для настройки API-ключа"
echo -e "  gosms --help    # для просмотра справки" 