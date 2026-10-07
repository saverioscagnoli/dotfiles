import QtQuick
import Quickshell.Services.UPower
import qs
import qs.components

// Battery + power profile. Click battery = profile menu; click profile icon = cycle.
Pill {
    id: root
    readonly property var dev: UPower.displayDevice
    readonly property real pct: dev ? dev.percentage * 100 : 0
    readonly property bool charging: dev && dev.state === UPowerDeviceState.Charging
    readonly property bool discharging: UPower.onBattery
    readonly property bool critical: discharging && pct <= 10
    readonly property bool warning: discharging && pct <= 25
    readonly property color accent: critical ? Theme.red : Theme.text
    property bool blink: false

    readonly property var profiles: [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
    readonly property int profile: PowerProfiles.profile

    visible: dev && dev.isLaptopBattery
    tooltip: (charging ? "Charging" : discharging ? "On battery" : "Plugged in")
           + (discharging && dev.timeToEmpty > 0 ? ` · ${Utils.duration(dev.timeToEmpty)} left` : "")
           + (charging && dev.timeToFull > 0 ? ` · full in ${Utils.duration(dev.timeToFull)}` : "")
           + (dev && dev.changeRate > 0 ? `\n${dev.changeRate.toFixed(1)} W` : "")
           + `\nPower profile: ${PowerProfile.toString(profile)}`
    Component.onCompleted: Popups.register("power-profile", root)
    onClicked: Popups.toggle("power-profile", root)

    Timer { running: root.critical; repeat: true; interval: 500; onTriggered: root.blink = !root.blink; onRunningChanged: if (!running) root.blink = false }

    Icon {
        text: root.charging ? "󰂄" : !root.discharging ? "󰚥" : Utils.batteryGlyph(root.pct)
        color: root.blink ? Theme.text : root.accent
    }
    Label { text: Math.round(root.pct) + "%"; color: root.blink ? Theme.text : root.accent }

    Icon {
        id: prof
        text: root.profile === PowerProfile.Performance ? "󰓅" : root.profile === PowerProfile.PowerSaver ? "󰾆" : "󰾅"
        color: Theme.text
        leftPadding: 4
        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => {
                const n = root.profiles.length
                let i = root.profiles.indexOf(root.profile)
                do {
                    i = (i + (mouse.button === Qt.RightButton ? n - 1 : 1)) % n
                } while (root.profiles[i] === PowerProfile.Performance && !PowerProfiles.hasPerformanceProfile)
                PowerProfiles.profile = root.profiles[i]
            }
        }
    }
}
