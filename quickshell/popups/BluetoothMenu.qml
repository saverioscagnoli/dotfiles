import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs
import qs.components
import qs.services

Dropdown {
    id: menu
    panelWidth: 380
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: adapter ? adapter.enabled : false
    property string error: ""
    onOpened: { error = ""; BtHelper.error = "" }

    readonly property var devices: !adapter ? [] : adapter.devices.values
        .filter(d => d.name && d.name !== d.address.replace(/:/g, "-"))
        .sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))

    Header {
        title: "Bluetooth"
        Toggle { checked: menu.on; onToggled: if (menu.adapter) menu.adapter.enabled = !menu.adapter.enabled }
    }

    Label {
        visible: (menu.error || BtHelper.error) !== ""
        width: parent.width
        leftPadding: 8; rightPadding: 8; bottomPadding: 6
        wrapMode: Text.Wrap
        text: menu.error || BtHelper.error
        color: Theme.red
        font.weight: Font.Medium
    }

    MenuItem {
        visible: menu.on
        icon: menu.adapter && menu.adapter.discovering ? "󰂰" : "󰑐"
        iconColor: Theme.mauve
        text: menu.adapter && menu.adapter.discovering ? "Scanning…" : "Scan for devices"
        onClicked: {
            menu.error = ""
            if (menu.adapter.discovering) menu.adapter.discovering = false
            else BtHelper.scan()
        }
    }

    Separator { visible: menu.on && menu.devices.length > 0 }

    Flickable {
        visible: menu.on
        width: parent.width
        height: Math.min(contentHeight, 420)
        contentHeight: list.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        Column {
            id: list
            width: parent.width
            spacing: 2
            Repeater {
                model: menu.devices
                MenuItem {
                    id: row
                    required property var modelData
                    readonly property bool busy: modelData.state === BluetoothDeviceState.Connecting
                                               || modelData.state === BluetoothDeviceState.Disconnecting
                                               || modelData.pairing || BtHelper.pairing === modelData.address
                    property int lastState: modelData.state

                    icon: Utils.btGlyph(modelData.icon)
                    text: modelData.name
                    active: modelData.connected
                    dim: !modelData.paired && !busy
                    sub: BtHelper.pairing === modelData.address ? "Pairing…"
                       : modelData.state === BluetoothDeviceState.Connecting ? "Connecting…"
                       : modelData.state === BluetoothDeviceState.Disconnecting ? "Disconnecting…"
                       : modelData.connected ? "Connected" + (modelData.batteryAvailable ? ` · ${Math.round(modelData.battery * 100)}%` : "")
                       : modelData.paired ? "Paired" : "New device — click to pair"

                    Connections {
                        target: row.modelData
                        function onStateChanged() {
                            if (row.lastState === BluetoothDeviceState.Connecting
                                && row.modelData.state === BluetoothDeviceState.Disconnected)
                                menu.error = `Couldn't connect to ${row.modelData.name}.`
                            row.lastState = row.modelData.state
                        }
                    }

                    onClicked: {
                        menu.error = ""; BtHelper.error = ""
                        if (busy) return
                        if (modelData.connected) modelData.disconnect()
                        else if (modelData.paired) { modelData.trusted = true; modelData.connect() }
                        else BtHelper.pairAndConnect(modelData)
                    }

                    IconButton {
                        visible: row.modelData.paired
                        icon: "󰆴"
                        onClicked: row.modelData.forget()
                    }
                }
            }
        }
    }
}
