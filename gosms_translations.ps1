# Функция для получения перевода
function Get-Text {
    param (
        [string]$lang,
        [string]$key
    )

    $translations = @{
        'ru' = @{
            'app_name' = 'GoSMS CLI'
            'usage' = 'Использование:'
            'command_format' = 'gosms [команда] [опции]'
            'commands' = 'Команды:'
            'send_sms' = 'Отправить SMS'
            'edit_settings' = 'Редактировать настройки'
            'uninstall' = 'Удалить программу'
            'show_help' = 'Показать справку'
            'options' = 'Опции:'
            'phone' = 'Номер телефона'
            'text' = 'Текст сообщения'
            'device' = 'ID устройства'
            'sim' = 'Номер SIM-карты'
            'examples' = 'Примеры:'
            'example_simple' = 'gosms sendsms -num +79001234567 --text "Тестовое сообщение"'
            'example_full' = 'gosms sendsms -num +79001234567 --text "Тестовое сообщение" --device 123 --sim 1'
            'example_edit' = 'gosms --edit'
            'config' = 'Конфигурация:'
            'token_stored' = 'Токен хранится в'
            'token_edit' = 'Для изменения токена используйте'
            'invalid_api_key' = 'Неверный формат API ключа'
            'api_key_instructions' = 'Введите ваш API ключ от GoSMS'
            'enter_api_key' = 'API Key: '
            'api_key_saved' = 'API ключ успешно сохранен'
            'settings_updated' = 'Настройки обновлены'
            'settings_not_changed' = 'Настройки не изменены'
            'uninstall_confirm' = 'Вы уверены, что хотите удалить GoSMS CLI? (y/n): '
            'uninstall_cancelled' = 'Удаление отменено'
            'uninstalling' = 'Удаление GoSMS CLI...'
            'removing_files' = 'Удаление файлов...'
            'removing_config' = 'Удаление конфигурации...'
            'uninstall_complete' = 'GoSMS CLI успешно удален'
            'token_not_found' = 'API ключ не найден'
            'run_edit_first' = 'Сначала выполните gosms --edit'
            'required_params' = 'Требуются параметры -num и --text'
            'sim_without_device' = 'Параметр --sim требует указания --device'
            'unknown_param' = 'Неизвестный параметр:'
            'select_language' = 'Выберите язык / Select language:'
            'russian' = 'Русский'
            'english' = 'English'
            'press_enter' = 'Нажмите Enter для выхода'
        }
        'en' = @{
            'app_name' = 'GoSMS CLI'
            'usage' = 'Usage:'
            'command_format' = 'gosms [command] [options]'
            'commands' = 'Commands:'
            'send_sms' = 'Send SMS'
            'edit_settings' = 'Edit settings'
            'uninstall' = 'Uninstall'
            'show_help' = 'Show help'
            'options' = 'Options:'
            'phone' = 'Phone number'
            'text' = 'Message text'
            'device' = 'Device ID'
            'sim' = 'SIM card number'
            'examples' = 'Examples:'
            'example_simple' = 'gosms sendsms -num +79001234567 --text "Test message"'
            'example_full' = 'gosms sendsms -num +79001234567 --text "Test message" --device 123 --sim 1'
            'example_edit' = 'gosms --edit'
            'config' = 'Configuration:'
            'token_stored' = 'Token is stored in'
            'token_edit' = 'To change token use'
            'invalid_api_key' = 'Invalid API key format'
            'api_key_instructions' = 'Enter your GoSMS API key'
            'enter_api_key' = 'API Key: '
            'api_key_saved' = 'API key saved successfully'
            'settings_updated' = 'Settings updated'
            'settings_not_changed' = 'Settings not changed'
            'uninstall_confirm' = 'Are you sure you want to uninstall GoSMS CLI? (y/n): '
            'uninstall_cancelled' = 'Uninstall cancelled'
            'uninstalling' = 'Uninstalling GoSMS CLI...'
            'removing_files' = 'Removing files...'
            'removing_config' = 'Removing configuration...'
            'uninstall_complete' = 'GoSMS CLI successfully uninstalled'
            'token_not_found' = 'API key not found'
            'run_edit_first' = 'Please run gosms --edit first'
            'required_params' = 'Parameters -num and --text are required'
            'sim_without_device' = 'Parameter --sim requires --device'
            'unknown_param' = 'Unknown parameter:'
            'select_language' = 'Select language:'
            'russian' = 'Russian'
            'english' = 'English'
            'press_enter' = 'Press Enter to exit'
        }
    }

    if ($translations.ContainsKey($lang) -and $translations[$lang].ContainsKey($key)) {
        return $translations[$lang][$key]
    }
    elseif ($translations['en'].ContainsKey($key)) {
        return $translations['en'][$key]
    }
    else {
        return $key
    }
} 