import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

// Panel that drops down under the bar item that opened it.
PanelWindow {
    id: win
    required property string name
    // only the copy on the screen the menu was opened from shows
    readonly property bool open: Popups.current === name && Popups.isOn(screen)
    signal opened()
    property int panelWidth: 340
    property bool needsKeyboard: false
    default property alias content: col.data

    // Full-width strip that never moves; the panel is positioned inside it.
    // (labwc doesn't apply margin changes to an already-mapped layer surface,
    // so moving the window itself left every menu stuck at the far left.)
    anchors { top: true; left: true; right: true }
    margins.top: Theme.barHeight + 4
    // Always mapped; when closed it's transparent and click-through. Showing is
    // then just a fade (re-mapping a keyboard-grabbing layer surface is unreliable).
    onOpenChanged: {
        if (open) { showAnim.restart(); opened() }
        else { showAnim.stop(); bg.opacity = 0 }
    }
    mask: Region { item: win.open ? bg : null }
    implicitHeight: col.implicitHeight + 20
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-popup"
    WlrLayershell.keyboardFocus: !open ? WlrKeyboardFocus.None
                               : needsKeyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand

    Rectangle {
        id: bg
        x: Math.round(Math.max(8, Math.min(Popups.anchorX - win.panelWidth / 2, win.width - win.panelWidth - 8)))
        width: win.panelWidth
        height: parent.height
        radius: 14
        color: Theme.surface
        border.width: 1
        border.color: Theme.overlay
        opacity: 0
        transform: Translate { id: slide }
        ParallelAnimation {
            id: showAnim
            NumberAnimation { target: bg; property: "opacity"; from: 0; to: 1; duration: 80 }
            NumberAnimation { target: slide; property: "y"; from: -4; to: 0; duration: 100; easing.type: Easing.OutCubic }
        }

        focus: true
        Keys.onEscapePressed: Popups.close()

        Column {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
            spacing: 2
        }
    }
}
