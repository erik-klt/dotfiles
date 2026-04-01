import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: root
    implicitWidth: layout.implicitWidth + 20
    implicitHeight: layout.implicitHeight + 7

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property int volumePct: sink?.audio ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool muted: sink?.audio ? sink.audio.muted : false

    Rectangle {
        anchors.fill: parent
        radius: 30
        color: "#2b2b2b"
    }

    RowLayout {
        id: layout
        spacing: 4
        anchors.centerIn: parent

        Text {
            text: root.muted ? "󰟎" : "󰋋"
            color: root.muted ? "#585b70" : "#cdd6f4"
            font.pixelSize: 14
            font.family: "Symbols Nerd Font"
        }

        Text {
            text: root.muted ? "muted" : (root.volumePct + "%")
            color: root.muted ? "#585b70" : "#cdd6f4"
            font.pixelSize: 12
            font.family: "Maple Mono"
            font.weight: Font.Bold
        }
    }

    WheelHandler {
        target: root
        onWheel: (event) => {
            const s = root.sink
            if (!s?.audio) return
            const delta = event.angleDelta.y / 120 * 0.05
            s.audio.volume = Math.max(0, Math.min(1, s.audio.volume + delta))
        }
    }

    TapHandler {
        onTapped: audioPopup.visible = !audioPopup.visible
    }

    PopupWindow {
        id: audioPopup
        width: popupContent.implicitWidth
        height: popupContent.implicitHeight
        visible: false
        grabFocus: true
        color: "transparent"

        anchor {
            item: root
            edges: Edges.Bottom
        }

        Rectangle {
            id: popupContent
            implicitWidth: 200
            implicitHeight: 60
            color: "#1e1e2e"
            border.color: "#45475a"
            border.width: 1
            radius: 8

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // Mute Toggle Button
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: root.muted ? "#f38ba8" : "#313244"

                    Text {
                        anchors.centerIn: parent
                        text: root.muted ? "󰝟" : "󰕾"
                        color: root.muted ? "#11111b" : "#cdd6f4"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 14
                    }

                    TapHandler {
                        onTapped: {
                            if (root.sink?.audio)
                                root.sink.audio.muted = !root.sink.audio.muted
                        }
                    }
                }

                // Volume Slider
                Slider {
                    id: volSlider
                    Layout.fillWidth: true
                    from: 0.0
                    to: 1.0
                    value: root.sink?.audio ? root.sink.audio.volume : 0.0

                    onMoved: {
                        if (root.sink?.audio) {
                            root.sink.audio.volume = value
                            if (root.sink.audio.muted && value > 0)
                                root.sink.audio.muted = false
                        }
                    }

                    background: Rectangle {
                        x: volSlider.leftPadding
                        y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                        implicitWidth: 100
                        implicitHeight: 6
                        width: volSlider.availableWidth
                        height: implicitHeight
                        radius: 3
                        color: "#313244"

                        Rectangle {
                            width: volSlider.visualPosition * parent.width
                            height: parent.height
                            color: "#b4befe"
                            radius: 3
                        }
                    }

                    handle: Rectangle {
                        x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                        y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                        implicitWidth: 14
                        implicitHeight: 14
                        radius: 7
                        color: volSlider.pressed ? "#cdd6f4" : "#b4befe"
                        border.color: "#1e1e2e"
                        border.width: 1
                    }
                }
            }
        }
    }
}