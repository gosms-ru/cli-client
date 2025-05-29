#!/bin/bash

# Подключаем файл с переводами
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "$SCRIPT_DIR/translations.sh"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Загружаем язык из конфигурации
CONFIG_FILE="$HOME/.gosms.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    LANG=$(grep '^language=' "$CONFIG_FILE" | cut -d '=' -f2- | tr -d '\r')
else
    LANG="en" # По умолчанию английский
fi

# Показываем информацию о приложении
echo -e "${CYAN}$(get_text "$LANG" "app_name")${NC}"

# Запрос подтверждения
read -p "$(get_text "$LANG" "uninstall_confirm")" confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo -e "${YELLOW}$(get_text "$LANG" "uninstall_cancelled")${NC}"
    exit 0
fi

echo -e "${BLUE}$(get_text "$LANG" "uninstalling")${NC}"

# Удаление файлов
echo -e "${BLUE}$(get_text "$LANG" "removing_files")${NC}"
sudo rm -f /usr/local/bin/gosms
sudo rm -f /usr/local/bin/gosms_translations.sh

# Удаление конфигурации
echo -e "${BLUE}$(get_text "$LANG" "removing_config")${NC}"
rm -f "$CONFIG_FILE"

echo -e "${GREEN}✅ $(get_text "$LANG" "uninstall_complete")${NC}" 