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

# Определение архитектуры
ARCH="$(uname -m)"
case "${ARCH}" in
    x86_64)     ARCH="amd64";;
    aarch64)    ARCH="arm64";;
    armv7l)     ARCH="arm";;
    *)          ARCH="unknown";;
esac

# Определение пути установки в зависимости от платформы
case "${PLATFORM}" in
    linux)
        INSTALL_DIR="/usr/local/bin"
        ;;
    macos)
        INSTALL_DIR="/usr/local/bin"
        ;;
    windows)
        INSTALL_DIR="/usr/local/bin"
        ;;
    *)
        echo "Неподдерживаемая операционная система"
        exit 1
        ;;
esac

# Проверка на прямой запуск скрипта
if [ -t 0 ]; then
    # Скрипт запущен напрямую
    :
else
    # Скрипт запущен через pipe
    echo "Для корректной работы установщика, пожалуйста, выполните следующие команды:"
    echo "curl -sSL https://raw.githubusercontent.com/gosms-ru/cli-client/main/install-gosms.sh -o install-gosms.sh"
    echo "chmod +x install-gosms.sh"
    echo "./install-gosms.sh"
    exit 1
fi

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

# Функция для генерации логотипа
generate_logo() {
    printf "${CYAN}
╔═══════════════════════════════════════════════════╗
║                                                   ║
║  ██████═╗  ██████╗ ███████╗███╗   ███╗███████╗    ║
║  ██╔════╝ ██╔═══██╗██╔════╝████╗ ████║██╔════╝    ║
║  ██║  ███╗██║   ██║███████╗██╔████╔██║███████╗    ║
║  ██║   ██║██║   ██║╚════██║██║╚██╔╝██║╚════██║    ║
║  ╚██████╔╝╚██████╔╝███████║██║ ╚═╝ ██║███████║    ║
║   ╚═════╝  ╚═════╝ ╚══════╝╚═╝     ╚═╝╚══════╝    ║
║                                                   ║
╚═══════════════════════════════════════════════════╝${NC}\n"
}

# Базовый URL репозитория
REPO_URL="https://raw.githubusercontent.com/gosms-ru/cli-client/developer"

# Функция для проверки прав суперпользователя
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}Для установки в системные директории требуются права суперпользователя${NC}"
        echo -e "${YELLOW}Пожалуйста, введите пароль для sudo:${NC}"
        if ! sudo -v; then
            echo -e "${RED}❌ Не удалось получить права суперпользователя${NC}"
            exit 1
        fi
    fi
}

# Функция для создания директории с правами
create_install_dir() {
    if [ ! -d "$INSTALL_DIR" ]; then
        echo -e "${YELLOW}Создаем директорию $INSTALL_DIR...${NC}"
        if [ "$PLATFORM" = "windows" ]; then
            mkdir -p "$INSTALL_DIR"
        else
            sudo mkdir -p "$INSTALL_DIR"
        fi
    fi
}

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

# Создаем временную директорию с учетом платформы
if [ "$PLATFORM" = "windows" ]; then
    TEMP_DIR=$(mktemp -d)
else
    TEMP_DIR=$(mktemp -d)
fi

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

# Создаем директорию установки
create_install_dir

# Копируем файлы
echo -e "${BLUE}Копирование файлов...${NC}"
if [ "$PLATFORM" = "windows" ]; then
    cp gosms.sh "$INSTALL_DIR/gosms"
    cp translations.sh "$INSTALL_DIR/gosms_translations.sh"
else
    sudo cp gosms.sh "$INSTALL_DIR/gosms"
    sudo cp translations.sh "$INSTALL_DIR/gosms_translations.sh"
fi

# Устанавливаем права
echo -e "${BLUE}Установка прав доступа...${NC}"
if [ "$PLATFORM" = "windows" ]; then
    chmod 755 "$INSTALL_DIR/gosms"
    chmod 755 "$INSTALL_DIR/gosms_translations.sh"
else
    sudo chmod 755 "$INSTALL_DIR/gosms"
    sudo chmod 755 "$INSTALL_DIR/gosms_translations.sh"
fi

# Очищаем временную директорию
rm -rf "$TEMP_DIR"

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

# Исправленная функция выбора языка
choose_language() {
    # Выводим логотип перед выбором языка
    printf "${CYAN}
╔═══════════════════════════════════════════════════╗
║                                                   ║
║  ██████═╗  ██████╗ ███████╗███╗   ███╗███████╗    ║
║  ██╔════╝ ██╔═══██╗██╔════╝████╗ ████║██╔════╝    ║
║  ██║  ███╗██║   ██║███████╗██╔████╔██║███████╗    ║
║  ██║   ██║██║   ██║╚════██║██║╚██╔╝██║╚════██║    ║
║  ╚██████╔╝╚██████╔╝███████║██║ ╚═╝ ██║███████║    ║
║   ╚═════╝  ╚═════╝ ╚══════╝╚═╝     ╚═╝╚══════╝    ║
║                                                   ║
╚═══════════════════════════════════════════════════╝${NC}\n"

    while true; do
        echo ""
        echo -e "${BLUE}Выберите язык / Select language:${NC}"
        echo "1) Русский"
        echo "2) English"
        echo ""
        read -p "Выберите номер / Select number (1-2): " lang_choice
        case "$lang_choice" in
            1)
                LANG="ru"
                echo -e "${GREEN}✅ Выбран русский язык${NC}"
                sleep 1
                break
                ;;
            2)
                LANG="en"
                echo -e "${GREEN}✅ English language selected${NC}"
                sleep 1
                break
                ;;
            *)
                echo -e "${RED}❌ Неверный выбор. Пожалуйста, выберите 1 или 2${NC}"
                sleep 1
                ;;
        esac
    done
}

# Функция для запроса API ключа
request_api_key() {
    local lang=$1
    local config_file=$2
    
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

choose_language

echo "language=$LANG" > "$CONFIG_FILE"

request_api_key "$LANG" "$CONFIG_FILE"

echo -e "${GREEN}✅ $(get_text "$LANG" "cli_installed")${NC}"
echo -e "${YELLOW}$(get_text "$LANG" "example_command")${NC}"
echo -e "${YELLOW}$(get_text "$LANG" "example_edit")${NC}"

# Ждем нажатия Enter перед выходом
read -p "$(get_text "$LANG" "press_enter")" 