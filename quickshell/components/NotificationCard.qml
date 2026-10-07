import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs
import qs.services

// One notification. Click = default action (if any) and dismiss.
Rectangle {
    id: card
    required property var notif
    signal done()          // card should go away (dismissed, or toast closed)
    property bool toast: false
    readonly property bool critical: notif.urgency === NotificationUrgency.Critical
    readonly property var buttons: notif.actions.filter(a => a.identifier !== "default")

    width: parent ? parent.width : 360
    implicitHeight: body.implicitHeight + 20
    radius: 12
    color: hover.hovered ? Theme.overlay : Theme.base
    border.width: 1
    border.color: critical ? Theme.red : Theme.overlay
    Behavior on color { ColorAnimation { duration: 120 } }

    HoverHandler { id: hover }
    // behind the content, so the X and action buttons take their own clicks
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const def = card.notif.actions.find(a => a.identifier === "default")
            if (def) def.invoke()
            if (!card.notif.resident) card.notif.dismiss()
            card.done()
        }
    }

    RowLayout {
        id: body
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
        spacing: 10

        IconImage {
            Layout.alignment: Qt.AlignTop
            implicitSize: 36
            source: Notifs.icon(card.notif)
            visible: status === Image.Ready
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                Label {
                    Layout.fillWidth: true
                    text: card.notif.appName || "Notification"
                    elide: Text.ElideRight
                    font.pixelSize: 11
                    color: Theme.subtext
                }
                Label { text: Notifs.ago(card.notif); font.pixelSize: 11; color: Theme.subtext }
                Rectangle {
                    implicitWidth: 18; implicitHeight: 18; radius: 6
                    color: x.containsMouse ? Theme.surface : "transparent"
                    Icon { anchors.centerIn: parent; text: ""; font.pixelSize: 11; color: x.containsMouse ? Theme.text : Theme.subtext }
                    MouseArea {
                        id: x
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        // on a toast, X just hides it (it stays in the centre)
                        onClicked: { if (!card.toast) card.notif.dismiss(); card.done() }
                    }
                }
            }
            Label {
                Layout.fillWidth: true
                visible: text !== ""
                text: card.notif.summary
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: card.notif.body
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                maximumLineCount: card.toast ? 3 : 6
                elide: Text.ElideRight
                color: Theme.subtext
                linkColor: Theme.mauve
                font.family: Theme.font
                font.pixelSize: 12
                onLinkActivated: link => Qt.openUrlExternally(link)
            }
            Flow {
                Layout.fillWidth: true
                Layout.topMargin: 4
                visible: card.buttons.length > 0
                spacing: 6
                Repeater {
                    model: card.buttons
                    Rectangle {
                        required property var modelData
                        implicitWidth: t.implicitWidth + 20
                        implicitHeight: 26
                        radius: 8
                        color: am.containsMouse ? Theme.mauve : Theme.surface
                        Label { id: t; anchors.centerIn: parent; text: modelData.text; font.pixelSize: 12; color: am.containsMouse ? Theme.base : Theme.text }
                        MouseArea {
                            id: am
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { modelData.invoke(); if (!card.notif.resident) card.notif.dismiss(); card.done() }
                        }
                    }
                }
            }
        }
    }
}
