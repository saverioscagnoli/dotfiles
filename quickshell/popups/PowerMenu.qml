import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.components

// Lock (if swaylock is installed), suspend, log out, reboot, shut down.
// Destructive actions ask for a second click.
Dropdown {
    id: menu
    panelWidth: 240
    property string confirm: ""
    property bool hasLock: false
    onOpened: confirm = ""

    Process {
        running: true
        command: ["sh", "-c", "command -v swaylock"]
        onExited: code => menu.hasLock = code === 0
    }

    Repeater {
        model: [
            { id: "lock", icon: "󰌾", name: "Lock", cmd: ["swaylock", "-f", "-c", "252525"], ask: false },
            { id: "suspend", icon: "󰤄", name: "Suspend", cmd: ["systemctl", "suspend"], ask: false },
            { id: "logout", icon: "󰍃", name: "Log out", cmd: ["labwc", "--exit"], ask: true },
            { id: "reboot", icon: "󰜉", name: "Reboot", cmd: ["systemctl", "reboot"], ask: true },
            { id: "poweroff", icon: "󰐥", name: "Shut down", cmd: ["systemctl", "poweroff"], ask: true },
        ]
        MenuItem {
            required property var modelData
            visible: modelData.id !== "lock" || menu.hasLock
            icon: modelData.icon
            iconColor: menu.confirm === modelData.id ? Theme.red : Theme.text
            text: menu.confirm === modelData.id ? `Click again to ${modelData.name.toLowerCase()}` : modelData.name
            onClicked: {
                if (modelData.ask && menu.confirm !== modelData.id) { menu.confirm = modelData.id; return }
                Popups.close()
                Quickshell.execDetached(modelData.cmd)
            }
        }
    }
}
