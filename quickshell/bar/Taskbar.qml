import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.WindowManager
import qs
import qs.components

// Open windows on the current workspace: click = focus, middle = close,
// right = minimise/restore.
// labwc doesn't tell clients which workspace a window is on, so each window
// is tagged with the workspace that was active when it opened or was last
// focused. Windows that were already open when the shell started show on
// every workspace until they're focused once.
Pill {
    id: root
    hPad: 4
    spacing: 2
    interactive: false
    readonly property var currentWs: WindowManager.windowsets.find(w => w.active) ?? null
    property bool started: false   // false while the initial window list loads
    visible: implicitWidth > hPad * 2   // hidden when no window is on this workspace
    Timer { interval: 1500; running: true; onTriggered: root.started = true }

    Repeater {
        model: ToplevelManager.toplevels
        Rectangle {
            id: btn
            required property var modelData
            property string ws: ""   // workspace name, "" = unknown
            readonly property bool onCurrent: ws === "" || !root.currentWs || ws === root.currentWs.name
            visible: onCurrent
            Component.onCompleted: {
                if (root.started || modelData.activated) tag()
            }
            function tag() { if (root.currentWs) ws = root.currentWs.name }
            // wait a moment so a workspace switch that focuses this window lands first
            Timer { id: tagLater; interval: 120; onTriggered: if (btn.modelData.activated) btn.tag() }
            Connections {
                target: btn.modelData
                function onActivatedChanged() { if (btn.modelData.activated) tagLater.restart() }
            }
            implicitWidth: 30
            implicitHeight: 20
            radius: 7
            color: modelData.activated ? Qt.alpha(Theme.mauve, 0.3) : ma.containsMouse ? Theme.overlay : "transparent"
            opacity: modelData.minimized ? 0.5 : 1
            Behavior on color { ColorAnimation { duration: 150 } }

            IconImage {
                anchors.centerIn: parent
                implicitSize: 18
                source: Utils.appIcon(btn.modelData.appId)
            }
            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.MiddleButton) btn.modelData.close()
                    else if (mouse.button === Qt.RightButton) btn.modelData.minimized = !btn.modelData.minimized
                    else btn.modelData.activate()
                }
            }
            LazyLoader {
                active: ma.containsMouse
                Tooltip { target: btn; text: btn.modelData.title }
            }
        }
    }
}
