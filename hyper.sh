#!/bin/bash

# Перевірка необхідних утиліт, встановлення якщо їх немає
for pkg in figlet dialog curl; do
    if ! command -v "$pkg" &>/dev/null; then
        echo "$pkg не знайдено. Встановлюємо..."
        sudo apt update && sudo apt install -y "$pkg"
    fi
done

# Завантаження та відображення логотипу
LOGO_URL="https://raw.githubusercontent.com/Baryzhyk/nodes/main/logo.sh"
LOGO_SCRIPT="$HOME/logo.sh"

curl -fsSL -o "$LOGO_SCRIPT" "$LOGO_URL"
chmod +x "$LOGO_SCRIPT"
bash "$LOGO_SCRIPT"

# Кольори
COLORS=("\e[31m" "\e[32m" "\e[33m" "\e[34m" "\e[35m" "\e[36m")
RANDOM_COLOR=${COLORS[$RANDOM % ${#COLORS[@]}]}
NC="\e[0m"

# ASCII-заставка
clear
echo -e "$RANDOM_COLOR"
figlet "Hyper Control"
echo -e "$NC"
sleep 1

#!/bin/bash

# Функція для відображення ASCII-заставки
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

case $CHOICE in
    1)
        echo -e "${RANDOM_COLOR}🛠 Встановлення бота...${NC}"
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

        # Завантаження бота
        BOT_URL="https://raw.githubusercontent.com/Baryzhyk/Hyperbolic/refs/heads/main/bot.py"
        curl -fsSL -o "$PROJECT_DIR/HyperChatter.py" "$BOT_URL"

        # Запит API-ключа
        USER_API_KEY=$(dialog --inputbox "Введіть ваш API-ключ для Hyperbolic:" 8 50 3>&1 1>&2 2>&3)
        sed -i "s/API_KEY = \"\$API_KEY\"/API_KEY = \"$USER_API_KEY\"/" "$PROJECT_DIR/HyperChatter.py"

        # Завантаження питань
        QUESTIONS_URL="https://github.com/Baryzhyk/Hyperbolic/blob/main/Questions.txt"
        curl -fsSL -o "$PROJECT_DIR/questions.txt" "$QUESTIONS_URL"

        USERNAME=$(whoami)
        HOME_DIR=$(eval echo ~$USERNAME)

        sudo bash -c "cat <<EOT > /etc/systemd/system/hyper-bot.service
[Unit]
Description=Hyperbolic API Bot Service
After=network.target

[Service]
User=$USERNAME
WorkingDirectory=$HOME_DIR/hyperbolic
ExecStart=$HOME_DIR/hyperbolic/venv/bin/python $HOME_DIR/hyperbolic/HyperChatter.py
Restart=always
Environment=PATH=$HOME_DIR/hyperbolic/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin

[Install]
WantedBy=multi-user.target
EOT"

        sudo systemctl daemon-reload
        sudo systemctl restart systemd-journald
        sudo systemctl enable hyper-bot.service
        sudo systemctl start hyper-bot.service

        echo -e "${RANDOM_COLOR}✅ Бот встановлено! Для перегляду логів виконайте:${NC}"
        echo "sudo journalctl -u hyper-bot.service -f"
        sleep 2
        sudo journalctl -u hyper-bot.service -f
        ;;

    2)
        echo -e "${RANDOM_COLOR}⬆ Оновлення бота...${NC}"
        sleep 2
        echo -e "${RANDOM_COLOR}✅ Оновлення не потрібне!${NC}"
        ;;

    3)
        echo -e "${RANDOM_COLOR}🔎 Перевірка логів...${NC}"
        sudo journalctl -u hyper-bot.service -f
        ;;

    4)
        echo -e "${RANDOM_COLOR}🔄 Перезапуск бота...${NC}"
        sudo systemctl restart hyper-bot.service
        sudo journalctl -u hyper-bot.service -f
        ;;

    5)
        echo -e "${RANDOM_COLOR}🗑 Видалення бота...${NC}"
        sudo systemctl stop hyper-bot.service
        sudo systemctl disable hyper-bot.service
        sudo rm /etc/systemd/system/hyper-bot.service
        sudo systemctl daemon-reload
        sleep 2

        rm -rf "$HOME_DIR/hyperbolic"

        echo -e "${RANDOM_COLOR}✅ Бот видалено!${NC}"
        sleep 1
        ;;

    *)
        echo -e "${RANDOM_COLOR}❌ Вихід без дії.${NC}"
        ;;
esac
