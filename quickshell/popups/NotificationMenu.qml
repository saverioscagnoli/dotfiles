import QtQuick
import QtQuick.Layouts
import qs
import qs.components
import qs.services

// Notification centre: history, Do Not Disturb, clear all.
Dropdown {
    id: menu
    panelWidth: 400

    Header {
        title: "Notifications"
        Label { text: "Do not disturb"; font.pixelSize: 12; color: Theme.subtext }
        Toggle { checked: Notifs.dnd; onToggled: Notifs.dnd = !Notifs.dnd }
        IconButton { icon: ""; visible: Notifs.count > 0; onClicked: Notifs.clearAll() }
    }

    Item { width: 1; height: 4 }

    ListView {
        id: list
        width: parent.width
        height: Math.min(contentHeight, 520)
        visible: Notifs.count > 0
        clip: true
        spacing: 6
        boundsBehavior: Flickable.StopAtBounds
        model: Notifs.list
        delegate: NotificationCard {
            required property var modelData
            notif: modelData
            width: list.width
        }
    }

    Column {
        visible: Notifs.count === 0
        width: parent.width
        topPadding: 18
        bottomPadding: 18
        spacing: 6
        Icon { anchors.horizontalCenter: parent.horizontalCenter; text: Notifs.dnd ? "" : ""; font.pixelSize: 26; color: Theme.overlay }
        Label { anchors.horizontalCenter: parent.horizontalCenter; text: "No notifications"; color: Theme.subtext }
    }
}
