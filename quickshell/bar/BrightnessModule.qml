import QtQuick
import QtQuick.Layouts
import qs
import qs.components
import qs.services

// Hover to slide out a slider; scroll for 5% steps.
Pill {
    id: root
    readonly property real value: Brightness.value
    readonly property bool open: hovered || slider.dragging
    onScrolled: dir => Brightness.set(value + dir * 0.05)

    Item {
        Layout.preferredWidth: root.open ? 110 : 0
        Layout.preferredHeight: 18
        clip: true
        Behavior on Layout.preferredWidth { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        Slider {
            id: slider
            width: 104
            anchors.verticalCenter: parent.verticalCenter
            value: root.value
            fill: Theme.text
            knob: false
            onMoved: v => Brightness.set(v)
        }
    }
    Icon { text: root.value < 0.34 ? "󰃞" : root.value < 0.67 ? "󰃟" : "󰃠"; color: Theme.text }
    Label { text: Math.round(root.value * 100) + "%"; color: Theme.text }
}
