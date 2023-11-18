#!/bin/bash

# Run Flameshot and save the screenshot with Flameshot's default naming
flameshot gui -c -p $HOME/Pictures/Screenshots --raw

# Get the latest file in the specified directory
latest_file=$(ls -t $HOME/Pictures/Screenshots | head -n1)

# Rename the latest file with the custom naming style (same as GNOME's screen shot application)
timestamp=$(date +"%Y-%m-%d %H-%M-%S")
new_filename="Screenshot from $timestamp.png"
mv "$HOME/Pictures/Screenshots/$latest_file" "$HOME/Pictures/Screenshots/$new_filename"
