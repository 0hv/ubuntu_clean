#!/bin/bash

# Constants
readonly TMP_DIR="/tmp"
readonly VAR_TMP_DIR="/var/tmp" 
readonly APT_CACHE_DIR="/var/cache/apt/archives"
readonly THUMBNAILS_DIR="$HOME/.cache/thumbnails"
readonly BLEACHBIT_PRESET="--preset"

# Functions
calculate_disk_usage() {
    df -h / | grep -Eo '[0-9]+G' | head -1
}

update_packages() {
    sudo apt update
}

remove_unnecessary_packages() {
    sudo apt autoremove -y
    sudo apt autoclean -y 
    sudo apt-get clean -y
}

remove_old_kernels() {
    dpkg -l linux-* | awk '/^ii/{print $2}' | egrep [0-9] | sort -t- -k3,4 --version-sort -r | sed -e "1,/$(uname -r | cut -f1,2 -d"-")/d" | grep -v -e `uname -r | cut -f1,2 -d"-"` | xargs sudo apt-get -y purge
}

remove_temporary_files() {
    sudo rm -rf "$TMP_DIR"/*
    sudo rm -rf "$VAR_TMP_DIR"/*
}

remove_apt_cache() {
    sudo rm -rf "$APT_CACHE_DIR"/*
}

remove_thumbnails() {
    rm -rf "$THUMBNAILS_DIR"/*
}

install_bleachbit() {
    sudo apt install -y bleachbit
}

clean_with_bleachbit() {
    sudo bleachbit --clean "$BLEACHBIT_PRESET"
}

configure_automatic_cleanup() {
    gsettings set org.gnome.desktop.privacy remove-old-temp-files true
    gsettings set org.gnome.desktop.privacy remove-old-trash-files true
}

display_final_report() {
    echo "Cleanup completed."
    echo "Initial disk usage: $1" 
    echo "Final disk usage: $2"
    echo "Space saved: ${3}G"
}

# Main function
main() {
    # Disk usage before cleanup
    initial_disk_usage=$(calculate_disk_usage)
    
    # Update package list
    update_packages
    
    # Remove unnecessary packages
    remove_unnecessary_packages
    
    # Remove old kernels
    remove_old_kernels
    
    # Remove temporary files
    remove_temporary_files
    
    # Remove APT cache
    remove_apt_cache
    
    # Remove thumbnails 
    remove_thumbnails
    
    # Install and use BleachBit for deep cleaning
    install_bleachbit
    clean_with_bleachbit
    
    # Configure automatic removal of temporary files and trash
    configure_automatic_cleanup
    
    # Disk usage after cleanup
    final_disk_usage=$(calculate_disk_usage)
    
    # Calculate space saved
    initial_disk_usage_bytes=$(echo $initial_disk_usage | grep -Eo '[0-9]+') 
    final_disk_usage_bytes=$(echo $final_disk_usage | grep -Eo '[0-9]+')
    space_saved=$((initial_disk_usage_bytes - final_disk_usage_bytes))
    
    # Display final report
    display_final_report "$initial_disk_usage" "$final_disk_usage" "$space_saved"
}

# Call the main function
main
