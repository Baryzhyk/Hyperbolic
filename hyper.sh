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

# Анімація завантаження
animate_loading() {
    for i in {1..5}; do
        printf "\r${RANDOM_COLOR}Запуск системи${NC}."
        sleep 0.2
        printf "\r${RANDOM_COLOR}Запуск системи${NC}.."
        sleep 0.2
        printf "\r${RANDOM_COLOR}Запуск системи${NC}..."
        sleep 0.2
    done
    echo ""
}

animate_loading
sleep 1

# Відображення меню через dialog
CHOICE=$(dialog --clear --title "Центр керування Hyper" \
    --menu "Оберіть дію:" 15 50 5 \
    1 "🛠 Встановити бота" \
    2 "⬆ Оновити бота" \
    3 "🔎 Перевірити стан" \
    4 "🔄 Перезапустити бота" \
    5 "🗑 Видалити бота" \
    2>&1 >/dev/tty)

clear

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
