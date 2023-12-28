#!/bin/zsh

mkxz() {
    local compression_level='9'
    local deduplicate_json=true
    local tar_options=("--exclude=*/.*")
    local exclude_extensions=()
    local include_extensions=()
    local flat_storage=false
    local replace_duplicates=false
    local include_path=false
    local create_json_index=true
    local usage_hierarchy=false

    # Text File Extensions
    local txt_exts=("txt" "doc" "docx" "pdf" "rtf")

    # Image File Extensions
    local img_exts=("jpg" "png" "svg" "bmp" "ico" "tiff" "gif")

    # Video File Extensions
    local vid_exts=("mp4" "mkv" "flv" "avi" "mov" "wmv")

    # Audio File Extensions
    local aud_exts=("mp3" "wav" "flac" "aac" "ogg")

    while getopts ":J0:1:2:3:4:5:6:7:8:9:t:i:v:s:T:I:V:S:X:x:fFj" flag; do
        case "$flag" in
        J)
            deduplicate_json=true
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
        f)
            flat_storage=true
            replace_duplicates=false
            ;;
        F)
            flat_storage=false
            replace_duplicates=true
            ;;
        j)
            create_json_index=true
            ;;
        *)
            echo "Unexpected option $flag" >&2
            return 1
            ;;
        esac
    done

    shift $((OPTIND - 1))
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

    (cd "$base_dir" && find . -type f ! -name '.*' -print0 | tar cvpf - "${tar_options[@]}" --null -T- | xz -"${compression_level}" >"$archive_path")

    if [ $? -ne 0 ]; then
        echo "An error occurred while creating or compressing the archive."
        return 1
    fi

    echo "Archive created: $archive_path"

    if [[ "$create_json_index" == true ]]; then
        local index_file="${archive_path}.index.json"

        (cd "$base_dir" && find . -type f ! -name '.*' -printf '{"filename": "%P", "size": %s, "last_modified": "%TY-%Tm-%TdT%TT", "owner": "%u"}\n' | jq -s ${deduplicate_json:+'unique_by(.filename)'} >"$index_file")

        if [ $? -ne 0 ]; then
            echo "An error occurred while creating the index file."
            return 1
        fi

        echo "Index file created: $index_file"
    fi
}

[[ $0 == $ZSH_NAME ]] && mkxz "$@"
