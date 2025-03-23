import time
import requests
import logging

# Конфігурація API Hyperbolic
HYPERBOLIC_API_URL = "https://api.hyperbolic.xyz/v1/chat/completions"
HYPERBOLIC_API_KEY = "$API_KEY"  # Замініть на свій API-ключ
MODEL = "meta-llama/Llama-3.3-70B-Instruct"      # Або вкажіть потрібну модель
MAX_TOKENS = 2048
TEMPERATURE = 0.7
TOP_P = 0.9
DELAY_BETWEEN_QUESTIONS = 45  # затримка між питаннями у секундах

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_response(question: str) -> str:
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {HYPERBOLIC_API_KEY}"
    }
    data = {
        "messages": [{"role": "user", "content": question}],
        "model": MODEL,
        "max_tokens": MAX_TOKENS,
        "temperature": TEMPERATURE,
        "top_p": TOP_P
    }
    response = requests.post(HYPERBOLIC_API_URL, headers=headers, json=data, timeout=30)
    response.raise_for_status()
    json_response = response.json()
    # Передбачається, що відповідь має структуру, схожу на API OpenAI:
    return json_response.get("choices", [{}])[0].get("message", {}).get("content", "Немає відповіді")

def main():
    # Читання питань з файлу "questions.txt"
    try:
        with open("questions.txt", "r", encoding="utf-8") as f:
            questions = [line.strip() for line in f if line.strip()]
    except Exception as e:
        logger.error(f"Помилка читання файлу questions.txt: {e}")
        return

    if not questions:
        logger.error("В файлі questions.txt немає питань.")
        return

    index = 0
    while True:
        question = questions[index]
        logger.info(f"Питання #{index+1}: {question}")
        try:
            answer = get_response(question)
            logger.info(f"Відповідь: {answer}")
        except Exception as e:
            logger.error(f"Помилка отримання відповіді для питання: {question}\n{e}")
        index = (index + 1) % len(questions)
        time.sleep(DELAY_BETWEEN_QUESTIONS)

if __name__ == "__main__":
    main()
