#!/bin/bash

# Define the list of script names
scripts=("backup-update-master.sh" "backup-ba-up-ma.sh" "config-ba-up-ma.sh" "cron-ba-up-ma.sh" "update-ba-up-ma.sh" "utils-ba-up-ma.sh")

# Define the base URL for the Gist raw files
base_url="https://raw.githubusercontent.com/hhftechnology/pangolin-backup-update/refs/heads/main"

# Download each script
for script in "${scripts[@]}"; do
  curl -o "$script" "$base_url/$script"
done

# Make all .sh files executable
chmod +x *.sh

# Run the master script
./backup-update-master.sh