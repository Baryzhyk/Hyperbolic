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

# Визначаємо кольори
YELLOW="\e[33m"
CYAN="\e[36m"
BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
PINK="\e[35m"
NC="\e[0m"

# Функція анімації
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

# Вивід меню
CHOICE=$(whiptail --title "Меню дій" \
    --menu "Виберіть дію:" 15 50 5 \
    "1" "Встановити бота" \
    "2" "Оновити бота" \
    "3" "Перевірка роботи бота" \
    "4" "Перезапустити бота" \
    "5" "Видалити бота" \
    3>&1 1>&2 2>&3)

case $CHOICE in
    1)
        echo -e "${BLUE}Встановлення бота...${NC}"

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
        echo -e "${YELLOW}Введіть ваш API-ключ для Hyperbolic:${NC}"
        read -r USER_API_KEY
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

        echo -e "${YELLOW}Команда для перевірки логів:${NC}"
        echo "sudo journalctl -u hyper-bot.service -f"
        sleep 2
        sudo journalctl -u hyper-bot.service -f
        ;;

    2)
        echo -e "${BLUE}Оновлення бота...${NC}"
        sleep 2
        echo -e "${GREEN}Оновлення бота поки не потрібне!${NC}"
        ;;

    3)
        echo -e "${BLUE}Перегляд логів...${NC}"
        sudo journalctl -u hyper-bot.service -f
        ;;

    4)
        echo -e "${BLUE}Перезапуск бота...${NC}"
        sudo systemctl restart hyper-bot.service
        sudo journalctl -u hyper-bot.service -f
        ;;
        
    5)
        echo -e "${BLUE}Видалення бота...${NC}"

        sudo systemctl stop hyper-bot.service
        sudo systemctl disable hyper-bot.service
        sudo rm /etc/systemd/system/hyper-bot.service
        sudo systemctl daemon-reload
        sleep 2

        rm -rf "$HOME_DIR/hyperbolic"

        echo -e "${GREEN}Бот успішно видалений!${NC}"
        sleep 1
        ;;
    
    *)
        echo -e "${RED}Невірний вибір. Завершення програми.${NC}"
        ;;
esac
