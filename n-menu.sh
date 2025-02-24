#!/usr/bin/env bash
set -xe

# Distro check and prep
source <(curl -sSL https://raw.githubusercontent.com/Snake26183/nadeko-installer/refs/heads/main/vars)

function run_nadeko {
    if [[ ! -f nadeko/data/creds.yml ]]; then
        cp nadeko/data/creds_example.yml nadeko/data/creds.yml
    fi

    echo "Attempting to run NadekoBot..."
    nadeko/NadekoBot || return 1
}

function install_nadeko {
    if [ -n "$AUTOMATED" ]; then
        tar_url="https://github.com/nadeko-bot/nadekobot/releases/latest/download/nadeko-linux-x64.tar.gz"
    else
        local version_array=($(echo "$(curl -s https://github.com/nadeko-bot/nadekobot/releases)" | grep -oP '\/tag\/\K(.*?)(?=")' | sort -u))
        local version

        PS3="Please select a version: "
        select bot_version in "${versions[@]}"; do
            if [ -n "$bot_version" ]; then
                echo "You selected version: $bot_version"
                version="$bot_version"
                break
            else
                echo "Invalid selection. Please try again."
            fi
        done

        echo "Downloading '${version}' for '${os}-${arch}'..."
        tar_url="https://github.com/nadeko-bot/nadekobot/releases/download/${version}/nadeko-${os}-${arch}.tar.gz"
    fi

    curl -L "$tar_url" | tar -xzf - || {
        echo "ERROR: Failed to download and extract the archive"
        return 1
    }

    handle_migration

    mv "nadeko-$os-$arch" nadeko

    chmod +x nadeko/NadekoBot
    echo "Installation complete!"
}

function handle_migration {
    if [ ! -d nadeko_backups ]; then
        mkdir nadeko_backups
    fi

    if [ -d nadeko ]; then
        date_now=$(date +%s)
        cp -r nadeko/data "nadeko_backups/$date_now-data"

        return 0
    fi
}

function install_music_deps {
    if [ -n "$AUTOMATED" ]; then
        echo "Running in automated mode, skipping prompts..."
    else
        echo "About to update repositories and run $INSTALL_CMD"
        read -p "Proceed? (y/n): " response </dev/tty
        if [[ "$response" == "n" ]]; then
            exit 0
        fi
    fi

    if command -v dnf; then
        $sudo_cmd dnf update -y
        $sudo_cmd dnf install epel-release
        $sudo_cmd dnf install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm
    fi

    $INSTALL_CMD

    yt_dlp_url=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp

    case "${os}_${arch}" in
    "linux_arm64")
        yt_dlp_url="${yt_dlp_url}_linux__arm64"
        ;;
    "osx_arm64")
        yt_dlp_url="${yt_dlp_url}_macos"
        ;;
    "osx_x64")
        yt_dlp_url="${yt_dlp_url}_macos_legacy"
        ;;
    *)
        yt_dlp_url="${yt_dlp_url}_linux"
        ;;
    esac

    $sudo_cmd curl -L "$yt_dlp_url" -o /usr/bin/yt-dlp
    $sudo_cmd chmod +x /usr/bin/yt-dlp

}

function set_token {
    if [[ ! -f nadeko/data/creds.yml ]]; then
        cp nadeko/data/creds_example.yml nadeko/data/creds.yml
    fi

    # ask the user to input the token
    echo "Please input your token: "
    echo ""
    read -r token </dev/tty

    # check if the token is not empty
    if [[ -z "$token" ]]; then
        echo "ERROR: Invalid token." >&2
        return 1
    fi

    # replace the token in the creds file
    # by finding a line which starts with 'token: ' and replacing it
    sed -i "s/token: .*/token: \"$token\"/" nadeko/data/creds.yml
}

function show_menu {
    echo "Select an option:"
    echo "1) Run NadekoBot"
    echo "2) Install NadekoBot"
    echo "3) Install music dependencies"
    echo "4) Set bot token"
    echo "5) Exit"
}

function execute_choice {
    case $1 in
    1)
        run_nadeko
        ;;
    2)
        install_bot
        ;;
    3)
        install_music_deps
        ;;
    4)
        set_token
        ;;
    5)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice: $1"
        ;;
    esac
}

if [ -z "${AUTOMATED+x}" ]; then
    # Automated mode, var set in Dockerfile
    for arg in "$@"; do
        execute_choice $arg
    done
else
    # Interactive mode
    while true; do
        show_menu
        read -p "Enter your choice: " choice </dev/tty
        execute_choice $choice
        echo
    done
fi
