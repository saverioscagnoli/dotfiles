import QtQuick
import Quickshell
import qs
import qs.components

Pill {
    id: root
    SystemClock { id: clock; precision: SystemClock.Minutes }
    Component.onCompleted: Popups.register("calendar", root)
    onClicked: Popups.toggle("calendar", root)
    Label { text: Qt.formatDateTime(clock.date, "ddd dd MMM   HH:mm") }
}
