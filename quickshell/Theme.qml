pragma Singleton
import QtQuick
import Quickshell

// Colours and sizes shared by the whole shell (same palette as the old waybar).
Singleton {
    readonly property color base: "#1b1b1b"
    readonly property color surface: "#252525"
    readonly property color overlay: "#363636"
    readonly property color text: "#e6e6e6"
    readonly property color subtext: "#9a9a9a"
    readonly property color blue: "#89b4fa"
    readonly property color mauve: "#cba6f7"
    readonly property color green: "#a6e3a1"
    readonly property color yellow: "#f9e2af"
    readonly property color peach: "#fab387"
    readonly property color red: "#f38ba8"
    readonly property color teal: "#94e2d5"

    readonly property string font: "Inter"
    readonly property string iconFont: "Symbols Nerd Font"
    readonly property int fontSize: 13
    readonly property int iconSize: 15

    readonly property int barHeight: 40   // reserved at the top of the screen
    readonly property int pillHeight: 26
    readonly property int gap: 6
}
