import QtQuick
import qs

Rectangle {
    id: b
    property string icon
    property color iconColor: Theme.subtext
    property string tip: ""
    signal clicked()
    implicitWidth: 28
    implicitHeight: 28
    radius: 8
    color: ma.containsMouse ? Theme.overlay : "transparent"
    Icon { anchors.centerIn: parent; text: b.icon; color: ma.containsMouse ? Theme.text : b.iconColor }
    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: b.clicked() }
}
