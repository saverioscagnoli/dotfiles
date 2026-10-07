import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import qs
import qs.components
import qs.services

// Desktop widgets (top right, under windows): now playing, then calendar + clock;
// to their left CPU + memory, then a network graph.
PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    // prefer whatever is playing, else the first player that has a track
    readonly property var player: {
        const ps = Mpris.players.values
        return ps.find(p => p.isPlaying) || ps.find(p => p.trackTitle) || null
    }
    readonly property bool hasLength: player !== null && player.lengthSupported && player.length > 0

    // widgets live on a grid of blocks; a card's size is a whole number of blocks
    readonly property int blockWidth: 32
    readonly property int blockHeight: 38
    readonly property int blockGap: Theme.gap * 2
    readonly property int columns: 16
    function spanX(n) { return n * blockWidth + (n - 1) * blockGap }
    function spanY(n) { return n * blockHeight + (n - 1) * blockGap }

    anchors { top: true; right: true }
    margins { top: Theme.barHeight + 12; right: 12 }
    implicitWidth: spanX(columns)
    implicitHeight: grid.implicitHeight
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "quickshell-desktop"

    function fmt(s) {
        s = Math.max(0, Math.floor(s))
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0")
    }

    SystemClock { id: clock; precision: SystemClock.Seconds }

    // MPRIS doesn't push position updates; poll while playing
    Timer {
        running: root.player !== null && root.player.isPlaying
        interval: 1000
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    component Card: Rectangle {
        property int cols: 1
        property int rows: 1
        width: root.spanX(cols)
        height: root.spanY(rows)
        radius: 14
        color: Qt.alpha(Theme.surface, 0.92)
        border.width: 1
        border.color: Theme.overlay
    }

    // 4×3 card: icon + title, a big readout with a small unit after it, and a usage bar
    component StatCard: Card {
        id: sc
        property string icon
        property string title
        property color accent
        property real value
        property string big
        property string small
        property string big2              // optional second readout after the first, e.g. a temperature
        property string small2
        property color big2Color: Theme.text
        cols: 4; rows: 3

        Row {
            id: head
            anchors { left: parent.left; top: parent.top; leftMargin: 14; topMargin: 12 }
            spacing: 6
            Icon { text: sc.icon; color: sc.accent }
            Label { text: sc.title; color: Theme.subtext }
        }
        Label {
            id: bigLabel
            anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14; verticalCenterOffset: 2 }
            text: sc.big
            font.pixelSize: 28
            font.weight: Font.Black
            font.letterSpacing: -1
        }
        Label {
            id: smallLabel
            anchors { left: bigLabel.right; baseline: bigLabel.baseline; leftMargin: 3 }
            text: sc.small
            color: Theme.subtext
            font.pixelSize: 12
            font.weight: Font.Bold
        }
        Label {
            id: big2Label
            anchors { left: smallLabel.right; baseline: bigLabel.baseline; leftMargin: 10 }
            visible: sc.big2 !== ""
            text: sc.big2
            color: sc.big2Color
            font: bigLabel.font
        }
        Label {
            anchors { left: big2Label.right; baseline: bigLabel.baseline; leftMargin: 3 }
            visible: sc.big2 !== ""
            text: sc.small2
            color: Theme.subtext
            font: smallLabel.font
        }
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 14; bottomMargin: 16 }
            height: 6; radius: 3
            color: Theme.overlay
            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, sc.value))
                height: parent.height; radius: 3
                color: sc.accent
                Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
            }
        }
    }

    Row {
        id: grid
        spacing: root.blockGap

        // ── system stats (left of media) ──
        Column {
            spacing: root.blockGap

            Row {
                spacing: root.blockGap

                StatCard {
                    icon: "󰘚"
                    title: "CPU"
                    accent: Theme.blue
                    value: SysStats.cpu
                    big: Math.round(SysStats.cpu * 100)
                    small: "%"
                    big2: isNaN(SysStats.cpuTemp) ? "" : Math.round(SysStats.cpuTemp)
                    small2: "°C"
                    big2Color: SysStats.cpuTemp >= 90 ? Theme.red : SysStats.cpuTemp >= 75 ? Theme.peach : Theme.text
                }

                StatCard {
                    icon: "󰍛"
                    title: "Memory"
                    accent: Theme.green
                    value: SysStats.mem
                    big: (SysStats.memUsed / 1073741824).toFixed(1)
                    small: "/ " + (SysStats.memTotal / 1073741824).toFixed(1) + " GB"
                }
            }

            // ── network: download (filled) and upload (line) over the last minute ──
            Card {
                cols: 8; rows: 3

                Row {
                    id: netHeader
                    anchors { left: parent.left; top: parent.top; leftMargin: 14; topMargin: 12 }
                    spacing: 6
                    Icon { text: "󰛳"; color: Theme.mauve }
                    Label { text: "Network"; color: Theme.subtext }
                }
                Row {
                    anchors { right: parent.right; verticalCenter: netHeader.verticalCenter; rightMargin: 14 }
                    spacing: 12
                    Row {
                        spacing: 3
                        Icon { text: "󰁅"; color: Theme.blue; font.pixelSize: 13 }
                        Label { text: SysStats.bytes(SysStats.rxRate) + "/s" }
                    }
                    Row {
                        spacing: 3
                        Icon { text: "󰁝"; color: Theme.peach; font.pixelSize: 13 }
                        Label { text: SysStats.bytes(SysStats.txRate) + "/s" }
                    }
                }

                Canvas {
                    id: graph
                    anchors { left: parent.left; right: parent.right; top: netHeader.bottom; bottom: parent.bottom; margins: 14; topMargin: 10 }
                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.reset()
                        const rx = SysStats.rxHistory, tx = SysStats.txHistory
                        const n = SysStats.historyLength
                        const peak = Math.max(1024, ...rx, ...tx) * 1.1
                        const px = i => width * i / (n - 1)
                        const py = v => height - height * v / peak
                        const trace = (data) => {
                            const off = n - data.length
                            for (let i = 0; i < data.length; i++) {
                                if (i === 0) ctx.moveTo(px(off), py(data[0]))
                                else ctx.lineTo(px(off + i), py(data[i]))
                            }
                        }

                        // baseline
                        ctx.strokeStyle = Theme.overlay
                        ctx.lineWidth = 1
                        ctx.beginPath(); ctx.moveTo(0, height - 0.5); ctx.lineTo(width, height - 0.5); ctx.stroke()
                        if (rx.length < 2) return

                        ctx.lineJoin = "round"
                        ctx.beginPath(); trace(rx)
                        ctx.lineTo(width, height); ctx.lineTo(px(n - rx.length), height); ctx.closePath()
                        ctx.fillStyle = Qt.alpha(Theme.blue, 0.25)
                        ctx.fill()
                        ctx.beginPath(); trace(rx)
                        ctx.strokeStyle = Theme.blue
                        ctx.lineWidth = 2
                        ctx.stroke()

                        ctx.beginPath(); trace(tx)
                        ctx.strokeStyle = Theme.peach
                        ctx.lineWidth = 1.5
                        ctx.stroke()
                    }
                    Connections {
                        target: SysStats
                        function onRxHistoryChanged() { graph.requestPaint() }
                    }
                    Label {
                        anchors { right: parent.right; top: parent.top }
                        text: SysStats.bytes(Math.max(1024, ...SysStats.rxHistory, ...SysStats.txHistory) * 1.1, 0) + "/s"
                        color: Theme.subtext
                        opacity: 0.7
                        font.pixelSize: 9
                    }
                }
            }
        }

        Column {
            id: col
            spacing: root.blockGap

            // ── now playing ──
            Card {
                id: media
                visible: root.player !== null
                cols: 8; rows: 3

                // vinyl record that spins while playing, with the album art as its label
                Item {
                    id: artBox
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 10 }
                    width: height; height: parent.height - 20

                    Item {
                        id: disc
                        anchors.fill: parent

                        // advance per tick so pausing keeps the current angle; only the label
                        // turns, since the grooves look the same at any angle and would shimmer
                        // 24 fps is plenty at this speed and keeps redraws (and battery use) down
                        Timer {
                            interval: 1000 / 24
                            repeat: true
                            running: media.visible && root.player !== null && root.player.isPlaying
                            onTriggered: label.rotation = (label.rotation + 60 / 24) % 360
                        }

                        // black disc with faint grooves
                        Canvas {
                            anchors.fill: parent
                            onWidthChanged: requestPaint()
                            onPaint: {
                                const ctx = getContext("2d")
                                const r = width / 2
                                ctx.reset()
                                ctx.fillStyle = "#0d0d0d"
                                ctx.beginPath(); ctx.arc(r, r, r, 0, 2 * Math.PI); ctx.fill()
                                ctx.lineWidth = 1
                                for (let g = r * 0.52; g < r - 2; g += 2.5) {
                                    ctx.strokeStyle = Qt.rgba(1, 1, 1, g % 5 < 2.5 ? 0.05 : 0.025)
                                    ctx.beginPath(); ctx.arc(r, r, g, 0, 2 * Math.PI); ctx.stroke()
                                }
                            }
                        }

                        Item {
                            id: label
                            anchors.centerIn: parent
                            width: parent.width * 0.48; height: width
                            antialiasing: true
                            // render once to a texture and rotate it with smooth filtering
                            layer.enabled: true
                            layer.smooth: true
                            layer.mipmap: true
                            layer.textureSize: Qt.size(width * 2, height * 2)

                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: Theme.mauve
                                visible: art.status !== Image.Ready
                                Icon {
                                    anchors.centerIn: parent
                                    text: "󰎆"
                                    font.pixelSize: 18
                                    color: Theme.base
                                }
                            }
                            Image {
                                id: art
                                anchors.fill: parent
                                source: root.player ? root.player.trackArtUrl : ""
                                fillMode: Image.PreserveAspectCrop
                                sourceSize: Qt.size(256, 256)
                                asynchronous: true
                                visible: false
                            }
                            MultiEffect {
                                anchors.fill: art
                                source: art
                                visible: art.status === Image.Ready
                                maskEnabled: true
                                maskSource: artMask
                                maskThresholdMin: 0.5
                                maskSpreadAtMin: 1.0
                            }
                            Item {
                                id: artMask
                                anchors.fill: parent
                                layer.enabled: true
                                visible: false
                                Rectangle { anchors.fill: parent; radius: width / 2 }
                            }
                        }
                    }

                    // static light reflection, so the spin reads against it
                    Canvas {
                        anchors.fill: parent
                        onWidthChanged: requestPaint()
                        onPaint: {
                            const ctx = getContext("2d")
                            const r = width / 2
                            ctx.reset()
                            const grad = ctx.createConicalGradient(r, r, Math.PI / 4)
                            grad.addColorStop(0.00, Qt.rgba(1, 1, 1, 0))
                            grad.addColorStop(0.08, Qt.rgba(1, 1, 1, 0.10))
                            grad.addColorStop(0.16, Qt.rgba(1, 1, 1, 0))
                            grad.addColorStop(0.50, Qt.rgba(1, 1, 1, 0))
                            grad.addColorStop(0.58, Qt.rgba(1, 1, 1, 0.10))
                            grad.addColorStop(0.66, Qt.rgba(1, 1, 1, 0))
                            grad.addColorStop(1.00, Qt.rgba(1, 1, 1, 0))
                            ctx.fillStyle = grad
                            ctx.beginPath(); ctx.arc(r, r, r, 0, 2 * Math.PI); ctx.fill()
                        }
                    }

                    // spindle hole
                    Rectangle {
                        anchors.centerIn: parent
                        width: 6; height: 6; radius: 3
                        color: Theme.surface
                    }
                }

                Row {
                    id: controls
                    anchors { right: parent.right; rightMargin: 10; top: parent.top; topMargin: 16 }
                    spacing: 2
                    IconButton {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "󰒮"
                        iconColor: Theme.text
                        opacity: root.player && root.player.canGoPrevious ? 1 : 0.4
                        onClicked: if (root.player && root.player.canGoPrevious) root.player.previous()
                    }
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 30; height: 30; radius: 15
                        color: playMa.containsMouse ? Qt.lighter(Theme.mauve, 1.1) : Theme.mauve
                        Icon {
                            anchors.centerIn: parent
                            text: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
                            color: Theme.base
                            font.pixelSize: 17
                        }
                        MouseArea {
                            id: playMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (root.player && root.player.canTogglePlaying) root.player.togglePlaying()
                        }
                    }
                    IconButton {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "󰒭"
                        iconColor: Theme.text
                        opacity: root.player && root.player.canGoNext ? 1 : 0.4
                        onClicked: if (root.player && root.player.canGoNext) root.player.next()
                    }
                }

                Column {
                    anchors { left: artBox.right; right: controls.left; top: parent.top; leftMargin: 12; rightMargin: 8; topMargin: 17 }
                    spacing: 1
                    Label {
                        width: parent.width
                        text: root.player ? (root.player.trackTitle || "Unknown title") : ""
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }
                    Label {
                        width: parent.width
                        text: root.player ? (root.player.trackArtist || root.player.identity) : ""
                        color: Theme.subtext
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                }

                // elapsed ─── slider ─── total
                Item {
                    visible: root.hasLength
                    anchors { left: artBox.right; right: parent.right; bottom: parent.bottom; leftMargin: 12; rightMargin: 14; bottomMargin: 16 }
                    height: 18
                    Label {
                        id: posLabel
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                        text: root.player ? root.fmt(root.player.position) : ""
                        color: Theme.subtext; font.pixelSize: 10; font.weight: Font.Medium
                    }
                    Label {
                        id: lenLabel
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        text: root.player ? root.fmt(root.player.length) : ""
                        color: Theme.subtext; font.pixelSize: 10; font.weight: Font.Medium
                    }
                    Slider {
                        anchors { left: posLabel.right; right: lenLabel.left; leftMargin: 8; rightMargin: 8; verticalCenter: parent.verticalCenter }
                        knob: false
                        value: root.hasLength ? root.player.position / root.player.length : 0
                        onMoved: v => { if (root.player && root.player.canSeek) root.player.position = v * root.player.length }
                    }
                }
            }

            Row {
                spacing: root.blockGap

                // ── calendar: big calendar icon with month + day ──
                Card {
                    cols: 4; rows: 3
                    Item {
                        id: page
                        anchors.centerIn: parent
                        height: parent.height * 0.84
                        width: height / 1.14

                        Rectangle {
                            id: sheet
                            anchors.fill: parent
                            anchors.topMargin: 6
                            radius: 14
                            color: Theme.overlay
                            clip: true
                            Rectangle {
                                id: band
                                width: parent.width
                                height: page.width * 0.276
                                color: Theme.mauve
                                Label {
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: 2
                                    text: Qt.formatDate(clock.date, "MMMM").toUpperCase()
                                    color: Theme.base
                                    font.pixelSize: Math.round(band.height * 0.36)
                                    font.weight: Font.Black
                                    font.letterSpacing: 1
                                }
                            }
                            Item {
                                anchors { top: band.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
                                Column {
                                    anchors.centerIn: parent
                                    spacing: -Math.round(page.width * 0.04)
                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: Qt.formatDate(clock.date, "dddd")
                                        color: Theme.subtext
                                        font.pixelSize: Math.round(page.width * 0.13)
                                        font.weight: Font.Bold
                                    }
                                    Label {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: clock.date.getDate()
                                        color: Theme.text
                                        font.pixelSize: Math.round(page.width * 0.38)
                                        font.weight: Font.Black
                                    }
                                }
                            }
                        }
                        // binder rings
                        Repeater {
                            model: 2
                            Rectangle {
                                required property int index
                                x: page.width * (index === 0 ? 0.28 : 0.72) - width / 2
                                y: 0
                                width: 8; height: 16; radius: 4
                                color: Theme.subtext
                                border.width: 2
                                border.color: Theme.surface
                            }
                        }
                    }
                }

                // ── analog clock ──
                Card {
                    cols: 4; rows: 3
                    Item {
                        id: face
                        anchors.centerIn: parent
                        width: Math.min(parent.width, parent.height) - 24; height: width
                        readonly property real r: width / 2
                        readonly property int h: clock.hours
                        readonly property int m: clock.minutes
                        readonly property int s: clock.seconds

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: Theme.base
                            border.width: 2
                            border.color: Theme.overlay
                        }

                        // hour / minute ticks
                        Repeater {
                            model: 60
                            Item {
                                required property int index
                                readonly property bool major: index % 5 === 0
                                anchors.fill: parent
                                rotation: index * 6
                                Rectangle {
                                    x: face.r - width / 2
                                    y: 8
                                    width: parent.major ? 3 : 1
                                    height: parent.major ? 10 : 5
                                    radius: width / 2
                                    color: parent.major ? Theme.text : Theme.subtext
                                    opacity: parent.major ? 1 : 0.6
                                }
                            }
                        }

                        // hands pivot at the centre and stick out a little past it
                        Rectangle {   // hour
                            readonly property real len: face.r * 0.5
                            x: face.r - width / 2; y: face.r - len
                            width: 6; height: len + 8; radius: 3
                            color: Theme.text
                            antialiasing: true
                            transform: Rotation { origin.x: 3; origin.y: face.r * 0.5; angle: (face.h % 12) * 30 + face.m * 0.5 }
                        }
                        Rectangle {   // minute
                            readonly property real len: face.r * 0.74
                            x: face.r - width / 2; y: face.r - len
                            width: 4; height: len + 10; radius: 2
                            color: Theme.text
                            antialiasing: true
                            transform: Rotation { origin.x: 2; origin.y: face.r * 0.74; angle: face.m * 6 + face.s * 0.1 }
                        }
                        Rectangle {   // second
                            readonly property real len: face.r * 0.8
                            x: face.r - width / 2; y: face.r - len
                            width: 2; height: len + 14; radius: 1
                            color: Theme.mauve
                            antialiasing: true
                            transform: Rotation { origin.x: 1; origin.y: face.r * 0.8; angle: face.s * 6 }
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            width: 10; height: 10; radius: 5
                            color: Theme.mauve
                        }
                    }
                }
            }
        }
    }
}
