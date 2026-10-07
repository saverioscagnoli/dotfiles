import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

// Rounded bar module. Children are laid out in a row.
Rectangle {
    id: root
    default property alias content: row.data
    property alias spacing: row.spacing
    property real hPad: 12
    property bool interactive: true
    property string tooltip: ""
    readonly property bool hovered: hover.hovered
    readonly property var screenInfo: QsWindow.window ? QsWindow.window.screen : null

    signal clicked(var mouse)
    signal scrolled(int direction)   // +1 = up, -1 = down

    implicitWidth: row.implicitWidth + hPad * 2
    implicitHeight: Theme.pillHeight
    Layout.alignment: Qt.AlignVCenter
    radius: 10
    color: interactive && hovered ? Theme.overlay : Theme.surface
    border.width: 1
    border.color: Qt.alpha(Theme.overlay, 0.7)
    Behavior on color { ColorAnimation { duration: 150 } }

    HoverHandler {
        id: hover
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => root.clicked(mouse)
    }

    WheelHandler {
        property real acc: 0
        onWheel: event => {
            acc += event.angleDelta.y
            while (acc >= 120) { acc -= 120; root.scrolled(1) }
            while (acc <= -120) { acc += 120; root.scrolled(-1) }
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6
    }

    LazyLoader {
        active: root.hovered && root.tooltip !== ""
        Tooltip { target: root; text: root.tooltip }
    }
}
