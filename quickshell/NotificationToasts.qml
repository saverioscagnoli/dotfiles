import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs
import qs.components
import qs.services

// New notifications, top-right of the external monitor (or the laptop screen
// when it's the only one). They hide on their own
// (critical ones stay until clicked) but remain in the notification centre.
PanelWindow {
    id: win
    screen: Quickshell.screens.find(s => !s.name.startsWith("eDP")) ?? Quickshell.screens[0]
    visible: Notifs.popups.length > 0
    anchors { top: true; right: true }
    margins { top: Theme.barHeight + 4; right: 8 }
    implicitWidth: 380
    implicitHeight: col.implicitHeight
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"
    mask: Region { item: col }

    Column {
        id: col
        width: parent.width
        spacing: 6
        Repeater {
            model: Notifs.popups
            NotificationCard {
                id: card
                required property var modelData
                notif: modelData
                toast: true
                color: hovered ? Theme.overlay : Theme.surface
                readonly property bool hovered: hh.hovered
                HoverHandler { id: hh }
                onDone: Notifs.hidePopup(modelData)
                Timer {
                    // pause while the mouse is over it
                    running: !card.critical && !card.hovered
                    interval: card.notif.expireTimeout > 0 ? Math.min(card.notif.expireTimeout, 15000) : 6000
                    onTriggered: Notifs.hidePopup(card.modelData)
                }
            }
        }
    }
}
