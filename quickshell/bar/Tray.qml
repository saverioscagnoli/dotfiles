import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs
import qs.components

Pill {
    id: root
    hPad: 8
    spacing: 8
    interactive: false
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items
        Item {
            id: ti
            required property var modelData
            implicitWidth: 18
            implicitHeight: 18
            IconImage { anchors.fill: parent; source: ti.modelData.icon }
            QsMenuAnchor {
                id: menu
                menu: ti.modelData.menu
                anchor.item: ti
                anchor.edges: Edges.Bottom
                anchor.gravity: Edges.Bottom
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (mouse.button === Qt.MiddleButton) ti.modelData.secondaryActivate()
                    else if (mouse.button === Qt.RightButton || ti.modelData.onlyMenu) { if (ti.modelData.hasMenu) menu.open() }
                    else ti.modelData.activate()
                }
            }
        }
    }
}
