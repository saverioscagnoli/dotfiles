#!/bin/bash
# filepath: /home/svscagn/dev/skadi/scripts/volume-control

# Get initial volume and output it
get_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%'
}

# Set volume
set_volume() {
    local volume=$1
    # Clamp volume between 0 and 100
    if [ "$volume" -lt 0 ]; then
        volume=0
    elif [ "$volume" -gt 100 ]; then
        volume=100
    fi
    
    pactl set-sink-volume @DEFAULT_SINK@ "${volume}%"
    echo "$volume"
}

# Output initial volume
echo "$(get_volume)"

# Listen for volume changes from PulseAudio
pactl subscribe | grep --line-buffered "Event 'change' on sink" &
PACTL_PID=$!

# Listen for stdin commands and volume events
while true; do
    # Check for stdin input (non-blocking)
    if read -t 0.1 command; then
        if [[ "$command" =~ ^[0-9]+$ ]]; then
            # It's a volume level command
            set_volume "$command"
        elif [ "$command" = "get" ]; then
            # Get current volume
            echo "$(get_volume)"
        elif [ "$command" = "mute" ]; then
            pactl set-sink-mute @DEFAULT_SINK@ toggle
            if pactl get-sink-mute @DEFAULT_SINK@ | grep -q "yes"; then
                echo "muted"
            else
                echo "$(get_volume)"
            fi
        elif [ "$command" = "quit" ]; then
            break
        fi
    fi
    
    # Check for PulseAudio events (non-blocking)
    if kill -0 $PACTL_PID 2>/dev/null; then
        # Output current volume when PA event occurs
        sleep 0.1
        echo "$(get_volume)"
    else
        # pactl subprocess died, restart it
        pactl subscribe | grep --line-buffered "Event 'change' on sink" &
        PACTL_PID=$!
    fi
done

# Cleanup
kill $PACTL_PID 2>/dev/null