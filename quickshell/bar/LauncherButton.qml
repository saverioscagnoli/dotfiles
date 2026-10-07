import QtQuick
import qs
import qs.components

Pill {
    id: root
    hPad: 11
    Component.onCompleted: Popups.register("launcher", root)
    onClicked: Popups.toggle("launcher", root)
    Icon { text: "\uf306"; color: "#d70a53"; font.pixelSize: 16 }
}
