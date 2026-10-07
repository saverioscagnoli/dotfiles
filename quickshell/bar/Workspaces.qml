import QtQuick
import Quickshell.WindowManager
import qs
import qs.components

// labwc workspaces: click to switch, scroll to move left/right.
Pill {
    id: root
    hPad: 5
    spacing: 3
    interactive: false
    readonly property var sets: WindowManager.windowsets.filter(w => w.shouldDisplay)
    visible: sets.length > 0

    onScrolled: dir => {
        const n = sets.length
        const i = sets.findIndex(s => s.active)
        sets[((i < 0 ? 0 : i) - dir + n) % n].activate()
    }

    Repeater {
        model: root.sets
        Rectangle {
            id: ws
            required property var modelData
            required property int index
            implicitWidth: 18
            implicitHeight: 16
            radius: 6
            color: modelData.active ? Theme.mauve : ma.containsMouse ? Theme.overlay : "transparent"
            Behavior on color { ColorAnimation { duration: 150 } }
            Label {
                anchors.centerIn: parent
                text: ws.index + 1
                color: ws.modelData.active ? Theme.base
                     : ws.modelData.urgent ? Theme.red
                     : ma.containsMouse ? Theme.text : Theme.subtext
            }
            MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: ws.modelData.activate() }
        }
    }
}
