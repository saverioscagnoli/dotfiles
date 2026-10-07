import QtQuick
import qs
import qs.components

Pill {
    id: root
    hPad: 10
    tooltip: "Screenshot"
    Component.onCompleted: Popups.register("screenshot", root)
    onClicked: Popups.toggle("screenshot", root)
    Icon { text: "󰹑"; color: Popups.current === "screenshot" ? Theme.mauve : Theme.text }
}
