#!/bin/bash

# Перевірка наявності необхідних утиліт, встановлення якщо відсутні
if ! command -v figlet &> /dev/null; then
    echo "figlet не знайдено. Встановлюємо..."
    sudo apt update && sudo apt install -y figlet
fi

if ! command -v whiptail &> /dev/null; then
    echo "whiptail не знайдено. Встановлюємо..."
    sudo apt update && sudo apt install -y whiptail
fi

# Завантаження та відображення логотипу
LOGO_URL="https://raw.githubusercontent.com/Baryzhyk/nodes/main/logo.sh"
LOGO_SCRIPT="$HOME/logo.sh"

curl -fsSL -o "$LOGO_SCRIPT" "$LOGO_URL"
chmod +x "$LOGO_SCRIPT"
bash "$LOGO_SCRIPT"

# Функція для відображення ASCII-заставки
animate_loading() {
    for ((i = 1; i <= 5; i++)); do
        printf "\r${GREEN}Завантажуємо меню${NC}."
        sleep 0.3
        printf "\r${GREEN}Завантажуємо меню${NC}.."
        sleep 0.3
        printf "\r${GREEN}Завантажуємо меню${NC}..."
        sleep 0.3
        printf "\r${GREEN}Завантажуємо меню${NC}"
        sleep 0.3
    done
    echo ""
}

animate_loading
echo ""

show_logo() {
    echo -e "\e[34m"
    figlet "Hyper Control"
    echo -e "\e[0m"
}

# Функція для відображення меню
show_menu() {
    echo ""
    echo "==============================="
    echo "   Центр керування Hyper Bot   "
    echo "==============================="
    echo " 1. 🛠 Встановити бота"
    echo " 2. ⬆ Оновити бота"
    echo " 3. 🔎 Перевірити стан"
    echo " 4. 🔄 Перезапустити бота"
    echo " 5. 🗑 Видалити бота"
    echo " 6. 🚪 Вихід"
    echo "==============================="
    echo -n "Оберіть дію (1-6): "
}

# Функція встановлення бота
install_bot() {
    echo "🛠 Встановлення бота..."
    sleep 1
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y python3 python3-venv python3-pip curl

    PROJECT_DIR="$HOME/hyperbolic"
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR" || exit 1

    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install requests
    deactivate
    cd

    echo "✅ Бот встановлено!"
    sleep 2
}

# Функція оновлення бота
update_bot() {
    echo "⬆ Оновлення бота..."
    sleep 2
    echo "✅ Оновлення завершено!"
}

# Функція перевірки стану
check_status() {
    echo "🔎 Перевірка логів..."
    sudo journalctl -u hyper-bot.service -f
}

# Функція перезапуску бота
restart_bot() {
    echo "🔄 Перезапуск бота..."
    sudo systemctl restart hyper-bot.service
    sudo journalctl -u hyper-bot.service -f
}

# Функція видалення бота
remove_bot() {
    echo "🗑 Видалення бота..."
    sudo systemctl stop hyper-bot.service
    sudo systemctl disable hyper-bot.service
    sudo rm /etc/systemd/system/hyper-bot.service
    sudo systemctl daemon-reload
    sleep 2

    rm -rf "$HOME/hyperbolic"

    echo "✅ Бот видалено!"
}

# Основний цикл меню
while true; do
    clear
    show_logo
    show_menu
    read -r CHOICE

    case $CHOICE in
        1) install_bot ;;
        2) update_bot ;;
        3) check_status ;;
        4) restart_bot ;;
        5) remove_bot ;;
        6) echo "🚪 Вихід..."; exit 0 ;;
        *) echo "❌ Невірний вибір. Спробуйте ще раз." ;;
    esac

    echo "Натисніть Enter, щоб продовжити..."
    read -r
done
