import QtQuick
import Quickshell
import qs

PopupWindow {
    id: tip
    required property Item target
    property string text: ""
    property bool armed: false

    Timer { running: true; interval: 600; onTriggered: tip.armed = true }

    visible: armed && Popups.current === ""
    anchor.item: target
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    implicitWidth: lbl.implicitWidth + 22
    implicitHeight: lbl.implicitHeight + 14 + 6
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 6
        radius: 8
        color: Theme.surface
        border.width: 1
        border.color: Theme.overlay
        Label {
            id: lbl
            anchors.centerIn: parent
            text: tip.text
            font.weight: Font.Medium
            lineHeight: 1.15
        }
    }
}
