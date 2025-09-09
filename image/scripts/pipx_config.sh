#!/bin/bash
pipx ensurepath

# Run all Python scripts in the python directory
for script in /image/scripts/python/*; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        echo "Running $script..."
        bash "$script"
    fi
done
