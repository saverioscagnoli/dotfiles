pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Notification daemon. Every notification stays in the centre until dismissed;
// new ones also pop up briefly unless Do Not Disturb is on.
Singleton {
    id: root
    readonly property var list: server.trackedNotifications.values.slice().reverse()   // newest first
    readonly property int count: list.length
    property bool dnd: false
    property var popups: []           // notifications currently shown as toasts
    property var times: ({})          // id -> Date received
    property date now: new Date()

    function clearAll() { for (const n of list.slice()) n.dismiss() }
    function hidePopup(n) { popups = popups.filter(p => p !== n) }

    function ago(n) {
        const t = times[n.id]
        if (!t) return ""
        const s = Math.max(0, (now - t) / 1000)
        if (s < 60) return "now"
        if (s < 3600) return `${Math.floor(s / 60)}m`
        if (s < 86400) return `${Math.floor(s / 3600)}h`
        return Qt.formatDate(t, "d MMM")
    }

    function icon(n) {
        const src = n.image || n.appIcon
        if (!src) return Quickshell.iconPath(n.desktopEntry || n.appName.toLowerCase(), true)
        if (src.startsWith("/")) return "file://" + src
        if (src.includes("://")) return src
        return Quickshell.iconPath(src, true)
    }

    Timer { interval: 30000; running: true; repeat: true; onTriggered: root.now = new Date() }

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        persistenceSupported: true
        onNotification: n => {
            n.tracked = true
            const t = Object.assign({}, root.times); t[n.id] = new Date(); root.times = t
            root.now = new Date()
            n.closed.connect(() => root.hidePopup(n))
            if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                root.popups = [n, ...root.popups.filter(p => p !== n)].slice(0, 4)
        }
    }
}
