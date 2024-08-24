#!/bin/bash

###### CHATGPT AMENDMENTS ######

target="/var/www/html/mirrors/archlinux"
lock="/var/lock/syncrepo-archlinux.lck"
min_space=100000  # Minimum space in MB (100 GB)
tmp="/tmp/rsync_tmp"

# Array of rsync URLs for Arch Linux mirrors
declare -a mirror_rsync_urls=(
    #'rsync://archlinux.za.mirror.allworldit.com/archlinux/'
    'rsync://archlinux.mirror.liquidtelecom.com/archlinux/'
    'rsync://mirror.23m.com/archlinux/'
)

if [ ! -d "${target}" ]; then
    mkdir -p "${target}" || { logger -t archlinux_mirror "Failed to create target directory ${target}"; exit 1; }
fi

if [ ! -d "${tmp}" ]; then
    mkdir -p "${tmp}" || { logger -t archlinux_mirror "Failed to create temporary directory ${tmp}"; exit 1; }
fi

exec 9>"${lock}"
flock -n 9 || { logger -t archlinux_mirror "Failed to acquire lock"; exit 1; }

# Function to check available disk space
check_space() {
    local mount_point
    mount_point=$(df --output=target "$target" | awk 'NR==2 {print $1}')
    local space_available
    space_available=$(df --block-size=1M "$mount_point" | awk 'NR==2 {print $4}')

    if [ "$space_available" -lt "$min_space" ]; then
        echo "--delete-after"
    else
        echo "--ignore-existing --size-only"
    fi
}

# Function to construct rsync command
rsync_cmd() {
    local additional_option
    additional_option=$(check_space)

    local -a cmd=(rsync -rlH --safe-links --timeout=600 --contimeout=60 --delay-updates --no-motd --bwlimit=5000 $additional_option --temp-dir="$tmp")

    if stty &>/dev/null; then
        cmd+=(-h -v --progress)
    else
        cmd+=(--quiet)
    fi

    "${cmd[@]}" "$@"
}

logger -t archlinux_mirror "Starting mirror synchronization"

for url in "${mirror_rsync_urls[@]}"; do
    logger -t archlinux_mirror "Syncing from $url"
    if rsync_cmd "${url}" "${target}"; then
        logger -t archlinux_mirror "Successfully synced from $url"
        break
    else
        logger -t archlinux_mirror "rsync command failed for $url"
    fi
done

date -u +'%s' > "${target}/lastsync"

# Set ownership and permissions
if chown -R www-data:www-data /var/www/html/mirrors && chmod -R 750 /var/www/html/mirrors && chmod g+s /var/www/html/mirrors; then
    logger -t archlinux_mirror "Ownership and permissions set successfully"
else
    logger -t archlinux_mirror "Failed to set ownership and permissions"
fi

# Clean up temporary directory
if rm -rf "${tmp}"/*; then
    logger -t archlinux_mirror "Temporary directory cleaned up successfully"
else
    logger -t archlinux_mirror "Failed to clean up temporary directory"
fi