import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

// Invisible full-screen layer: clicking anywhere outside a dropdown closes it.
PanelWindow {
    required property var forScreen
    screen: forScreen
    visible: Popups.current !== "" && Popups.isOn(forScreen)
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-catcher"
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onPressed: Popups.close()
    }
}
