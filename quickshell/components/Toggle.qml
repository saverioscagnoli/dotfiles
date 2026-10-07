import QtQuick
import qs

Rectangle {
    id: t
    property bool checked: false
    signal toggled()
    implicitWidth: 38
    implicitHeight: 22
    radius: 11
    color: checked ? Theme.mauve : Theme.overlay
    Behavior on color { ColorAnimation { duration: 150 } }
    Rectangle {
        width: 16; height: 16; radius: 8
        y: 3
        x: t.checked ? t.width - width - 3 : 3
        color: t.checked ? Theme.base : Theme.text
        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: t.toggled() }
}
