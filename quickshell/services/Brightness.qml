pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Screen backlight: read from sysfs, set through brightnessctl.
Singleton {
    id: root
    property string device: "amdgpu_bl0"
    property int max: 1
    property int raw: 0
    readonly property real value: max > 0 ? raw / max : 0
    property int pending: -1

    FileView {
        id: cur
        path: `/sys/class/backlight/${root.device}/brightness`
        onLoaded: if (root.pending < 0 && !setter.running) root.raw = parseInt(text())
    }
    FileView {
        path: `/sys/class/backlight/${root.device}/max_brightness`
        onLoaded: root.max = parseInt(text())
    }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: cur.reload() }

    // 0..1; minimum 1% so the screen never goes fully dark
    function set(v) {
        raw = Math.round(Math.max(0.01, Math.min(1, v)) * max)
        pending = raw
        if (!setter.running) flush()
    }
    function flush() {
        if (pending < 0) return
        setter.command = ["brightnessctl", "-q", "-d", device, "set", String(pending)]
        pending = -1
        setter.running = true
    }
    Process { id: setter; onExited: root.flush() }
}
