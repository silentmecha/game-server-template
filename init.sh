#!/bin/bash

# Default values
app_id=""
image_base=""
current_dir=$(pwd)
update_dir=""

# Function to display help
show_help() {
    echo "Usage: $0 [-i steam_app_id] [-b image_base] [-h]"
    echo ""
    echo "Options:"
    echo "  -i  Specify the Steam app ID"
    echo "  -b  Override the image base (optional)"
    echo "  -u  Update existing image to new guidelines (optional)"
    echo "  -h  Show this help message"
}

# Parse command-line options
while getopts "i:b:u:h" opt; do
    case ${opt} in
    i ) app_id=$OPTARG ;;
    b ) image_base=$OPTARG ;;
    u ) update_dir=$OPTARG ;;
    h )
        show_help
        exit 0
        ;;
    * )
        echo "Invalid option: -${OPTARG}."
        exit 1
        ;;
    esac
done

if [ -z "$app_id" ]; then
    echo "Please specify the Steam app ID."
    show_help
    exit 1
fi

GAME_NAME=""              # Game name using SteamCMD API
GAME_NAME_PASCAL_CASE=""  # Converted $GAME_NAME to PascalCase
GAME_SERVER_IMAGE_NAME="" # Converted $GAME_NAME to kebab-case and appended "-server"
IMAGE_BASE=""             # Image base for the game server

function tools_check() {
    if ! command -v jq &>/dev/null; then
        echo "jq could not be found. Please install jq to continue."
        exit
    fi
}

function convert_to_pascal_case() {
    local input="$1"
    # Remove special characters (keep letters and numbers only), replace with spaces
    input=$(echo "$input" | sed 's/[^a-zA-Z0-9]/ /g')

    # Capitalize the first letter of each word and make the rest lowercase
    input=$(echo "$input" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')

    # Remove spaces to form Pascal case
    echo "$input" | tr -d ' '
}

function convert_to_kebab_case() {
    local input="$1"
    # Replace non-alphanumeric characters with hyphens
    input=$(echo "$input" | sed 's/[^a-zA-Z0-9]/-/g')

    # Replace multiple consecutive hyphens with a single hyphen
    input=$(echo "$input" | sed 's/--*/-/g')

    # Convert the whole string to lowercase
    input=$(echo "$input" | tr '[:upper:]' '[:lower:]')

    # Remove leading/trailing hyphens (if any)
    input=$(echo "$input" | sed 's/^-*//;s/-*$//')

    echo "$input"
}

function check_linux_depot() {
    local json_data=$1
    if echo "$json_data" | jq -e '.data[].common.oslist | contains("linux")' > /dev/null; then
        echo "steamcmd"
    else
        echo "steamcmd-wine"
    fi
}

function define_variables() {
    local game_server_info=$(curl -s -X GET "https://api.steamcmd.net/v1/info/$app_id" | jq .)
    local parent_app_id=$(echo $game_server_info | jq -r '.data | to_entries | .[].value.common.parent')
    local server_parent_info=$(curl -s -X GET "https://api.steamcmd.net/v1/info/$parent_app_id" | jq .)
    # Set game name from $server_parent_info
    GAME_NAME=$(echo $server_parent_info | jq -r '.data | to_entries | .[].value.common.name')
    if [ -z "$GAME_NAME" ] || [ "$GAME_NAME" == "null" ]; then
        local game_server_info_steamapi=$(curl -s -X GET https://store.steampowered.com/api/appdetails?appids=$parent_app_id | jq .)
        GAME_NAME=$(echo $game_server_info_steamapi | jq -r ".\"$parent_app_id\".data.name")
        if [ -z "$GAME_NAME" ] || [ "$GAME_NAME" == "null" ]; then
            echo "Game name could not be found. Please check the Steam app ID."
            exit 1
        fi
    fi
    # Set game name in PascalCase
    GAME_NAME_PASCAL_CASE=$(convert_to_pascal_case "$GAME_NAME")
    # Set game server image name in kebab-case
    GAME_SERVER_IMAGE_NAME=$(convert_to_kebab_case "$GAME_NAME")"-server"
    # Set image base
    if [ -z "$image_base" ]; then
        IMAGE_BASE=$(check_linux_depot "$game_server_info") # Check if $game_server_info has a Linux depot and set the image base accordingly
    else
        IMAGE_BASE=$image_base
    fi
    echo "Game name: $GAME_NAME"
    echo "Game server image name: $GAME_SERVER_IMAGE_NAME"
    echo "Image base: $IMAGE_BASE"
    echo "Game Install DIR: $GAME_NAME_PASCAL_CASE"
}

function replace_placeholders() {
    # List of files to replace variables
    local files_to_replace="Dockerfile docker-compose.yml base.Dockerfile README.md"

    cd "$current_dir/../$GAME_SERVER_IMAGE_NAME"
    for file in $files_to_replace; do
        sed -i "s/{{GAME_APP_ID}}/$app_id/g" $file
        sed -i "s/{{GAME_NAME}}/$GAME_NAME/g" $file
        sed -i "s/{{GAME_NAME_PASCAL_CASE}}/$GAME_NAME_PASCAL_CASE/g" $file
        sed -i "s/{{GAME_SERVER_IMAGE_NAME}}/$GAME_SERVER_IMAGE_NAME/g" $file
        sed -i "s/{{IMAGE_BASE}}/$IMAGE_BASE/g" $file
    done
}

function update_existing_server_image_directory() {
    local source_dir="$current_dir/../$update_dir"
    local destination_dir="$current_dir/../$GAME_SERVER_IMAGE_NAME"

    if [ "$source_dir" != "$destination_dir" ]; then
        cp -r "$source_dir" "$destination_dir"
    fi
    replace_placeholders
}

function create_server_image_directory() {
    mkdir -p "$current_dir/../$GAME_SERVER_IMAGE_NAME"
    # Copy files from template directory and replace variables, including `.` files
    cp -r "$current_dir/template/"* "$current_dir/../$GAME_SERVER_IMAGE_NAME"
    cp -r "$current_dir/template/."* "$current_dir/../$GAME_SERVER_IMAGE_NAME"
    replace_placeholders
}

function main() {
    tools_check
    define_variables
    if [ -z "$update_dir" ]; then
        create_server_image_directory
    else
        update_existing_server_image_directory
    fi
}

main "$@"