#!/bin/bash

# Проверка наличия IP-адреса в аргументах
if [ $# -ne 1 ]; then
  echo "Использование: $0 <IP-адрес>"
  exit 1
fi

IP_ADDRESS="$1"
API_URL="https://ipinfo.io/$IP_ADDRESS/geo"

# Получаем данные из API
response=$(curl -s "$API_URL")

# Проверка на успешное получение данных
if [ $? -ne 0 ]; then
  echo "Ошибка при получении данных из API."
  exit 1
fi

# Проверка на наличие данных
if [[ "$response" == *"error"* ]]; then
  echo "Ошибка: Неверный IP-адрес или нет данных для этого IP."
  exit 1
fi

# Парсинг JSON и вывод в табличном формате
echo -e "\n\033[1mИнформация о геолокации для IP-адреса $IP_ADDRESS:\033[0m"
printf "| %-15s | %-20s |\n" "Поле" "Значение"
printf "|%-17s|%-22s|\n" "-----------------" "--------------------"

# Извлечение данных из JSON
echo "$response" | jq -r 'to_entries | .[] | [.key, .value] | @tsv' | \
while IFS=$'\t' read -r key value; do
  printf "| %-15s | %-20s |\n" "$key" "$value"
done

