#!/bin/bash

CURRENT=$(powerprofilesctl get)

case $CURRENT in
    "power-saver") DISPLAY="⚡ Save" ;;
    "balanced") DISPLAY="⚖ Bal" ;;
    "performance") DISPLAY="🚀 Perf" ;;
    *) DISPLAY="? $CURRENT" ;;
esac

echo "$DISPLAY"

if [ ! -z "$BLOCK_BUTTON" ]; then
    case $BLOCK_BUTTON in
        1) 
            case $CURRENT in
                "power-saver") powerprofilesctl set balanced ;;
                "balanced") powerprofilesctl set performance ;;
                "performance") powerprofilesctl set power-saver ;;
            esac
            ;;
        3) 
            case $CURRENT in
                "power-saver") powerprofilesctl set performance ;;
                "balanced") powerprofilesctl set power-saver ;;
                "performance") powerprofilesctl set balanced ;;
            esac
            ;;
    esac
fi
