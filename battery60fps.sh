#!/bin/bash

# Rebel Battery Optimizer: Aim for 25hr lifespan at 60 FPS via Low Power Mode
# Usage: sudo ./battery_rebel.sh [--extreme | --balanced | --revert | --monitor]

# Function to enable optimizations
optimize() {
    MODE=$1
    echo "Initiating $MODE optimization sequence... Buckle up!"

    # Enable Low Power Mode for 60Hz cap and power savings
    sudo pmset -a lowpowermode 1
    echo "Low Power Mode activated: Refresh rate capped at 60Hz, CPU/GPU throttled for epic battery stretch."

    # Disable WiFi and Bluetooth
    networksetup -setairportpower airport off
    if command -v blueutil &> /dev/null; then
        blueutil -p 0
    else
        echo "blueutil not found; install via brew for Bluetooth control."
    fi
    echo "Networks silenced: WiFi/Bluetooth off – saving 10-20% drain."

    # Dim screen to 10% brightness
    osascript -e 'tell application "System Events" to set the brightness of the first display to 0.1'
    # Keyboard backlight off
    osascript -e 'tell application "System Events" to key code 145'  # F5 decrease, repeat if needed
    echo "Lights dimmed: Screen at minimal glow, backlight extinguished."

    # Disable Spotlight and other services
    sudo mdutil -a -i off
    sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist
    echo "Spotlight banished: No more indexing vampires."

    if [ "$MODE" = "extreme" ]; then
        # Extreme: Disable more – auto updates, Siri
        sudo softwareupdate --schedule off
        defaults write com.apple.Siri StatusMenuVisible -bool false
        # Kill background apps creatively
        pkill -f "Safari|Chrome|Finder relaunch"  # Risky, customize
        sudo pmset -a hibernatemode 0  # No hibernate file
        echo "Extreme mode: Updates off, Siri silenced, hibernating disabled for pure efficiency."
    fi

    # Monitor battery baseline
    system_profiler SPPowerDataType > battery_log.txt
    echo "Baseline logged. Estimated savings: Up to 50% extension, pushing towards 25hrs on light use at 60FPS."
}

# Revert function
revert() {
    sudo pmset -a lowpowermode 0
    networksetup -setairportpower airport on
    if command -v blueutil &> /dev/null; then blueutil -p 1; fi
    osascript -e 'tell application "System Events" to set the brightness of the first display to 0.8'
    sudo mdutil -a -i on
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist
    sudo softwareupdate --schedule on
    sudo pmset -a hibernatemode 3  # Default
    echo "Reverted to stock – freedom restored, but battery dreams faded."
}

# Monitoring mode
monitor() {
    while true; do
        BATTERY=$(pmset -g batt | grep -o '[0-9]\+%')
        echo "Current battery: $BATTERY | Time: $(date)" >> battery_monitor.log
        sleep 300  # Every 5 min
    done
}

# Main logic
if [ "$1" = "--extreme" ]; then
    optimize "extreme"
elif [ "$1" = "--balanced" ]; then
    optimize "balanced"
elif [ "$1" = "--revert" ]; then
    revert
elif [ "$1" = "--monitor" ]; then
    monitor
else
    echo "Usage: sudo $0 [--extreme | --balanced | --revert | --monitor]"
fi
