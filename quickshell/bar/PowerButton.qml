import QtQuick
import qs
import qs.components

Pill {
    id: root
    Component.onCompleted: Popups.register("power", root)
    onClicked: Popups.toggle("power", root)
    Icon { text: "⏻"; color: Theme.text }
}
