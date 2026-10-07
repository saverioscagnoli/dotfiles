import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs

PanelWindow {
    id: bar
    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-bar"

    Item {
        anchors { fill: parent; topMargin: 10; bottomMargin: 4; leftMargin: 12; rightMargin: 12 }

        RowLayout {
            anchors.left: parent.left
            height: parent.height
            spacing: Theme.gap
            LauncherButton {}
            ScreenshotButton {}
            WallpaperButton {}
            Workspaces {}
            Taskbar {}
        }

        ClockModule { anchors.centerIn: parent }

        RowLayout {
            anchors.right: parent.right
            height: parent.height
            spacing: Theme.gap
            Tray {}
            Volume {}
            Volume { input: true }
            BluetoothModule {}
            NetworkModule {}
            BrightnessModule {}
            BatteryModule {}
            NotificationButton {}
            PowerButton {}
        }
    }
}
