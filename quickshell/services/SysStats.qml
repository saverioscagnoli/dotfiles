pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// CPU, memory and network usage, sampled from /proc once a second.
Singleton {
    id: root
    readonly property int historyLength: 60

    property real cpu: 0              // 0..1
    property real cpuTemp: NaN        // °C, NaN until a sensor is found
    property string tempPath: ""
    property real memUsed: 0          // bytes
    property real memTotal: 0         // bytes
    readonly property real mem: memTotal > 0 ? memUsed / memTotal : 0
    property real rxRate: 0           // bytes/s
    property real txRate: 0
    property var rxHistory: []        // oldest first, at most historyLength samples
    property var txHistory: []

    property var lastCpu: null        // [busy, total]
    property var lastNet: null        // [rx, tx, ms]

    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            const f = text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number)
            const idle = f[3] + (f[4] || 0)
            const total = f.reduce((a, b) => a + b, 0)
            if (root.lastCpu && total > root.lastCpu[1])
                root.cpu = 1 - (idle - root.lastCpu[0]) / (total - root.lastCpu[1])
            root.lastCpu = [idle, total]
        }
    }
    // hwmon numbering changes between boots, so look the CPU sensor up by driver name
    Process {
        running: true
        command: ["sh", "-c", "for d in k10temp zenpower coretemp; do for h in /sys/class/hwmon/hwmon*; do [ \"$(cat $h/name)\" = $d ] && echo $h/temp1_input && exit; done; done"]
        stdout: StdioCollector { onStreamFinished: root.tempPath = text.trim() }
    }
    FileView {
        id: temp
        path: root.tempPath
        onLoaded: root.cpuTemp = parseInt(text()) / 1000
    }
    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: {
            const kb = k => Number((text().match(new RegExp(`^${k}:\\s+(\\d+)`, "m")) || [0, 0])[1]) * 1024
            root.memTotal = kb("MemTotal")
            root.memUsed = root.memTotal - kb("MemAvailable")
        }
    }
    FileView {
        id: netdev
        path: "/proc/net/dev"
        onLoaded: {
            let rx = 0, tx = 0
            for (const line of text().split("\n").slice(2)) {
                const m = line.trim().match(/^([^:]+):\s*(.*)$/)
                if (!m || /^(lo|docker|veth|br-|virbr|tun|tap)/.test(m[1])) continue
                const f = m[2].split(/\s+/).map(Number)
                rx += f[0]; tx += f[8]
            }
            const now = Date.now()
            if (root.lastNet) {
                const dt = Math.max(0.001, (now - root.lastNet[2]) / 1000)
                root.rxRate = Math.max(0, rx - root.lastNet[0]) / dt
                root.txRate = Math.max(0, tx - root.lastNet[1]) / dt
                root.rxHistory = root.rxHistory.concat([root.rxRate]).slice(-root.historyLength)
                root.txHistory = root.txHistory.concat([root.txRate]).slice(-root.historyLength)
            }
            root.lastNet = [rx, tx, now]
        }
    }
    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { stat.reload(); meminfo.reload(); netdev.reload(); if (root.tempPath) temp.reload() }
    }

    // 1536 -> "1.5 KB", base 1024
    function bytes(n, digits) {
        const u = ["B", "KB", "MB", "GB", "TB"]
        let i = 0
        while (n >= 1024 && i < u.length - 1) { n /= 1024; i++ }
        return n.toFixed(i === 0 ? 0 : (digits === undefined ? 1 : digits)) + " " + u[i]
    }
}
