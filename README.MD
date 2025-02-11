## Описание
Данный PowerShell-скрипт предназначен для автоматического создания RDP-файлов на основе данных, предоставленных в CSV-файле, или для ручного ввода. Он также автоматически добавляет пользователей в группу "Пользователи удаленного рабочего стола" на удаленных машинах через `Invoke-Command`.

## Возможности
1. Создание RDP-файлов из CSV-файла с данными о компьютерах, логинах и именах пользователей.
2. Ручное создание RDP-файла для одного пользователя с заданными параметрами.
3. Автоматическое добавление пользователей в группу "Пользователи удаленного рабочего стола".
4. Проверка корректности данных и диагностика через вывод сообщений в консоль.

## Параметры

### Основные параметры
- **`-csv <path>`**
  Путь к CSV-файлу с данными для создания RDP-файлов.
- **`-hand`**
  Ручной ввод данных для создания одного RDP-файла. Требуются дополнительные параметры:
  - **`-PCName`**: Имя компьютера.
  - **`-Login`**: Логин пользователя.
  - **`-DisplayName`**: Отображаемое имя пользователя.
- **`-help`**
  Вывод справки по использованию скрипта.

## Формат CSV-файла
Файл должен быть сохранен в формате UTF-8. Пример содержимого:
```
"PCName","DisplayName","Login"
"PC-WS001","Пользователь П","user.u"
```

## Примеры использования

### 1. Работа с CSV-файлом
```
.\script.ps1 -csv 'C:\Путь\До\файла.csv'
```

### 2. Ручной ввод данных
```
.\script.ps1 -hand -PCName 'PC-WS001' -Login 'user.u' -DisplayName 'Пользователь П'
```

### 3. Вывод справки
```
.\script.ps1 -help
```

## Устройство скрипта

### Основные функции используещихся в скрипте
1. **`Show-Help`**
   Вывод справочной информации по параметрам и примерам использования скрипта.

2. **`Add-UserToRemoteDesktopGroup`**
   Добавляет пользователя в группу "Пользователи удаленного рабочего стола" на удаленной машине с помощью `Invoke-Command`.

3. **`Process-Csv`**
   Обрабатывает CSV-файл, создаёт RDP-файлы для каждого пользователя и вызывает добавление в группу удаленного рабочего стола.

4. **`Create-RdpFromHand`**
   Создаёт один RDP-файл на основе вручную введённых параметров.

### Вывод сообщений
Скрипт предоставляет обратную связь пользователю:
- Уведомляет о создании файлов и добавлении пользователей в группы.
- Сообщает об ошибках (например, отсутствующих данных или недоступных машинах).

## Сильные стороны
1. **Простота использования:** Параметры интуитивно понятны, а подробная справка позволяет быстро освоить работу.
2. **Гибкость:** Возможность работы как с CSV-файлом, так и с ручным вводом.
3. **Диагностика:** Подробный вывод сообщений об ошибках и успешных операциях.
4. **Автоматизация:** Упрощает массовое создание RDP-файлов и настройку удалённого доступа.

## Слабые стороны
1. **Поддержка только доменов формата DOMAIN.local** # В будущем можно исправить.
2. **Зависимость от настроек PowerShell:** Может потребоваться изменение политики выполнения скриптов (`Set-ExecutionPolicy`).
3. **Права администратора:** Для добавления пользователей в группу "Пользователи удаленного рабочего стола" требуются права администратора.
4. **Отсутствие логов:** Скрипт не сохраняет информацию о выполнении операций в лог-файл.
5. **Отсутствие проверки подключения к домену:** Скрипт предполагает, что домен всегда доступен.
6. **Поддержка только русcкоязычных ПК**

## Рекомендации по улучшению
1. Добавить поддежку доменов разного формата 
2. Добавить возможность записи логов в файл.
3. Реализовать проверку доступности компьютеров перед выполнением операций.
4. Сделать параметры домена и пути к выходной папке настраиваемыми через конфигурационный файл.
5. Улучшить обработку ошибок (например, добавить коды ошибок).

## Установка и запуск
1. Сохраните скрипт с расширением `.ps1`. (RDPShorts.ps1)
2. Измените переменную $Domain на имя вышего домена 
3. Измените переменную $OutputFolder на место сохранения rdp файлов (опционально)
4. Откройте PowerShell с правами администратора.
5. Запустите скрипт с нужными параметрами. (.\RDPShorts.ps1 -help)

## Требования
- Windows PowerShell (рекомендуется версия 5.1 или выше).
- Доступ к домену и правам администратора.
- Формат CSV-файла с кодировкой UTF-8.