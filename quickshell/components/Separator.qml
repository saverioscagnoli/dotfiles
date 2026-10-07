import QtQuick
import qs

Item {
    width: parent ? parent.width : 300
    implicitHeight: 9
    Rectangle { anchors.centerIn: parent; width: parent.width - 12; height: 1; color: Theme.overlay }
}
