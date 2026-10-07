import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// Wallpaper for one display, drawn on the background layer.
PanelWindow {
    id: root
    required property var modelData
    screen: modelData
    readonly property string path: Wallpapers.pathFor(modelData)

    visible: path !== ""
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "black"
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "quickshell-wallpaper"

    Image {
        anchors.fill: parent
        source: root.path ? "file://" + root.path : ""
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(root.screen.width, root.screen.height)
        asynchronous: true
        cache: false
        smooth: true
    }
}
