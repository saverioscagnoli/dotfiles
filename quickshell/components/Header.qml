import QtQuick
import QtQuick.Layouts
import qs

// Section title with optional controls on the right.
Item {
    id: h
    property string title
    default property alias trailing: right.data
    width: parent ? parent.width : 300
    implicitHeight: 34
    Label {
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        text: h.title
        font.pixelSize: 14
        font.weight: Font.Bold
    }
    RowLayout {
        id: right
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
    }
}
