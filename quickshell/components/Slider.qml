import QtQuick
import qs

Item {
    id: s
    property real value: 0          // 0..1
    property color fill: Theme.mauve
    property bool knob: true
    readonly property bool dragging: area.pressed
    signal moved(real value)

    implicitWidth: 160
    implicitHeight: 18

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: 3
        color: Theme.overlay
        Rectangle {
            width: Math.max(parent.height, parent.width * Math.min(1, s.value))
            height: parent.height
            radius: 3
            color: s.fill
        }
    }
    Rectangle {
        visible: s.knob
        width: 14; height: 14; radius: 7
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(s.width - width, s.width * Math.min(1, s.value) - width / 2))
        color: Theme.text
    }
    MouseArea {
        id: area
        anchors.fill: parent
        anchors.margins: -4
        preventStealing: true
        cursorShape: Qt.PointingHandCursor
        function update(x) { s.moved(Math.max(0, Math.min(1, (x - 4) / s.width))) }
        onPressed: mouse => update(mouse.x)
        onPositionChanged: mouse => { if (pressed) update(mouse.x) }
    }
}
