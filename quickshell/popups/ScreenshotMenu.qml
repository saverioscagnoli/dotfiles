import QtQuick
import Quickshell
import qs
import qs.components

// Full screen (the output the menu was opened on) or drag-select a portion.
// The work is done by ~/.local/bin/screenshot (grim + slurp + wl-copy).
Dropdown {
    id: menu
    panelWidth: 240

    Header { title: "Screenshot" }

    MenuItem {
        icon: "󰍹"
        iconColor: Theme.blue
        text: "Full screen"
        onClicked: {
            const out = Popups.screen ? Popups.screen.name : ""
            Popups.close()
            Quickshell.execDetached(["sh", "-c", "\"$HOME/.local/bin/screenshot\" full \"$1\"", "sh", out])
        }
    }
    MenuItem {
        icon: "󰩭"
        iconColor: Theme.mauve
        text: "Portion"
        sub: "Drag to select · Esc cancels"
        onClicked: {
            Popups.close()
            Quickshell.execDetached(["sh", "-c", "\"$HOME/.local/bin/screenshot\" area"])
        }
    }
}
