pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Per-display wallpapers, keyed by output name (e.g. "DP-2"), saved to
// ~/.local/state/quickshell/.../wallpapers.json so they survive restarts.
Singleton {
    id: root
    readonly property var paths: store.adapter.paths
    readonly property string home: Quickshell.env("HOME")
    // folder the browser opens in: wherever you last picked from
    readonly property string lastDir: store.adapter.lastDir || home + "/Pictures"

    function pathFor(screen) { return screen ? (paths[screen.name] ?? "") : "" }

    function set(name, path) {
        const p = Object.assign({}, store.adapter.paths)
        if (path) p[name] = path; else delete p[name]
        store.adapter.paths = p
        if (path) store.adapter.lastDir = path.substring(0, path.lastIndexOf("/")) || "/"
        store.writeAdapter()
    }

    FileView {
        id: store
        path: Quickshell.statePath("wallpapers.json")
        blockLoading: true
        printErrors: false
        onLoadFailed: err => { if (err === FileViewError.FileNotFound) writeAdapter() }
        JsonAdapter {
            property var paths: ({})
            property string lastDir: ""
        }
    }
}
