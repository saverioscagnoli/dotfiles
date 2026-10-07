import QtQuick
import Qt.labs.folderlistmodel
import qs
import qs.components
import qs.services

// Wallpaper browser: folders and image thumbnails. Click an image to set it
// for the display whose bar opened this.
Dropdown {
    id: menu
    panelWidth: 560
    property string dir: Wallpapers.lastDir
    readonly property string screenName: Popups.screen ? Popups.screen.name : ""
    readonly property string current: Wallpapers.paths[screenName] ?? ""
    onOpened: { dir = Wallpapers.lastDir; grid.positionViewAtBeginning() }

    function pretty(p) { return p.startsWith(Wallpapers.home) ? "~" + p.substring(Wallpapers.home.length) : p }
    function up() { dir = dir.substring(0, dir.lastIndexOf("/")) || "/" }

    FolderListModel {
        id: files
        folder: "file://" + menu.dir
        showDirsFirst: true
        showDotAndDotDot: false
        showHidden: false
        caseSensitive: false
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.bmp", "*.gif"]
    }

    // header: up / home / path / remove
    Item {
        width: parent.width
        height: 32
        Row {
            id: nav
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            IconButton { icon: ""; onClicked: menu.up(); opacity: menu.dir === "/" ? 0.4 : 1 }
            IconButton { icon: ""; onClicked: menu.dir = Wallpapers.home }
            IconButton { icon: ""; onClicked: menu.dir = Wallpapers.home + "/Pictures" }
        }
        Label {
            anchors { left: nav.right; leftMargin: 8; right: clear.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
            text: menu.pretty(menu.dir)
            elide: Text.ElideMiddle
            color: Theme.subtext
        }
        IconButton {
            id: clear
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            visible: menu.current !== ""
            icon: ""
            onClicked: Wallpapers.set(menu.screenName, "")
        }
    }

    Item { width: 1; height: 6 }

    GridView {
        id: grid
        readonly property int cols: 3
        width: parent.width
        height: Math.max(80, Math.min(contentHeight, cellHeight * 3.5))
        cellWidth: Math.floor(width / cols)
        cellHeight: Math.round(cellWidth * 0.62)
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: cellHeight * 2
        model: files

        delegate: Item {
            id: cell
            required property string fileName
            required property string filePath
            required property bool fileIsDir
            readonly property bool isCurrent: !fileIsDir && filePath === menu.current
            width: grid.cellWidth
            height: grid.cellHeight

            Rectangle {
                id: tile
                anchors { fill: parent; margins: 4 }
                radius: 10
                color: ma.containsMouse ? Theme.overlay : Theme.base
                clip: true

                Image {
                    id: thumb
                    visible: !cell.fileIsDir
                    anchors { fill: parent; margins: 3 }
                    source: cell.fileIsDir ? "" : "file://" + cell.filePath
                    sourceSize.width: 320
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                    opacity: status === Image.Ready ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }

                Column {
                    visible: cell.fileIsDir
                    anchors.centerIn: parent
                    width: parent.width - 16
                    spacing: 4
                    Icon { anchors.horizontalCenter: parent.horizontalCenter; text: ""; font.pixelSize: 28; color: Theme.mauve }
                    Label { width: parent.width; text: cell.fileName; elide: Text.ElideMiddle; horizontalAlignment: Text.AlignHCenter; font.pixelSize: 12 }
                }

                // file name on hover for images
                Rectangle {
                    visible: !cell.fileIsDir && ma.containsMouse
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 3 }
                    height: 20
                    radius: 7
                    color: Qt.alpha(Theme.base, 0.8)
                    Label { anchors { fill: parent; leftMargin: 6; rightMargin: 6 }
                        text: cell.fileName; elide: Text.ElideMiddle; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter }
                }
            }

            // outline drawn on top so it isn't covered by the thumbnail
            Rectangle {
                anchors { fill: tile }
                radius: tile.radius
                color: "transparent"
                border.width: cell.isCurrent ? 2 : 0
                border.color: Theme.mauve
            }

            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (cell.fileIsDir) menu.dir = cell.filePath
                    else Wallpapers.set(menu.screenName, cell.filePath)
                }
            }
        }

        Label {
            anchors.centerIn: parent
            visible: files.status === FolderListModel.Ready && files.count === 0
            text: "No folders or images here"
            color: Theme.subtext
        }
    }
}
