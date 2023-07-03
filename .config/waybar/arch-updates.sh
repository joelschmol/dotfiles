#!/bin/bash

# Waybar Module for Arch Linux packages to update

# Check if pacman is installed
if ! command -v pacman &>/dev/null; then
  echo "Error: pacman is not installed."
  exit 1
fi

# Check if pacman-contrib is installed
if ! command -v checkupdates &>/dev/null; then
  echo "Error: pacman-contrib is not installed."
  exit 1
fi

# Get list of packages to update
package_list=$(checkupdates)

# Count number of packages to update
package_count=$(checkupdates | wc -l)

# Set Waybar icon and tooltip
if [ "$package_count" -gt 0 ]; then
  icon=" $package_count"
  tooltip=$(echo "$package_list" | head -n 20 | sed -z 's/\n/\\n/g')
fi

# Output JSON for Waybar
echo "{ \"text\": \"$icon\", \"tooltip\": \"$tooltip\" }"
