import QtQuick
import Quickshell.Services.UPower
import qs
import qs.components

// Battery of a connected mouse (e.g. Logitech via hidpp); hidden when there is none.
Pill {
    id: root
    readonly property var dev: UPower.devices.values.find(d => d.type === UPowerDeviceType.Mouse && d.isPresent) ?? null
    readonly property real pct: dev ? dev.percentage * 100 : 0
    visible: dev !== null
    interactive: false
    tooltip: dev ? dev.model : ""
    Icon { text: "󰍽"; color: root.pct <= 15 ? Theme.red : Theme.text }
    Label { text: Math.round(root.pct) + "%"; color: root.pct <= 15 ? Theme.red : Theme.text }
}
