import QtQuick
import Quickshell.Services.UPower
import qs
import qs.components

Dropdown {
    id: menu
    panelWidth: 320
    readonly property var dev: UPower.displayDevice

    Header { title: "Power profile" }

    Repeater {
        model: [
            { p: PowerProfile.Performance, icon: "󰓅", name: "Performance", color: Theme.red },
            { p: PowerProfile.Balanced, icon: "󰾅", name: "Balanced", color: Theme.mauve },
            { p: PowerProfile.PowerSaver, icon: "󰾆", name: "Power saver", color: Theme.green },
        ]
        MenuItem {
            required property var modelData
            visible: modelData.p !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile
            icon: modelData.icon
            iconColor: modelData.color
            activeIconColor: modelData.color
            text: modelData.name
            active: PowerProfiles.profile === modelData.p
            onClicked: PowerProfiles.profile = modelData.p
        }
    }

    Separator {}

    Column {
        width: parent.width
        leftPadding: 12
        bottomPadding: 4
        spacing: 4
        Label {
            color: Theme.subtext
            font.weight: Font.Medium
            text: {
                const d = menu.dev
                if (!d) return ""
                const state = UPowerDeviceState.toString(d.state)
                let s = `Battery ${Math.round(d.percentage * 100)}% · ${state}`
                if (UPower.onBattery && d.timeToEmpty > 0) s += ` · ${Utils.duration(d.timeToEmpty)} left`
                if (d.state === UPowerDeviceState.Charging && d.timeToFull > 0) s += ` · full in ${Utils.duration(d.timeToFull)}`
                return s
            }
        }
        Label {
            color: Theme.subtext
            font.weight: Font.Medium
            visible: text !== ""
            text: {
                const d = menu.dev
                if (!d) return ""
                const parts = []
                if (d.changeRate > 0) parts.push(`${d.changeRate.toFixed(1)} W`)
                if (d.healthSupported) parts.push(`health ${Math.round(d.healthPercentage)}%`)
                return parts.join(" · ")
            }
        }
    }
}
