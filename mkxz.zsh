#!/bin/zsh

# A function to log messages with timestamps
log_msg() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

# The function for minifying a JSON file using the jq tool
minify_json() {
    if jq -c . "$1" >"${1}.min"; then
        log_msg "Minification of $1 completed."
        mv "${1}.min" "$1"
    else
        log_msg "Minification of $1 failed."
        return 1
    fi
}

# The function for optimizing a JSON file, also uses the jq tool
optimize_json() {
    if jq -c '
    reduce .[] as $item ({}; . + $item)
    | with_entries(.value |= { files: [(.files[]? // {})|del(.filename)], total_size: (.files[].size? // 0) | add })
    ' "$1" >"${1}.opt"; then
        log_msg "Optimization of $1 completed."
        mv "${1}.opt" "$1"
    else
        log_msg "Optimization of $1 failed."
        return 1
    fi
}

# The function for creating an archive with customizable parameters
mkxz() {

    local jsonfile="" tempfile=$(mktemp) compression_level='9' create_json_index=true

    # Initialization of arrays of file extensions by type for exclusion from the archive
    local txt_exts=("txt" "doc" "docx" "pdf" "rtf")
    local img_exts=("jpg" "png" "svg" "bmp" "ico" "tiff" "gif")
    local vid_exts=("mp4" "mkv" "flv" "avi" "mov" "wmv")
    local aud_exts=("mp3" "wav" "flac" "aac" "ogg")
    local exclude_extensions=()

    # Loop to process command line flags
    while getopts ":jJ0:1:2:3:4:5:6:7:8:9:t:i:v:s:T:I:V:S:X:x:" flag; do
        case "$flag" in
        j) create_json_index=false ;;
        J)
            shift
            jsonfile=$1
            ;;
        [0-9]) compression_level=$flag ;;
        t) exclude_extensions+=(${txt_exts[@]}) ;;
        i) exclude_extensions+=(${img_exts[@]}) ;;
        v) exclude_extensions+=(${vid_exts[@]}) ;;
        s) exclude_extensions+=(${aud_exts[@]}) ;;
        *)
            log_msg "Unexpected option $flag"
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    if [[ -n "$jsonfile" && -f "$jsonfile" ]]; then
        log_msg "Processing $jsonfile..."
        minify_json "$jsonfile" && optimize_json "$jsonfile"
    fi

    local base_dir=${1:-$(pwd)} archive_output_dir="$HOME/archives"
    mkdir -p "$archive_output_dir"
    local date=$(date +%Y%m%d%H%M%S)
    local archive_name="$(basename "$base_dir")-$date.tar.xz"
    local archive_path="$archive_output_dir/$archive_name"

    local tar_exclusions=("${exclude_extensions[@]/#/--exclude=*}")
    local temp_archive_path=$(mktemp "${TMPDIR:-/tmp/}$(basename "$base_dir").tar.xz.XXXXXX")

    log_msg "Creating archive..."
    if tar -cJf "$temp_archive_path" "${tar_exclusions[@]}" -C "$base_dir" .; then
        log_msg "Archive created successfully: $temp_archive_path"

        # Split the archive into chunks of 512MB each
        local split_size="512m"
        local chunk_prefix="${archive_output_dir}/$(basename "$archive_name" .tar.xz).part-"
        log_msg "Splitting the archive into ${split_size} parts..."
        split -b $split_size -d "$temp_archive_path" "$chunk_prefix"

        # Remove the temporary single large archive file
        rm -f "$temp_archive_path"
        log_msg "Archive split into multiple parts of size ${split_size}."
    else
        log_msg "Failed to create archive."
        return 1
    fi
}
[[ $0 == $ZSH_NAME ]] && mkxz "$@"
