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

    // Main Widget Pill
    Rectangle {
        anchors.fill: parent
        radius: 30
        // Deep slate background at 80% opacity
        color: "#CC1F232A"
        border.color: "#4C566A"  // color8: Dark Grey outline
        border.width: 1
    }

    RowLayout {
        id: layout
        spacing: 4
        anchors.centerIn: parent

        Text {
            text: root.muted ? "󰟎" : "󰋋"
            // Muted: Crimson (#FF6B7A) | Active: Cream White (#E5E9F0)
            color: root.muted ? "#FF6B7A" : "#E5E9F0"
            font.pixelSize: 14
            font.family: "Symbols Nerd Font"
        }

        Text {
            text: root.muted ? "muted" : (root.volumePct + "%")
            color: root.muted ? "#FF6B7A" : "#E5E9F0"
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

    // Popup Detail Window
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
            gravity: Edges.Bottom
        }

        Rectangle {
            id: popupContent
            implicitWidth: 200
            implicitHeight: 60
            // Darker slate for the popup at 80% opacity
            color: "#CC1A1D24"
            border.color: "#5E81AC" // Slate-blue (color6) border to differentiate from battery
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
                    // Crimson background when muted, Dark Grey when active
                    color: root.muted ? "#FF6B7A" : "#4C566A"

                    Text {
                        anchors.centerIn: parent
                        text: root.muted ? "󰝟" : "󰕾"
                        // Invert icon color when muted for contrast
                        color: root.muted ? "#1F232A" : "#E5E9F0"
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
                        color: "#1A1D24" // Darkest grey for the slider track

                        Rectangle {
                            width: volSlider.visualPosition * parent.width
                            height: parent.height
                            color: "#88C0D0" // Ice blue for the active volume level
                            radius: 3
                        }
                    }

                    handle: Rectangle {
                        x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                        y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                        implicitWidth: 14
                        implicitHeight: 14
                        radius: 7
                        // Cream white when pressed, otherwise Ice Blue
                        color: volSlider.pressed ? "#E5E9F0" : "#88C0D0"
                        border.color: "#1F232A"
                        border.width: 1
                    }
                }
            }
        }
    }
}
