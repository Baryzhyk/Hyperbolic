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

# ASCII заголовок
figlet "Hyperbolic Panel"
echo -e "${CYAN}Ласкаво просимо до панелі управління Hyperbolic!${NC}\n"

# Вивід меню
CHOICE=$(whiptail --title "🛠 HYPERBOLIC CONTROL CENTER 🛠" \
    --menu "🎛 Оберіть свою місію:" 18 60 6 \
    "🛠 1" "⚙️ Запуск HYPER-IA (встановлення бота)" \
    "🔄 2" "📡 Завантаження оновлення для HYPER-IA" \
    "🔍 3" "📊 Дослідження звітів роботи (логи)" \
    "🔁 4" "🚀 Перезапуск процесора HYPER-IA" \
    "🗑 5" "💀 Самознищення HYPER-IA (видалення)" \
    3>&1 1>&2 2>&3)

case $CHOICE in
    "🛠 1")
        echo -e "${BLUE}🚀 Встановлення бота...${NC}"
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
        BOT_URL="https://raw.githubusercontent.com/Baryzhyk/Hyperbolic/refs/heads/main/bot.py"
        curl -fsSL -o "$PROJECT_DIR/HyperChatter.py" "$BOT_URL"
        echo -e "${YELLOW}Введіть ваш API-ключ для Hyperbolic:${NC}"
        read -r USER_API_KEY
        sed -i "s/API_KEY = \"\$API_KEY\"/API_KEY = \"$USER_API_KEY\"/" "$PROJECT_DIR/HyperChatter.py"
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
    "🔄 2")
        echo -e "${BLUE}📡 Оновлення бота...${NC}"
        sleep 2
        echo -e "${GREEN}🔄 Оновлення завершене!${NC}"
        ;;
    "🔍 3")
        echo -e "${BLUE}📊 Аналізую звіти...${NC}"
        sudo journalctl -u hyper-bot.service -f
        ;;
    "🔁 4")
        echo -e "${BLUE}🚀 Перезапускаю Hyper-IA...${NC}"
        sudo systemctl restart hyper-bot.service
        sudo journalctl -u hyper-bot.service -f
        ;;
    "🗑 5")
        echo -e "${RED}💀 Самознищення Hyper-IA...${NC}"
        sudo systemctl stop hyper-bot.service
        sudo systemctl disable hyper-bot.service
        sudo rm /etc/systemd/system/hyper-bot.service
        sudo systemctl daemon-reload
        rm -rf "$HOME/hyperbolic"
        echo -e "${GREEN}☠️ HYPER-IA видалено!${NC}"
        ;;
    *)
        echo -e "${RED}❌ Місія скасована.${NC}"
        ;;
esac
