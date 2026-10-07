//@ pragma IconTheme Adwaita
import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.bar
import qs.components
import qs.popups

ShellRoot {
    Variants {
        model: Quickshell.screens
        Wallpaper {}
    }
    Variants {
        model: Quickshell.screens
        DesktopWidgets {}
    }
    Variants {
        model: Quickshell.screens
        Bar {}
    }

    // dropdowns are created once per screen and just shown/hidden (instant open).
    // Per-screen so they're rebuilt with the bars when outputs come and go
    // (lid close/open); a single window would get stranded on the wrong output.
    Variants {
        model: Quickshell.screens
        Scope {
            id: s
            required property var modelData
            Catcher { forScreen: s.modelData }
            Launcher { name: "launcher"; screen: s.modelData }
            WallpaperMenu { name: "wallpaper"; screen: s.modelData }
            ScreenshotMenu { name: "screenshot"; screen: s.modelData }
            CalendarMenu { name: "calendar"; screen: s.modelData }
            AudioMenu { name: "audio-out"; input: false; screen: s.modelData }
            AudioMenu { name: "audio-in"; input: true; screen: s.modelData }
            BluetoothMenu { name: "bluetooth"; screen: s.modelData }
            NetworkMenu { name: "network"; screen: s.modelData }
            PowerProfileMenu { name: "power-profile"; screen: s.modelData }
            PowerMenu { name: "power"; screen: s.modelData }
            NotificationMenu { name: "notifications"; screen: s.modelData }
        }
    }
    NotificationToasts {}

    // e.g. labwc keybind:  qs ipc call menu toggle launcher
    IpcHandler {
        target: "menu"
        function toggle(name: string): void { Popups.toggle(name, null) }
        function close(): void { Popups.close() }
    }
}
