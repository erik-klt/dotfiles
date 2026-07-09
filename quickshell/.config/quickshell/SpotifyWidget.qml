import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property MprisPlayer spotify: null

    Instantiator {
        model: Mpris.players
        delegate: QtObject {
            required property MprisPlayer modelData
            readonly property bool isSpotify: {
                const entry = (modelData.desktopEntry ?? "").toLowerCase()
                const name  = (modelData.identity    ?? "").toLowerCase()
                return entry.includes("spotify") || name.includes("spotify")
            }
            Component.onCompleted:   if (isSpotify) root.spotify = modelData
            Component.onDestruction: if (root.spotify === modelData) root.spotify = null
        }
    }

    readonly property bool   active:    spotify !== null
    readonly property bool   isPlaying: spotify?.playbackState === MprisPlaybackState.Playing
    readonly property string title:     spotify?.trackTitle       ?? ""
    readonly property string artist:    spotify?.trackAlbumArtist ?? ""

    implicitWidth:  active ? row.implicitWidth + 22 : 0
    implicitHeight: 28
    clip: true

    Behavior on implicitWidth {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }
    opacity: active ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    // Main Widget Pill
    Rectangle {
        anchors.fill: parent
        radius: 30
        color: "#CC1F232A"
        border.color: "#4C566A"
        border.width: 1
    }

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 6
        spacing: 0

        BarBtn {
            text: "󰒮"
            enabled: root.spotify?.canGoPrevious ?? false
            onClicked: root.spotify?.previous()
        }

        BarBtn {
            text: root.isPlaying ? "󰏤" : "󰐊"
            enabled: root.spotify?.canTogglePlaying ?? false
            onClicked: root.spotify?.togglePlaying()
        }

        BarBtn {
            text: "󰒭"
            enabled: root.spotify?.canGoNext ?? false
            onClicked: root.spotify?.next()
        }

        // Inner Divider
        Rectangle {
            width: 1
            height: 14
            color: "#4C566A"
            Layout.leftMargin:  4
            Layout.rightMargin: 4
        }

        // ── Scrolling label ────────────────────────────────────────────────────
        Item {
            id: scrollArea
            // FIX 2: Explicit width fixes the layout calculation loop 
            Layout.preferredWidth: 160 
            implicitHeight: 28
            clip: true

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: LinearGradient {
                    width: scrollArea.width
                    height: scrollArea.height
                    start: Qt.point(0, 0)
                    end: Qt.point(scrollArea.width, 0)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "black" }
                        // FIX 3: Pushed to 0.90 so the text fades closer to the right edge
                        GradientStop { position: 0.90; color: "black" } 
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
            }

            Row {
                id: textRow
                anchors.verticalCenter: parent.verticalCenter
                x: 0
                spacing: 6

                Text {
                    text: root.title
                    color: "#E5E9F0"
                    font.pixelSize: 12
                    font.family: "Maple Mono"
                    font.weight: Font.Bold
                }
                Text {
                    text: "·"
                    color: "#5E81AC"
                    font.pixelSize: 12
                    font.family: "Maple Mono"
                    visible: root.title !== "" && root.artist !== ""
                }
                Text {
                    text: root.artist
                    color: "#88C0D0"
                    font.pixelSize: 12
                    font.family: "Maple Mono"
                }
            }

            Connections {
                target: root
                function onTitleChanged() {
                    textRow.x = 0
                    scrollAnim.restart()
                }
            }

            SequentialAnimation {
                id: scrollAnim
                running: textRow.implicitWidth > scrollArea.width && root.active
                loops: Animation.Infinite

                PauseAnimation { duration: 2000 }
                NumberAnimation {
                    target:      textRow
                    property:    "x"
                    to:          -(textRow.implicitWidth - scrollArea.width)
                    duration:    Math.max(0, textRow.implicitWidth - scrollArea.width) * 30
                    easing.type: Easing.InOutSine
                }
                PauseAnimation { duration: 1500 }
                NumberAnimation { target: textRow; property: "x"; to: 0; duration: 0 }
            }
        }
    }
}
