#!/bin/bash

# Проверка параметров командной строки
INTERFACE="console"  # По умолчанию консольный режим
N=""
K=""

# Если передан параметр --gui, то устанавливаем интерфейс в "gui"
if [[ "$1" == "--gui" ]]; then
  INTERFACE="gui"
  shift  # Убираем первый параметр из аргументов
fi

# Если параметры для N и K переданы, то считываем их
if [[ $# -ge 2 ]]; then
  N=$1
  K=$2
else
  N=5  # Значения по умолчанию для количества директорий и файлов
  K=3
fi

# Функция для получения директорий и файлов с красивым выводом и разделителями
get_directories_and_files() {
  echo -e "\n\033[1mTop $N Directories by Size\033[0m"
  printf "| %-40s | %-10s | %-20s |\n" "Directory" "Size" "Total Size"
  printf "|%-42s|%-12s|%-22s|\n" "------------------------------------------" "----------" "--------------------"

  # Получаем топ N директорий по размеру
  du -ah --max-depth=1 | sort -rh | head -n "$N" | while read -r size dir; do
    total_size=$(du -sh "$dir" | cut -f1)
    printf "| %-40s | %10s | %20s |\n" "$dir" "$size" "$total_size"

    # Найти топ K файлов по размеру в каждой директории
    echo -e "\n\033[1mTop $K Files in $dir\033[0m"
    printf "| %-60s | %-10s |\n" "File" "Size"
    printf "|%-62s|%-12s|\n" "--------------------------------------------------------------" "----------"
    
    find "$dir" -type f -exec du -ah {} + | sort -rh | head -n "$K" | \
    awk '{printf "| %-60s | %10s |\n", $2, $1}' | column -t
    echo
  done
}

# Функция для графического интерфейса с Zenity
gui_mode() {
  N=$(zenity --entry --title "Number of Directories" --text "Enter N (number of directories):" --entry-text "$N")
  K=$(zenity --entry --title "Number of Files" --text "Enter K (number of files):" --entry-text "$K")

  OUTPUT=$(get_directories_and_files)

  # Вывод в Zenity
  zenity --text-info --title "Directory and File Sizes" --width=600 --height=400 --filename=<(echo "$OUTPUT")
}

# Основной блок
if [[ "$INTERFACE" == "gui" ]]; then
  gui_mode
else
  get_directories_and_files
fi

