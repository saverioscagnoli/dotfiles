pragma Singleton
import QtQuick
import Quickshell

// Which dropdown is open, and where. Only one at a time.
Singleton {
    id: root
    property string current: ""
    property var screen: null
    property real anchorX: 0
    property var items: ({})   // name -> bar item, so IPC can open menus too

    function register(name, item) { items[name] = item }

    // Compare by name: a screen that's unplugged and re-added (lid close/open)
    // comes back as a new object.
    function isOn(s) { return !!screen && !!s && screen.name === s.name }

    function toggle(name, item) {
        // same button on the other monitor moves the menu instead of closing it
        if (current === name && (!item || isOn(item.screenInfo))) { close(); return }
        item = item ?? items[name]
        // registered bar item may have been destroyed along with its screen
        if (!item || !item.screenInfo) {
            screen = Quickshell.screens[0] ?? null
            anchorX = screen ? screen.width / 2 : 0
        } else {
            anchorX = item.mapToItem(null, item.width / 2, 0).x
            screen = item.screenInfo
        }
        current = name
    }

    function close() { current = "" }

    // Outputs changed: whatever was open belongs to a layout that's gone.
    Connections {
        target: Quickshell
        function onScreensChanged() { root.close(); root.screen = null }
    }
}
