import QtQuick
import qs
import qs.components

Pill {
    id: root
    hPad: 10
    Component.onCompleted: Popups.register("wallpaper", root)
    onClicked: Popups.toggle("wallpaper", root)
    Icon { text: ""; color: Popups.current === "wallpaper" ? Theme.mauve : Theme.text }
}
