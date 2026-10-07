import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs
import qs.components

Dropdown {
    id: menu
    property bool input: false
    panelWidth: 380

    readonly property var node: input ? Pipewire.defaultAudioSource : Pipewire.defaultAudioSink
    readonly property var audio: node ? node.audio : null
    readonly property var devices: Pipewire.nodes.values
        .filter(n => n.audio && !n.isStream && n.isSink === !input)
        .sort((a, b) => (a.description || a.name).localeCompare(b.description || b.name))

    PwObjectTracker { objects: [menu.node] }

    Header {
        title: menu.input ? "Input" : "Output"
        IconButton {
            icon: menu.audio && menu.audio.muted ? (menu.input ? "󰍭" : "󰝟") : (menu.input ? "󰍬" : "󰕾")
            iconColor: menu.audio && menu.audio.muted ? Theme.red : Theme.subtext
            onClicked: if (menu.audio) menu.audio.muted = !menu.audio.muted
        }
    }

    Item {
        width: parent.width
        implicitHeight: 36
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12
            Slider {
                Layout.fillWidth: true
                value: menu.audio ? menu.audio.volume / (menu.input ? 1 : 1.5) : 0
                fill: Theme.mauve
                onMoved: v => { if (menu.audio) menu.audio.volume = v * (menu.input ? 1 : 1.5) }
            }
            Label {
                Layout.preferredWidth: 40
                horizontalAlignment: Text.AlignRight
                text: menu.audio ? Math.round(menu.audio.volume * 100) + "%" : ""
                color: Theme.subtext
            }
        }
    }

    Separator {}

    Repeater {
        model: menu.devices
        MenuItem {
            required property var modelData
            icon: menu.input ? "󰍬" : modelData.description.indexOf("HDMI") >= 0 ? "󰡁"
                : /bluez/.test(modelData.name) ? "󰋋" : "󰓃"
            // "Renoir/Cezanne HDMI/DP Audio Controller HDMI / DisplayPort 3 Output" -> "HDMI / DisplayPort 3 Output"
            text: (modelData.description || modelData.name).replace(/^.* (HDMI \/ DisplayPort)/, "$1")
            active: menu.node && modelData.id === menu.node.id
            onClicked: {
                if (menu.input) Pipewire.preferredDefaultAudioSource = modelData
                else Pipewire.preferredDefaultAudioSink = modelData
            }
        }
    }
}
