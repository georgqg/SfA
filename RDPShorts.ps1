param (
    # Параметры для работы с CSV-файлом
    [string]$csv,

    # Параметры для ручного ввода
    [switch]$hand,
    [string]$PCName,
    [string]$Login,
    [string]$DisplayName,

    # Параметр для справки
    [switch]$help
)

# Функция для вывода справки
function Show-Help {
    Write-Host "Использование скрипта:"
    Write-Host "        -csv <path>            Путь к CSV-файлу с данными для создания RDP-файлов."
    Write-Host "        -hand                  Ручной ввод данных для создания одного RDP-файла."
    Write-Host "                                <PCName> <Login> <DisplayName>" -ForegroundColor Yellow
    Write-Host "                                Параметры для ручного ввода (используются с -hand)."
    Write-Host "        -help                  Показать справку по использованию скрипта."
    Write-Host ""
    Write-Host "Пример использования:"
    Write-Host "        1. Для работы с CSV:"
    Write-Host "           .\script.ps1 -csv 'C:\Путь\До\файла.csv'" -ForegroundColor Yellow
    Write-Host "        2. Для ручного ввода:"
    Write-Host "           .\script.ps1 -hand -PCName 'PC-WS001' -Login 'user.u' -DisplayName 'Пользователь П'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Пример CSV файла:"
    Write-Host '        "PCName","DisplayName","Login"' -ForegroundColor Yellow
    Write-Host '        "PC-WS001","Пользователь П","user.u"' -ForegroundColor Yellow
}



# Домен Active Directory
$Domain = "DOMAIN"
# Папка для сохранения RDP-файлов
$OutputFolder = "$env:USERPROFILE\Desktop\RDP_Files"

function Add-UserToRemoteDesktopGroup {
    param (
        [string]$PCName,
        [string]$Login
    )

    try {
        Invoke-Command -ComputerName $PCName -ScriptBlock {
            param ($User)
            $group = [ADSI]"WinNT://./Пользователи удаленного рабочего стола,group"
            $existingMembers = @($group.psbase.Invoke("Members")) | ForEach-Object {
                $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
            }

            if ($User -in $existingMembers) {
                Write-Host "Пользователь $User уже состоит в группе 'Пользователи удаленного рабочего стола'." -ForegroundColor Green
            } else {
                $group.Add("WinNT://$env:USERDOMAIN/$User")
                Write-Host "Пользователь $User добавлен в группу 'Пользователи удаленного рабочего стола'." -ForegroundColor Green
            }
        } -ArgumentList $Login
    } catch {
        Write-Host "Не удалось подключиться к ПК $PCName. Причина: $($_.Exception.Message)" -ForegroundColor Red
    }
}




# Убедимся, что папка существует
if (-not (Test-Path -Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder
}

# Функция для обработки CSV-файла и создания RDP-файлов
function Process-Csv {
    param (
        [string]$csvFilePath
    )
    
   
    # Убедимся, что папка существует
    if (-not (Test-Path -Path $OutputFolder)) {
        New-Item -ItemType Directory -Path $OutputFolder
    }

    # Проверка наличия CSV-файла
    if (-not (Test-Path -Path $csvFilePath)) {
        Write-Host "CSV файл $csvFilePath не найден!" -ForegroundColor Red
        return
    }

    # Загрузка данных из CSV-файла с кодировкой UTF-8
    $Servers = Import-Csv -Path $csvFilePath -Encoding UTF8

    # Диагностика: выведем все строки, чтобы убедиться, что данные загружаются корректно
    Write-Host "Данные, загруженные из CSV:"
    $Servers | Format-Table -Property PCName, DisplayName, Login

    # Проход по данным из CSV и создание RDP-файлов
    foreach ($Server in $Servers) {
        # Диагностика: проверим содержимое каждого элемента
        Write-Host "Проверка содержимого для $($Server.PCName):" -ForegroundColor Yellow
        Write-Host "PCName: '$($Server.PCName)' Login: '$($Server.Login)' DisplayName: '$($Server.DisplayName)'" -ForegroundColor Yellow

        # Убираем лишние пробелы и скрытые символы
        $Login = $Server.Login.Trim()
        if (-not $Login) {
        Write-Host "Ошибка: Login для компьютера $($Server.PCName) не задан!" -ForegroundColor Red
        continue
    }
        
        # Содержимое RDP-файла
        $RDPFileName = "$OutputFolder\$($Server.DisplayName) - $($Server.PCName).rdp"
        $RDPContent = @"
full address:s:$($Server.PCName).$Domain.local
username:s:$Domain\$Login
prompt for credentials:i:1
"@

        # Сохранение RDP-файла с кодировкой UTF-8 через Out-File
        $RDPContent | Out-File -FilePath $RDPFileName -Encoding utf8
        Write-Host "Создан файл: $RDPFileName" -ForegroundColor Green
        Add-UserToRemoteDesktopGroup -PCName $Server.PCName -Login $Login

    }
}

# Функция для создания одного RDP-файла на основе ручных данных
function Create-RdpFromHand {
    param (
        [string]$PCName,
        [string]$Login,
        [string]$DisplayName
    )
    


    Write-Host "Создание RDP-файла для: $PCName, Login: $Login, DisplayName: $DisplayName" -ForegroundColor Yellow

    # Содержимое RDP-файла
    $RDPFileName = "$OutputFolder\$DisplayName - $PCName.rdp"
    $RDPContent = @"
full address:s:$PCName.$Domain.local
username:s:$Domain\$Login
prompt for credentials:i:1
"@

    # Сохранение RDP-файла с кодировкой UTF-8 через Out-File
    $RDPContent | Out-File -FilePath $RDPFileName -Encoding utf8
    Write-Host "Создан файл: $DisplayName - $PCName.rdp" -ForegroundColor Green
    Add-UserToRemoteDesktopGroup -PCName $PCName -Login $Login

}

# Обработка параметра -help, (выводим справку и выходим)
if ($help) {
    Show-Help
    return
}

# Обработка параметра -csv
if ($csv) {
    Process-Csv -csvFilePath $csv
}

# Обработка параметра -hand
elseif ($hand) {
    # Проверка наличия всех обязательных параметров для ручного ввода
    if (-not $PCName -or -not $Login -or -not $DisplayName) {
        Write-Host "Необходимо указать все параметры: -PCName, -Login, -DisplayName!" -ForegroundColor Red
        return
    }

    Create-RdpFromHand -PCName $PCName -Login $Login -DisplayName $DisplayName
}

else {
    Write-Host "Нет заданных параметров. Используйте -help для справки!" -ForegroundColor Red
}

Write-Host "Завершено!"