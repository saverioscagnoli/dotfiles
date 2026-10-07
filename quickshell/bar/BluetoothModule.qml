import QtQuick
import Quickshell.Bluetooth
import QtQuick.Layouts
import qs
import qs.components

Pill {
    id: root
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: adapter ? adapter.enabled : false
    readonly property var connected: adapter ? adapter.devices.values.filter(d => d.connected) : []
    readonly property var first: connected.length > 0 ? connected[0] : null

    visible: adapter !== null
    tooltip: !on ? "Bluetooth off"
           : connected.length === 0 ? "No devices connected"
           : connected.map(d => d.name + (d.batteryAvailable ? `  ${Math.round(d.battery * 100)}%` : "")).join("\n")
    Component.onCompleted: Popups.register("bluetooth", root)
    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) { if (adapter) adapter.enabled = !adapter.enabled }
        else Popups.toggle("bluetooth", root)
    }

    Icon {
        text: !root.on ? "󰂲" : root.first ? "󰂱" : "󰂯"
        color: root.on ? Theme.text : Theme.subtext
    }
    Label {
        visible: root.first !== null
        color: Theme.text
        text: root.first ? root.first.name + (root.first.batteryAvailable ? `  ${Math.round(root.first.battery * 100)}%` : "") : ""
        elide: Text.ElideRight
        Layout.maximumWidth: 180
    }
}
