#!/bin/zsh

# Функция для минификации JSON файла, используя утилиту jq
minify_json() {
    jq -c . "$1"
}

# Функция для оптимизации JSON файла, удаляя дубликаты и считая общий размер
optimize_json() {
    jq -c 'reduce .[] as $item ({}; . + $item) | map_values({files: [.[] | del(.filename)], total_size: (add | if . == 0 then empty else . end)})' "$1"
}

# Функция для создания сжатого tar.xz архива, с опциями для работы с JSON файлами и исключениями расширений файлов
mkxz() {
    # Объявление локальных переменных
    local jsonfile="" tempfile=$(mktemp) compression_level='9' deduplicate_json=true tar_options=("--exclude=*/.*") exclude_extensions=() include_extensions=() include_path=false create_json_index=true
    # Массивы с расширениями файлов для исключения
    local txt_exts=("txt" "doc" "docx" "pdf" "rtf") img_exts=("jpg" "png" "svg" "bmp" "ico" "tiff" "gif") vid_exts=("mp4" "mkv" "flv" "avi" "mov" "wmv") aud_exts=("mp3" "wav" "flac" "aac" "ogg")
    
    # Обработка аргументов командной строки
    while getopts ":jJ0:1:2:3:4:5:6:7:8:9:t:i:v:s:T:I:V:S:X:x:" flag; do
        case "$flag" in
            j) deduplicate_json=false ;;
            J) shift; jsonfile=$1 ;;
            [0-9]) compression_level=$flag ;;
            t) exclude_extensions+=(${txt_exts[@]}) ;;
            i) exclude_extensions+=(${img_exts[@]}) ;;
            v) exclude_extensions+=(${vid_exts[@]}) ;;
            s) exclude_extensions+=(${aud_exts[@]}) ;;
            T) include_extensions+=(${txt_exts[@]}) ;;
            I) include_extensions+=(${img_exts[@]}) ;;
            V) include_extensions+=(${vid_exts[@]}) ;;
            S) include_extensions+=(${aud_exts[@]}) ;;
            X) include_path=true ;;
            x) include_path=false ;;
            *) echo "Unexpected option $flag" >&2; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))
    
    # Если включена оптимизация JSON и файл существует, то оптимизируем его
    if [[ $deduplicate_json == true && -n "$jsonfile" && -f "$jsonfile" ]]; then
        minify_json "$jsonfile" > "$tempfile"
        optimize_json "$tempfile" > "$jsonfile"
        rm "$tempfile"
    fi
    
    # Подготовка к созданию архива
    local base_dir=${1:-$(pwd)} archive_output_dir="$HOME/archives"
    mkdir -p "$archive_output_dir"
    local date=$(date +%Y%m%d%H%M%S)
    local archive_name="$(basename "$base_dir")-$date"
    local complex_archive_path="$archive_output_dir/$archive_name.tar.xz"
    local simple_archive_path="$archive_output_dir/$archive_name.simple.tar.xz"
    
    # Создание архива с использованием tar
    tar -cJf "$simple_archive_path" --exclude=*/.* "$base_dir" &
    wait
    echo "Complex Archive created: $complex_archive_path"
    echo "Simple Archive created: $simple_archive_path"
}

# Если скрипт вызван напрямую, то запускаем функцию mkxz с аргументами командной строки
[[ $0 == $ZSH_NAME ]] && mkxz "$@"