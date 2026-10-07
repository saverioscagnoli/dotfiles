pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

// Scanning and pairing. Pairing goes through bluetoothctl because it brings
// its own pairing agent (Quickshell has none).
Singleton {
    id: root
    readonly property var adapter: Bluetooth.defaultAdapter
    property string error: ""
    property string pairing: ""        // address currently being paired

    function scan() {
        if (!adapter) return
        error = ""
        adapter.discovering = true
        scanTimer.restart()
    }
    Timer { id: scanTimer; interval: 20000; onTriggered: if (root.adapter) root.adapter.discovering = false }

    function pairAndConnect(dev) {
        if (pairProc.running) return
        error = ""
        pairing = dev.address
        pairProc.devName = dev.name
        const a = dev.address
        pairProc.command = ["sh", "-c",
            `timeout 30 bluetoothctl pair ${a} && bluetoothctl trust ${a} >/dev/null && timeout 20 bluetoothctl connect ${a}`]
        pairProc.running = true
    }

    Process {
        id: pairProc
        property string devName
        onExited: code => {
            if (code !== 0) root.error = `Couldn't pair with ${devName}. Put it in pairing mode and try again.`
            root.pairing = ""
        }
    }
}
