#!/bin/zsh

# Объявление функции для минификации JSON файла с использованием инструмента jq
minify_json() {
    jq -c . "$1" # 'jq -c .' компактифицирует JSON, удаляя лишние пробелы и символы перевода строки
}

# Объявление функции для оптимизации JSON файла, также использует инструмент jq
optimize_json() {
    # 'reduce' аккумулирует результат, 'with_entries' используется для преобразования объекта,
    # '|=' изменяет значение поля, 'del' удаляет указанные поля из объекта
    jq -c '
    reduce .[] as $item ({}; . + $item)
    | with_entries(.value |= { files: [(.files[]? // {})|del(.filename)], total_size: (.files[].size? // 0) | add })
    ' "$1"
}

# Объявление функции для создания архива с возможностью настройки параметров
mkxz() {
    # Объявление локальных переменных для настройки скрипта
    local jsonfile="" tempfile=$(mktemp) compression_level='9' create_json_index=true
    
    # Инициализация массивов расширений по типам файлов для исключения из архива
    local txt_exts=("txt" "doc" "docx" "pdf" "rtf") img_exts=("jpg" "png" "svg" "bmp" "ico" "tiff" "gif")
    local vid_exts=("mp4" "mkv" "flv" "avi" "mov" "wmv") aud_exts=("mp3" "wav" "flac" "aac" "ogg")
    local exclude_extensions=()
    
    # Цикл обработки флагов командной строки
    while getopts ":jJ0:1:2:3:4:5:6:7:8:9:t:i:v:s:T:I:V:S:X:x:" flag; do
        # Определение действий для каждого флага
        case "$flag" in
            j) create_json_index=false ;;
            J) shift; jsonfile=$1 ;;
            [0-9]) compression_level=$flag ;;
            t) exclude_extensions+=(${txt_exts[@]}) ;;
            i) exclude_extensions+=(${img_exts[@]}) ;;
            v) exclude_extensions+=(${vid_exts[@]}) ;;
            s) exclude_extensions+=(${aud_exts[@]}) ;;
            *) echo "Unexpected option $flag" >&2; return 1 ;; # Сообщение об ошибке при неожиданном флаге
        esac
    done
    shift $((OPTIND - 1))
    
    # Если указан JSON файл и он существует, применяем функции минификации и оптимизации
    if [[ -n "$jsonfile" && -f "$jsonfile" ]]; then
        minify_json "$jsonfile" >"$tempfile" && mv "$tempfile" "$jsonfile"
        optimize_json "$jsonfile" >"$tempfile" && mv "$tempfile" "$jsonfile"
    fi
    
    # Настройка путей для создания архива
    local base_dir=${1:-$(pwd)} archive_output_dir="$HOME/archives"
    mkdir -p "$archive_output_dir"
    local date=$(date +%Y%m%d%H%M%S)
    local archive_name="$(basename "$base_dir")-$date.tar.xz"
    local archive_path="$archive_output_dir/$archive_name"
    
    # Подготовка паттернов исключения для tar
    local tar_exclusions=("${exclude_extensions[@]/#/--exclude=*}")
    
    # Создание архива с помощью tar и вывод сообщения об успехе
    tar -cJf "$archive_path" "${tar_exclusions[@]}" "$base_dir" && echo "Archive created: $archive_path"
}

# Условие для запуска функции в качестве основного скрипта
[[ $0 == $ZSH_NAME ]] && mkxz "$@"
