import QtQuick
import qs
import qs.components
import qs.services

Pill {
    id: root
    Component.onCompleted: Popups.register("notifications", root)
    onClicked: Popups.toggle("notifications", root)
    Icon {
        text: Notifs.dnd ? "" : ""
        color: Notifs.dnd ? Theme.subtext : Notifs.count > 0 ? Theme.mauve : Theme.text
    }
    Label { visible: Notifs.count > 0; text: Notifs.count; font.pixelSize: 12 }
}
