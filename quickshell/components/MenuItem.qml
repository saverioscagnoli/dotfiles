import QtQuick
import QtQuick.Layouts
import qs

// One clickable row in a dropdown.
Rectangle {
    id: it
    property string icon: ""
    property color iconColor: Theme.text
    property color activeIconColor: Theme.mauve
    property string text: ""
    property string sub: ""
    property color subColor: Theme.subtext
    property bool active: false
    property bool dim: false
    default property alias trailing: right.data
    signal clicked()

    width: parent ? parent.width : 300
    implicitHeight: sub !== "" ? 46 : 38
    radius: 10
    color: ma.containsMouse ? Theme.overlay : active ? Qt.alpha(Theme.mauve, 0.14) : "transparent"
    Behavior on color { ColorAnimation { duration: 100 } }

    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: it.clicked() }

    Icon {
        id: ic
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 20
        text: it.icon
        color: it.active ? it.activeIconColor : it.iconColor
        opacity: it.dim ? 0.6 : 1
    }
    Column {
        anchors.left: ic.right
        anchors.leftMargin: 12
        anchors.right: right.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1
        Label {
            width: parent.width
            text: it.text
            elide: Text.ElideRight
            font.weight: it.active ? Font.Bold : Font.Medium
            color: it.dim ? Theme.subtext : Theme.text
        }
        Label {
            width: parent.width
            visible: it.sub !== ""
            text: it.sub
            elide: Text.ElideRight
            font.pixelSize: 11
            font.weight: Font.Medium
            color: it.subColor
        }
    }
    RowLayout {
        id: right
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2
    }
}
