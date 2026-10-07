pragma Singleton
import QtQuick
import Quickshell

Singleton {
    function appIcon(appId) {
        // touching the list makes bindings re-run once desktop entries finish loading
        if (DesktopEntries.applications.values.length === 0) return Quickshell.iconPath(appId, "application-x-executable")
        const entry = DesktopEntries.heuristicLookup(appId)
        const icon = entry?.icon || appId || ""
        if (icon.startsWith("/")) return "file://" + icon
        return Quickshell.iconPath(icon, "application-x-executable")
    }

    function batteryGlyph(pct) {
        const g = ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
        return g[Math.max(0, Math.min(10, Math.round(pct / 10)))]
    }

    function wifiGlyph(strength) {   // strength 0..1
        const s = strength > 1 ? strength / 100 : strength
        return s >= 0.8 ? "󰤨" : s >= 0.6 ? "󰤥" : s >= 0.4 ? "󰤢" : s >= 0.2 ? "󰤟" : "󰤯"
    }

    function btGlyph(icon) {
        if (!icon) return "󰂯"
        if (icon.startsWith("audio-head") || icon === "audio-card") return "󰋋"
        if (icon === "input-mouse") return "󰍽"
        if (icon === "input-keyboard") return "󰌌"
        if (icon === "input-gaming") return "󰊴"
        if (icon === "phone") return "󰏲"
        if (icon === "computer") return "󰌢"
        return "󰂯"
    }

    function duration(seconds) {
        if (!seconds || seconds <= 0) return ""
        const h = Math.floor(seconds / 3600), m = Math.round((seconds % 3600) / 60)
        return h > 0 ? `${h} h ${m} min` : `${m} min`
    }
}
