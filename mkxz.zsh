#!/bin/zsh

mkxz() {
    declare -a image_extensions=("jpg" "jpeg" "png" "gif" "tiff" "bmp" "svg" "webp" "ico" "raw" "indd" "ai" "eps" "pdf")
    declare -a video_extensions=("webm" "mkv" "flv" "vob" "ogv" "ogg" "drc" "gifv" "mng" "avi" "mts" "m2ts" "ts" "mov" "qt" "wmv" "yuv" "rm" "rmvb" "asf" "amv" "mp4" "m4p" "m4v" "mpg" "mp2" "mpeg" "mpe" "mpv" "m2v" "svi" "3gp" "3g2" "mxf" "roq" "nsv" "flv" "f4v" "f4p" "f4a" "f4b")
    declare -a audio_extensions=("3gp" "aa" "aac" "aax" "act" "aiff" "alac" "amr" "ape" "au" "awb" "dct" "dss" "dvf" "flac" "gsm" "iklax" "ivs" "m4a" "m4b" "m4p" "mmf" "mp3" "mpc" "msv" "nmf" "ogg" "oga" "mogg" "opus" "spx" "ra" "rm" "raw" "tta" "wav" "webm" "8svx")
    declare -a text_extensions=("txt" "csv" "xml" "json" "yml" "yaml" "md" "htm" "html" "php" "js" "py" "c" "cpp" "java" "pl" "rb" "swift" "go" "kt" "rs" "ts" "tsx" "jsx")

    only_text=0
    only_images=0
    only_videos=0
    only_sounds=0
    exclude_all=0
    preserve_path=false
    flatten_dir=false
    numeric_compression='9'

    declare -A ALLOWED_FLAGS=(
        ["-t"]=only_text
        ["-i"]=only_images
        ["-v"]=only_videos
        ["-s"]=only_sounds
        ["-T"]=exclude_all
        ["-I"]=exclude_all
        ["-V"]=exclude_all
        ["-S"]=exclude_all
        ["-X"]=preserve_path
        ["-x"]=preserve_path
        ["-f"]=flatten_dir
        ["-F"]=flatten_dir
    )

    while getopts "tivsTIVSXxVFf:0:1:2:3:4:5:6:7:8:9" flag; do
        if [[ -v ALLOWED_FLAGS[$flag] ]]; then
            declare ${ALLOWED_FLAGS[$flag]}=1
        elif [[ $flag =~ [0-9] ]]; then
            numeric_compression=$flag
        else
            echo "Unexpected option $flag"
            exit 1
        fi
    done

    shift $((OPTIND - 1))

    tar_options=()
    include_tar_option_for_extension_type() {
        local -n extensions=$1
        local flag=$2
        if (( flag )); then
            for extension in ${extensions[@]}; do
                tar_options+=("--exclude=*.${extension}")
            done
        fi
    }

    if (( only_text )); then
        tar_options+=("--exclude=*")
        include_tar_option_for_extension_type text_extensions 0
    elif (( only_images )); then
        tar_options+=("--exclude=*")
        include_tar_option_for_extension_type image_extensions 0
    elif (( only_videos )); then
        tar_options+=("--exclude=*")
        include_tar_option_for_extension_type video_extensions 0
    elif (( only_sounds )); then
        tar_options+=("--exclude=*")
        include_tar_option_for_extension_type audio_extensions 0
    elif (( exclude_all )); then
        include_tar_option_for_extension_type text_extensions 1
        include_tar_option_for_extension_type image_extensions 1
        include_tar_option_for_extension_type video_extensions 1
        include_tar_option_for_extension_type audio_extensions 1
    fi

    if (( preserve_path )); then
        tar_options+=("--absolute-names")
    fi

    archive_func() {
        local base_dir=$(pwd)
        local temp_dir=$(mktemp -d)
        local date=$(date +%d-%m-%Y-%H-%M-%S)
        local archive_name="$(basename "$PWD")-$date.tar.xz"

        local _tar_options=("${tar_options[@]}")

        if (( flatten_dir )); then
            _tar_options+=("--transform=s|.*/\(.*\)|\1|")    
            cp -rf "${base_dir}/." "${temp_dir}"
        fi

        tar --use-compress-program="xz -${numeric_compression}" -cf "${base_dir}/${archive_name}" -C "${temp_dir}" . ${_tar_options[@]} >&2

        echo "Archive created: $PWD/$archive_name" >&2
        rm -rf "$t" && echo "Temporary directory removed: $temp_dir" >&2
        echo "$archive_name"
    }

    archive_func "$@"
}

[[ $0 == $ZSH_NAME ]] && mkxz "$@"
