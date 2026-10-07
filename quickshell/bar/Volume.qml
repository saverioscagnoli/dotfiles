import QtQuick
import Quickshell.Services.Pipewire
import qs
import qs.components

// Output (or input with input: true). Click = devices, right = mute, scroll = volume.
Pill {
    id: root
    property bool input: false
    readonly property var node: input ? Pipewire.defaultAudioSource : Pipewire.defaultAudioSink
    readonly property var audio: node ? node.audio : null
    readonly property real vol: audio ? audio.volume : 0
    readonly property bool muted: audio ? audio.muted : false
    readonly property string menuName: input ? "audio-in" : "audio-out"
    readonly property color accent: muted ? Theme.subtext : Theme.text

    visible: node !== null
    tooltip: (node ? node.description : "") + (input ? "\nclick: switch input · right-click: mute" : "\nclick: switch output · right-click: mute")
    Component.onCompleted: Popups.register(menuName, root)

    PwObjectTracker { objects: [root.node] }

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) { if (audio) audio.muted = !audio.muted }
        else Popups.toggle(menuName, root)
    }
    onScrolled: dir => {
        if (!audio) return
        audio.volume = Math.max(0, Math.min(input ? 1.0 : 1.5, Math.round((vol + dir * 0.05) * 100) / 100))
    }

    Icon {
        color: root.accent
        text: root.input ? (root.muted ? "󰍭" : "󰍬")
                         : root.muted ? "󰝟" : root.vol < 0.34 ? "󰕿" : root.vol < 0.67 ? "󰖀" : "󰕾"
    }
    Label {
        color: root.accent
        visible: !(root.input && root.muted)
        text: root.muted ? "muted" : Math.round(root.vol * 100) + "%"
    }
}
