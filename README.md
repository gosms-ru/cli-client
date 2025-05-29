# GoSMS CLI

[English](#english) | [Русский](#russian)

---

<a name="english"></a>
# GoSMS CLI

🚀 SMS CLI Client by GoSMS.ru
📌 Features: 📩Send SMS via command line ⚡Quick integration with GoSMS.ru 🔑API key authentication

## Table of Contents
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Additional Commands](#additional-commands)
- [Examples](#examples)
- [Configuration File](#configuration-file)
- [Uninstallation](#uninstallation)
- [Support](#support)
- [License](#license)

## Installation

### Automatic Installation

To install, run one of the following commands:

```bash
# Method 1 (recommended):
curl -sSL https://raw.githubusercontent.com/gosms-ru/cli-client/main/install-gosms.sh -o install-gosms.sh && chmod +x install-gosms.sh && ./install-gosms.sh

# Method 2 (alternative):
bash -c "$(curl -sSL https://raw.githubusercontent.com/gosms-ru/cli-client/main/install-gosms.sh)"
```

The script will automatically:
1. Download all necessary files
2. Install them in the system
3. Configure access permissions

### Requirements

- curl
- sudo (for installation in system directories)

## Configuration

Before using, you need to obtain an API key from [GoSMS.ru](https://gosms.ru) and configure it:

```bash
gosms --edit
```

Enter the received API key when prompted.

## Usage

### Basic Commands

```bash
gosms sendsms -num <number> --text <text> [--device <id>] [--sim <number>]
```

### Parameters

- `-num <number>` - recipient's phone number (required)
- `--text <text>` - message text (required)
- `--device <id>` - device ID (optional)
- `--sim <number>` - SIM card number (optional, requires device specification)

## Additional Commands

- `gosms --edit` - edit settings (API key)
- `gosms --uninstall` - remove CLI client
- `gosms -h` or `gosms --help` - show help

## Examples

1. Simple SMS sending:
```bash
gosms sendsms -num "+79001234567" --text "Hello, world!"
```

2. Sending SMS with device specification:
```bash
gosms sendsms -num "+79001234567" --text "Test message" --device "device123"
```

3. Sending SMS with device and SIM card specification:
```bash
gosms sendsms -num "+79001234567" --text "Test message" --device "device123" --sim 1
```

## Configuration File

The configuration file is located at `~/.gosms.conf` and contains:
- API key
- Interface language

## Uninstallation

To remove the CLI client, run:

```bash
gosms --uninstall
```

## Support

If you encounter any issues or have questions, please create an issue in the project repository.

## License

MIT License

---

<a name="russian"></a>
# GoSMS CLI

🚀 CLI-клиент для отправки SMS от GoSMS.ru 
📌 Возможности: 📩 Отправка SMS через командную строку ⚡ Быстрая интеграция с сервисом GoSMS.ru 🔑 Работа с API ключом

## Содержание
- [Установка](#установка)
- [Настройка](#настройка)
- [Использование](#использование)
- [Дополнительные команды](#дополнительные-команды)
- [Примеры](#примеры)
- [Конфигурация](#конфигурация)
- [Удаление](#удаление)
- [Поддержка](#поддержка)
- [Лицензия](#лицензия)

## Установка

### Автоматическая установка

Для установки выполните одну из команд:

```bash
# Способ 1 (рекомендуется):
curl -sSL https://raw.githubusercontent.com/gosms-ru/cli-client/main/install-gosms.sh -o install-gosms.sh && chmod +x install-gosms.sh && ./install-gosms.sh

# Способ 2 (альтернативный):
bash -c "$(curl -sSL https://raw.githubusercontent.com/gosms-ru/cli-client/main/install-gosms.sh)"
```

Скрипт автоматически:
1. Загрузит все необходимые файлы
2. Установит их в систему
3. Настроит права доступа

### Требования

- curl
- sudo (для установки в системные директории)

## Настройка

Перед использованием необходимо получить API-ключ на сайте [GoSMS.ru](https://gosms.ru) и настроить его:

```bash
gosms --edit
```

Введите полученный API-ключ при запросе.

## Использование

### Основные команды

```bash
gosms sendsms -num <номер> --text <текст> [--device <id>] [--sim <номер>]
```

### Параметры

- `-num <номер>` - номер телефона получателя (обязательный)
- `--text <текст>` - текст сообщения (обязательный)
- `--device <id>` - ID устройства (опциональный)
- `--sim <номер>` - номер SIM-карты (опциональный, требует указания device)

## Дополнительные команды

- `gosms --edit` - редактировать настройки (API-ключ)
- `gosms --uninstall` - удалить CLI-клиент
- `gosms -h` или `gosms --help` - показать справку

## Примеры

1. Простая отправка SMS:
```bash
gosms sendsms -num "+79001234567" --text "Привет, мир!"
```

2. Отправка SMS с указанием устройства:
```bash
gosms sendsms -num "+79001234567" --text "Тестовое сообщение" --device "device123"
```

3. Отправка SMS с указанием устройства и SIM-карты:
```bash
gosms sendsms -num "+79001234567" --text "Тестовое сообщение" --device "device123" --sim 1
```

## Конфигурация

Конфигурационный файл находится в `~/.gosms.conf` и содержит:
- API-ключ
- Язык интерфейса

## Удаление

Для удаления CLI-клиента выполните:

```bash
gosms --uninstall
```

## Поддержка

При возникновении проблем или вопросов, пожалуйста, создайте issue в репозитории проекта.

## Лицензия

MIT License 