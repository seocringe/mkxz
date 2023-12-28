#!/bin/zsh

minify_json() {
    jq -c . "$1"
}

optimize_json() {
    jq -c '
    def merge_files:
        reduce .[] as $item ({}; . + $item);
        
    def flat:
        objects or arrays as $item | 
        if $item then reduce $item[] as $i (.; . + $i | flat)
        else . end;
    
    def build_directory_item:
        {( (.filename | split("/"))[0] ):
            { "files": [if .filename then del(.filename) else . end],
              "total_size": (if .size then .size else 0 end)}};
            
    [.[] | build_directory_item] | add | flat
    ' "$1"
}

mkxz() {
    local jsonfile=""
    local tempfile=$(mktemp)
    local compression_level='9'
    local deduplicate_json=true
    local tar_options=("--exclude=*/.*")
    local exclude_extensions=()
    local include_extensions=()
    local include_path=false
    local create_json_index=true

    # Text File Extensions
    local txt_exts=("txt" "doc" "docx" "pdf" "rtf")

    # Image File Extensions
    local img_exts=("jpg" "png" "svg" "bmp" "ico" "tiff" "gif")

    # Video File Extensions
    local vid_exts=("mp4" "mkv" "flv" "avi" "mov" "wmv")

    # Audio File Extensions
    local aud_exts=("mp3" "wav" "flac" "aac" "ogg")

    while getopts ":jJ0:1:2:3:4:5:6:7:8:9:t:i:v:s:T:I:V:S:X:x:" flag; do
        case "$flag" in
        j)
            deduplicate_json=false
            ;;
        J)
            shift
            jsonfile=$1
            ;;
        [0-9])
            compression_level=$flag
            ;;
        t)
            exclude_extensions+=(${txt_exts[@]})
            ;;
        i)
            exclude_extensions+=(${img_exts[@]})
            ;;
        v)
            exclude_extensions+=(${vid_exts[@]})
            ;;
        s)
            exclude_extensions+=(${aud_exts[@]})
            ;;
        T)
            include_extensions+=(${txt_exts[@]})
            ;;
        I)
            include_extensions+=(${img_exts[@]})
            ;;
        V)
            include_extensions+=(${vid_exts[@]})
            ;;
        S)
            include_extensions+=(${aud_exts[@]})
            ;;
        X)
            include_path=true
            ;;
        x)
            include_path=false
            ;;
        *)
            echo "Unexpected option $flag" >&2
            return 1
            ;;
        esac
    done

    shift $((OPTIND - 1))

    # if jsonfile is specified, minify and optimize the json file
    if [[ $deduplicate_json == true && -n "$jsonfile" && -f "$jsonfile" ]]; then
        minify_json "$jsonfile" >"$tempfile"
        optimize_json "$tempfile" >"$jsonfile"
        rm "$tempfile"
    fi

    local base_dir=${1:-$(pwd)}
    if [ ! -d "$base_dir" ]; then
        echo "The specified path is not a directory or does not exist."
        return 1
    fi

    local archive_output_dir="$HOME/archives"
    if [ ! -d "$archive_output_dir" ]; then
        mkdir -p "$archive_output_dir"
    fi

    local date=$(date +%Y%m%d%H%M%S)
    local archive_name="$(basename "$base_dir")-$date.tar.xz"
    local archive_path="$archive_output_dir/$archive_name"

    for ext in "${exclude_extensions[@]}"; do
        tar_options+=("--exclude=*.${ext}")
    done

    if [[ "$include_path" == true ]]; then
        tar_options+=("--absolute-names")
    fi

    (cd "$base_dir" && find . -type f ! -name '.*' -print0 | parallel --null --files tar "${tar_options[@]}" | xz -"${compression_level}" >"$archive_path")

    if [ $? -ne 0 ]; then
        echo "An error occurred while creating or compressing the archive."
        return 1
    fi

    echo "Archive created: $archive_path"

    if [[ "$create_json_index" == true ]]; then
        local index_file="${archive_path}.index.json"

        (cd "$base_dir" && find . -type f ! -name '.*' -printf '{"filename": "%P", "size": %s, "last_modified": "%TY-%Tm-%TdT%TT"}\n' | jq -c 'inputs' | jq -s ${deduplicate_json:+'unique_by(.filename)'} >"$tempfile")

        optimize_json "$tempfile" >"$index_file"
        rm -f "$tempfile"

        if [ ! -s "$index_file" ]; then
            echo "An error occurred while creating the index file."
            return 1
        fi

        echo "Index file created: $index_file"
    fi
}

[[ $0 == $ZSH_NAME ]] && mkxz "$@"
