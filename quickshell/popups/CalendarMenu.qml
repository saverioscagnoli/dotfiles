import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.components

Dropdown {
    id: menu
    panelWidth: 300
    property date today: new Date()
    property int year: today.getFullYear()
    property int month: today.getMonth()
    onOpened: { today = new Date(); year = today.getFullYear(); month = today.getMonth() }

    function shift(d) {
        let m = month + d, y = year
        while (m < 0) { m += 12; y-- }
        while (m > 11) { m -= 12; y++ }
        month = m; year = y
    }

    // Monday-first grid of 42 days
    readonly property var days: {
        const first = new Date(year, month, 1)
        const offset = (first.getDay() + 6) % 7
        const out = []
        for (let i = 0; i < 42; i++) out.push(new Date(year, month, 1 - offset + i))
        return out
    }

    Header {
        title: Qt.locale().standaloneMonthName(menu.month) + " " + menu.year
        IconButton { icon: "󰅁"; onClicked: menu.shift(-1) }
        IconButton { icon: "󰃭"; onClicked: { menu.year = menu.today.getFullYear(); menu.month = menu.today.getMonth() } }
        IconButton { icon: "󰅂"; onClicked: menu.shift(1) }
    }

    Item {
        width: parent.width
        implicitHeight: grid.implicitHeight + 6
        WheelHandler { onWheel: e => menu.shift(e.angleDelta.y > 0 ? -1 : 1) }
        GridLayout {
            id: grid
            anchors.horizontalCenter: parent.horizontalCenter
            columns: 7
            columnSpacing: 2
            rowSpacing: 2
            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                Label {
                    required property string modelData
                    Layout.preferredWidth: 38
                    Layout.preferredHeight: 26
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: Theme.mauve
                    font.pixelSize: 11
                    font.weight: Font.Bold
                }
            }
            Repeater {
                model: menu.days
                Rectangle {
                    required property var modelData
                    readonly property bool isToday: modelData.toDateString() === menu.today.toDateString()
                    readonly property bool inMonth: modelData.getMonth() === menu.month
                    Layout.preferredWidth: 38
                    Layout.preferredHeight: 32
                    radius: 8
                    color: isToday ? Theme.mauve : "transparent"
                    Label {
                        anchors.centerIn: parent
                        text: parent.modelData.getDate()
                        color: parent.isToday ? Theme.base : parent.inMonth ? Theme.text : Qt.alpha(Theme.subtext, 0.5)
                        font.weight: parent.isToday ? Font.Bold : Font.Medium
                    }
                }
            }
        }
    }
}
