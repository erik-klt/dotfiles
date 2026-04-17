// SpotifyWidget.qml
import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

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

    implicitWidth:  active ? row.implicitWidth : 0
    implicitHeight: 28
    clip: true

    Behavior on implicitWidth {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }
    opacity: active ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    Rectangle {
        anchors.fill: parent
        radius: 30
        color: "#050505"
        border.color: "#1C1C1C"
        border.width: 1
    }

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 6
        anchors.rightMargin: 8
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

        Rectangle {
            width: 1
            height: 14
            color: "#44ffffff"
            Layout.leftMargin:  4
            Layout.rightMargin: 4
        }

        // ── Scrolling label ────────────────────────────────────────────────────
        Item {
            implicitWidth: 160
            implicitHeight: 28
            clip: true

            Row {
                id: textRow
                anchors.verticalCenter: parent.verticalCenter
                x: 0
                spacing: 6

                Text {
                    text: root.title
                    color: "#ffffff"
                    font.pixelSize: 12
                }
                Text {
                    text: "·"
                    color: "#888888"
                    font.pixelSize: 12
                    visible: root.title !== "" && root.artist !== ""
                }
                Text {
                    text: root.artist
                    color: "#aaaaaa"
                    font.pixelSize: 12
                }
            }

            // Reset position and restart whenever the track title changes
            Connections {
                target: root
                function onTitleChanged() {
                    textRow.x = 0
                    scrollAnim.restart()
                }
            }

            SequentialAnimation {
                id: scrollAnim
                running: textRow.implicitWidth > 160 && root.active
                loops: Animation.Infinite

                PauseAnimation { duration: 2000 }
                NumberAnimation {
                    target:      textRow
                    property:    "x"
                    to:          -(textRow.implicitWidth - 160)
                    duration:    Math.max(0, textRow.implicitWidth - 160) * 30
                    easing.type: Easing.InOutSine
                }
                PauseAnimation { duration: 1500 }
                NumberAnimation { target: textRow; property: "x"; to: 0; duration: 0 }
            }

            // Right-edge fade — match to your bar background colour
            Rectangle {
                anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                width: 24
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: "#ff050505" }
                }
            }
        }
    }
}
