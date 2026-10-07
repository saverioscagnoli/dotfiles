import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import qs
import qs.components
import qs.services

Pill {
    id: root
    readonly property var wifiDev: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wifiNet: wifiDev ? (wifiDev.networks.values.find(n => n.connected) ?? null) : null
    readonly property bool lan: NetInfo.wiredUp

    readonly property string glyph: wifiNet ? Utils.wifiGlyph(wifiNet.signalStrength) : lan ? "󰈀" : "󰤮"
    readonly property string label: wifiNet ? wifiNet.name : lan ? "LAN" : "offline"
    readonly property color accent: wifiNet || lan ? Theme.text : Theme.subtext

    tooltip: {
        const lines = []
        if (wifiNet) lines.push(`${wifiNet.name} (${Math.round(wifiNet.signalStrength * 100)}%)\n${wifiDev.name}: ${NetInfo.addrs[wifiDev.name] ?? "no address"}`)
        if (lan) lines.push(`${NetInfo.wiredIf}: ${NetInfo.addrs[NetInfo.wiredIf]}`)
        return lines.length ? lines.join("\n") : "Disconnected"
    }
    Component.onCompleted: Popups.register("network", root)
    onClicked: Popups.toggle("network", root)

    Icon { text: root.glyph; color: root.accent }
    Label { text: root.label; color: root.accent; elide: Text.ElideRight; Layout.maximumWidth: 160 }
}
