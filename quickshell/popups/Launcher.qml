import QtQuick
import Quickshell
import Quickshell.Widgets
import qs
import qs.components

// App launcher: type to filter, arrows to move, Enter to start.
Dropdown {
    id: menu
    panelWidth: 440
    needsKeyboard: true
    property int selected: 0
    onOpened: { search.text = ""; selected = 0; search.forceActiveFocus() }

    readonly property var apps: {
        const q = search.text.trim().toLowerCase()
        const all = DesktopEntries.applications.values.filter(a => !a.noDisplay)
        const hit = a => !q || [a.name, a.genericName, a.comment, ...(a.keywords || [])]
            .some(s => s && s.toLowerCase().includes(q))
        return all.filter(hit).sort((a, b) => {
            if (q) {   // names starting with the query first
                const sa = a.name.toLowerCase().startsWith(q), sb = b.name.toLowerCase().startsWith(q)
                if (sa !== sb) return sb - sa
            }
            return a.name.localeCompare(b.name)
        })
    }
    onAppsChanged: selected = 0

    function launch(app) {
        if (!app) return
        Popups.close()
        app.execute()
    }

    Rectangle {
        width: parent.width
        height: 42
        radius: 10
        color: Theme.base
        border.width: 1
        border.color: Theme.mauve
        Icon { id: mag; anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: "󰍉"; color: Theme.subtext }
        TextInput {
            id: search
            anchors { left: mag.right; right: parent.right; leftMargin: 10; rightMargin: 12; verticalCenter: parent.verticalCenter }
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 14
            focus: true
            Keys.onEscapePressed: Popups.close()
            Keys.onDownPressed: menu.selected = Math.min(menu.selected + 1, menu.apps.length - 1)
            Keys.onUpPressed: menu.selected = Math.max(menu.selected - 1, 0)
            Keys.onTabPressed: menu.selected = Math.min(menu.selected + 1, menu.apps.length - 1)
            Keys.onReturnPressed: menu.launch(menu.apps[menu.selected])
            Keys.onEnterPressed: menu.launch(menu.apps[menu.selected])
            Label {
                visible: search.text.length === 0
                anchors.verticalCenter: parent.verticalCenter
                text: "Search apps…"
                color: Theme.subtext
                font.pixelSize: 14
                font.weight: Font.Medium
            }
        }
    }

    Item { width: 1; height: 6 }

    ListView {
        id: list
        width: parent.width
        height: Math.min(contentHeight, 9 * 42)
        clip: true
        model: menu.apps
        currentIndex: menu.selected
        boundsBehavior: Flickable.StopAtBounds
        highlightMoveDuration: 0
        delegate: Rectangle {
            id: row
            required property var modelData
            required property int index
            width: list.width
            height: 42
            radius: 10
            color: index === menu.selected ? Qt.alpha(Theme.mauve, 0.18) : "transparent"
            IconImage {
                id: ic
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                implicitSize: 24
                source: Utils.appIcon(row.modelData.icon || row.modelData.id)
            }
            Column {
                anchors { left: ic.right; leftMargin: 12; right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                Label { width: parent.width; text: row.modelData.name; elide: Text.ElideRight; font.weight: Font.Medium }
                Label {
                    width: parent.width
                    visible: text !== ""
                    text: row.modelData.genericName || row.modelData.comment || ""
                    elide: Text.ElideRight
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: Theme.subtext
                }
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: menu.selected = row.index
                onClicked: menu.launch(row.modelData)
            }
        }
    }
}
