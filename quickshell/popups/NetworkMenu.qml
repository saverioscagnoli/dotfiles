import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import qs
import qs.components
import qs.services

Dropdown {
    id: menu
    panelWidth: 400
    needsKeyboard: pwFor !== ""
    property string pwFor: ""       // SSID whose password field is open
    property string error: ""

    readonly property var wifiDev: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wiredDevs: Networking.devices.values.filter(d => d.type === DeviceType.Wired)
    readonly property var networks: !wifiDev ? [] : wifiDev.networks.values
        .filter(n => n.name)
        .sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength))

    // scan only while the menu is open
    onOpened: { pwFor = ""; error = ""; NetInfo.refresh() }
    onOpenChanged: if (wifiDev) wifiDev.scannerEnabled = open

    // ---- wired
    Header { title: "Ethernet"; visible: menu.wiredDevs.length > 0 }
    Repeater {
        model: menu.wiredDevs
        MenuItem {
            required property var modelData
            readonly property string addr: NetInfo.addrs[modelData.name] ?? ""
            icon: addr || modelData.connected ? "󰈀" : "󰈂"
            iconColor: addr || modelData.connected ? Theme.green : Theme.subtext
            text: modelData.name
            active: addr !== ""
            sub: (addr ? addr : modelData.hasLink ? "Not connected" : "Cable unplugged")
               + (modelData.nmManaged ? "" : " · managed by ifupdown")
            onClicked: {
                if (!modelData.nmManaged) return
                if (modelData.connected) modelData.disconnect()
                else if (modelData.network) modelData.network.connect()
            }
        }
    }

    Separator { visible: menu.wiredDevs.length > 0 && menu.wifiDev !== null }

    // ---- wifi
    Header {
        visible: menu.wifiDev !== null
        title: "Wi-Fi"
        IconButton { icon: "󰑐"; visible: Networking.wifiEnabled; onClicked: { menu.wifiDev.scannerEnabled = false; menu.wifiDev.scannerEnabled = true } }
        Toggle { checked: Networking.wifiEnabled; onToggled: Networking.wifiEnabled = !Networking.wifiEnabled }
    }

    Label {
        visible: menu.error !== ""
        width: parent.width
        leftPadding: 8; rightPadding: 8; bottomPadding: 6
        wrapMode: Text.Wrap
        text: menu.error
        color: Theme.red
        font.weight: Font.Medium
    }

    Label {
        visible: menu.wifiDev !== null && Networking.wifiEnabled && menu.networks.length === 0
        leftPadding: 12; topPadding: 4; bottomPadding: 8
        text: "Searching for networks…"
        color: Theme.subtext
    }

    Flickable {
        visible: Networking.wifiEnabled
        width: parent.width
        height: Math.min(contentHeight, 440)
        contentHeight: list.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        Column {
            id: list
            width: parent.width
            spacing: 2
            Repeater {
                model: menu.networks
                Column {
                    id: net
                    required property var modelData
                    readonly property bool secured: modelData.security !== WifiSecurityType.Open
                    readonly property bool connecting: modelData.state === ConnectionState.Connecting
                    width: parent.width

                    Connections {
                        target: net.modelData
                        function onConnectionFailed(reason) {
                            menu.error = `Couldn't connect to ${net.modelData.name}: ${ConnectionFailReason.toString(reason)}`
                        }
                    }

                    MenuItem {
                        icon: Utils.wifiGlyph(net.modelData.signalStrength)
                        text: net.modelData.name + (net.secured ? "  󰌾" : "")
                        active: net.modelData.connected
                        sub: net.connecting ? "Connecting…"
                           : net.modelData.connected ? "Connected" + (NetInfo.addrs[menu.wifiDev.name] ? " · " + NetInfo.addrs[menu.wifiDev.name] : "")
                           : net.modelData.known ? "Saved" : ""
                        onClicked: {
                            menu.error = ""
                            if (net.modelData.connected) net.modelData.disconnect()
                            else if (net.modelData.known || !net.secured) net.modelData.connect()
                            else menu.pwFor = menu.pwFor === net.modelData.name ? "" : net.modelData.name
                        }
                        IconButton {
                            visible: net.modelData.known
                            icon: "󰆴"
                            onClicked: net.modelData.forget()
                        }
                    }

                    // password entry
                    Rectangle {
                        visible: menu.pwFor === net.modelData.name
                        width: parent.width
                        height: visible ? 44 : 0
                        color: "transparent"
                        Rectangle {
                            anchors { fill: parent; leftMargin: 8; rightMargin: 8; topMargin: 4; bottomMargin: 4 }
                            radius: 9
                            color: Theme.base
                            border.width: 1
                            border.color: pw.activeFocus ? Theme.mauve : Theme.overlay
                            TextInput {
                                id: pw
                                anchors { fill: parent; leftMargin: 12; rightMargin: 40 }
                                verticalAlignment: TextInput.AlignVCenter
                                echoMode: TextInput.Password
                                color: Theme.text
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize
                                clip: true
                                onVisibleChanged: if (visible) { text = ""; forceActiveFocus() }
                                Keys.onReturnPressed: go()
                                Keys.onEnterPressed: go()
                                Keys.onEscapePressed: menu.pwFor = ""
                                function go() {
                                    if (text.length === 0) return
                                    net.modelData.connectWithPsk(text)
                                    menu.pwFor = ""
                                }
                                Label {
                                    visible: pw.text.length === 0
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Password"
                                    color: Theme.subtext
                                    font.weight: Font.Medium
                                }
                            }
                            IconButton {
                                anchors.right: parent.right
                                anchors.rightMargin: 4
                                anchors.verticalCenter: parent.verticalCenter
                                icon: "󰁔"
                                iconColor: Theme.mauve
                                onClicked: pw.go()
                            }
                        }
                    }
                }
            }
        }
    }

    Separator {}
    MenuItem {
        icon: "󰒓"
        iconColor: Theme.subtext
        text: "Edit connections"
        onClicked: { Quickshell.execDetached(["foot", "-T", "nmtui", "nmtui"]); Popups.close() }
    }
}
