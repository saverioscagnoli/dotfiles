pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// IPv4 addresses per interface (also covers interfaces NetworkManager doesn't manage).
Singleton {
    id: root
    property var addrs: ({})          // ifname -> "1.2.3.4/24"
    property string wiredIf: ""       // first wired interface that has an address
    readonly property bool wiredUp: wiredIf !== ""

    function parse(json) {
        let list = []
        try { list = JSON.parse(json) } catch (e) { return }
        const a = {}
        let wired = ""
        for (const i of list) {
            const v4 = (i.addr_info || []).find(x => x.family === "inet")
            if (!v4 || i.ifname === "lo") continue
            a[i.ifname] = `${v4.local}/${v4.prefixlen}`
            if (!wired && !/^(wl|docker|veth|br-|virbr|tun|tap|wg|tailscale)/.test(i.ifname)) wired = i.ifname
        }
        addrs = a
        wiredIf = wired
    }

    Process {
        id: ip
        command: ["ip", "-j", "-4", "addr"]
        stdout: StdioCollector { onStreamFinished: root.parse(text) }
    }
    Timer {
        interval: 4000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: ip.running = true
    }
    function refresh() { ip.running = true }
}
