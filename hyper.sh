#!/bin/bash

# Перевірка наявності необхідних утиліт, встановлення якщо відсутні
if ! command -v figlet &> /dev/null; then
    echo "figlet не знайдено. Встановлюємо..."
    sudo apt update && sudo apt install -y figlet
fi

# Завантаження та відображення логотипу
LOGO_URL="https://raw.githubusercontent.com/Baryzhyk/nodes/main/logo.sh"
LOGO_SCRIPT="$HOME/logo.sh"

curl -fsSL -o "$LOGO_SCRIPT" "$LOGO_URL"
chmod +x "$LOGO_SCRIPT"
bash "$LOGO_SCRIPT"

# Функція анімації завантаження
animate_loading() {
    for ((i = 1; i <= 5; i++)); do
        printf "\r\e[32mЗавантажуємо меню   \e[0m"
        sleep 1
        printf "\r\e[32mЗавантажуємо меню.  \e[0m"
        sleep 1
        printf "\r\e[32mЗавантажуємо меню.. \e[0m"
        sleep 1
        printf "\r\e[32mЗавантажуємо меню...\e[0m"
        sleep 1
    done
    echo ""
}

# Основна функція меню
menu() {
    clear
    figlet "HyperBot Menu"
    echo "===================================="
    echo " 1) Встановити бота"
    echo " 2) Оновити бота"
    echo " 3) Перевірити роботу бота"
    echo " 4) Перезапустити бота"
    echo " 5) Видалити бота"
    echo " 0) Вийти"
    echo "===================================="
    echo -n "Виберіть опцію: "
    read -r CHOICE
    
    case $CHOICE in
        1)
            echo "Встановлення бота..."
            sleep 5
            ;;
        2)
            echo "Оновлення бота..."
            sleep 5
            ;;
        3)
            echo "Перегляд логів..."
            sudo journalctl -u hyper-bot.service -f
            ;;
        4)
            echo "Перезапуск бота..."
            sudo systemctl restart hyper-bot.service
            sleep 5
            ;;
        5)
            echo "Видалення бота..."
            sudo systemctl stop hyper-bot.service
            sudo systemctl disable hyper-bot.service
            sudo rm /etc/systemd/system/hyper-bot.service
            sudo systemctl daemon-reload
            rm -rf "$HOME/hyperbolic"
            echo "Бот успішно видалений!"
            sleep 5
            ;;
        0)
            echo "Вихід..."
            exit 0
            ;;
        *)
            echo "Невірний вибір. Спробуйте ще раз."
            sleep 2
            ;;
    esac
}

# Запускаємо анімацію, а потім меню в циклі
animate_loading
while true; do
    menu
done
