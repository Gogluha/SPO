#!/bin/bash

# Проверяем введенные параметры
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <N directories> <K files>"
  exit 1
fi

N=$1  # Кол-во директорий
K=$2  # Кол-во файлов

# Получаем топ N директорий по размеру
echo "Top $N directories by size:"
du -ah --max-depth=1 | sort -rh | head -n $N | while read -r size dir; do
  echo "Directory: $dir, Size: $size"

  # Суммарный размер файлов 
  total_size=$(du -s "$dir" | awk '{print $1}')
  echo "Total size of directory: $(du -sh "$dir" | cut -f1)"

  # Находим топ K файлов по размеру в каждой директории
  echo "Top $K files in $dir:"
  find "$dir" -type f -exec du -ah {} + | sort -rh | head -n $K | awk '{print $2, "-", $1}'
  echo
done

