import requests
import random
import logging
import time
from faker import Faker
from datetime import datetime

# Константы
NODE_URL = "https://[АДРЕС].us.gaianet.network/v1/chat/completions"
HEADERS = {
    "Accept": "application/json",
    "Content-Type": "application/json"
}
LOG_FILE = "chat_log.txt"
MIN_DELAY = 60
MAX_DELAY = 180

# Инициализация
faker = Faker()
logging.basicConfig(filename=LOG_FILE, level=logging.INFO, format='%(asctime)s - %(message)s')


def log_message(event_type, message):
    logging.info(f"{event_type}: {message}")


def send_message_to_node(url, message_payload):
    try:
        response = requests.post(url, json=message_payload, headers=HEADERS)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as error:
        logging.error(f"Failed to get response from API: {error}")
        return None


def extract_reply_from_response(response):
    if response and 'choices' in response and response['choices']:
        return response['choices'][0]['message']['content']
    return ""


def generate_random_question():
    return faker.sentence(nb_words=10)


def main_loop():
    while True:
        random_question = generate_random_question()
        message_payload = {
            "messages": [
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": random_question}
            ]
        }

        question_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Отправка сообщения и получение ответа
        response = send_message_to_node(NODE_URL, message_payload)
        reply = extract_reply_from_response(response)

        reply_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Логирование вопроса и ответа
        log_message("Node replied", f"Q ({question_time}): {random_question} A ({reply_time}): {reply}")

        # Вывод в консоль
        print(f"Q ({question_time}): {random_question}\nA ({reply_time}): {reply}")

        # Задержка перед следующим запросом
        delay = random.randint(MIN_DELAY, MAX_DELAY)
        time.sleep(delay)


if __name__ == "__main__":
    main_loop()
