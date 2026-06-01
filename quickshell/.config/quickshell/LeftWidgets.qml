import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

RowLayout {
    id: root
    spacing: 5

    function run(cmd) { 
        Quickshell.execDetached(["sh", "-c", cmd]) 
    }

    // --- Bluetooth devices model ---
    ListModel { id: btDevicesModel }

    // --- Process to scan BT devices ---
    Process {
        id: btScanProcess
        command: ["sh", "-c", "bluetoothctl devices | while read _ mac name; do paired=$(bluetoothctl info $mac | grep -c 'Connected: yes'); echo \"$mac|$name|$paired\"; done"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                var parts = data.split("|")
                if (parts.length >= 3) {
                    btDevicesModel.append({
                        mac: parts[0],
                        name: parts[1],
                        connected: parts[2].trim() === "1"
                    })
                }
            }
        }
        onRunningChanged: {
            if (!running) btScanDone = true
        }
    }

    property bool btScanDone: false

    // --- Process to get current brightness percentage directly ---
    Process {
        id: brightnessGetProcess
        // brightnessctl -m outputs comma separated values, field 4 is the percentage.
        // We strip the '%' sign and feed it directly into the slider.
        command: ["sh", "-c", "brightnessctl -m | cut -d, -f4 | tr -d '%'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var currentPct = parseInt(data.trim())
                if (!isNaN(currentPct)) {
                    brightSlider.value = currentPct
                }
            }
        }
    }

    // --- Brightness setter (debounced via timer for smooth sliding) ---
    Timer {
        id: brightnessDebounce
        interval: 16 // ~60fps debounce to prevent locking up the shell
        repeat: false
        property int pending: 70
        onTriggered: {
            Quickshell.execDetached(["/usr/bin/brightnessctl", "set", pending + "%"])
        }
    }

    // --- The Dashboard Popup ---
    PopupWindow {
        id: settingsPopup
        width: 260
        height: btExpanded ? 340 : 160
        visible: false
        grabFocus: true
        color: "transparent"
        surfaceFormat.opaque: false

        property bool btExpanded: false

        Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        anchor { item: root; edges: Edges.Bottom; gravity: Edges.Bottom }

        Rectangle {
            anchors.fill: parent
            // Darker slate for the popup (#1A1D24) at 80% opacity
            color: "#CC1A1D24"
            // Muted cream/beige border to uniquely identify the system dashboard
            border.color: "#E2D5C3" 
            border.width: 1
            radius: 8
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                // --- BRIGHTNESS ---
                RowLayout {
                    spacing: 10
                    Text {
                        text: "󰃠"
                        color: "#E2D5C3" // Muted Cream (color3) from the mask
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                    }
                    Slider {
                        id: brightSlider
                        Layout.fillWidth: true
                        implicitHeight: 20
                        from: 1
                        to: 100
                        value: 70

                        onMoved: {
                            // Properly uses the debounce timer so dragging the slider doesn't lag
                            brightnessDebounce.pending = Math.floor(value)
                            brightnessDebounce.restart()
                        }

                        background: Rectangle {
                            x: brightSlider.leftPadding
                            y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
                            width: brightSlider.availableWidth
                            height: 6
                            radius: 3
                            color: "#1F232A" // Deep Slate track
                            Rectangle {
                                width: brightSlider.visualPosition * parent.width
                                height: parent.height
                                color: "#E2D5C3" // Muted Cream active fill
                                radius: 3
                            }
                        }

                        handle: Rectangle {
                            x: brightSlider.leftPadding + brightSlider.visualPosition * (brightSlider.availableWidth - width)
                            y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
                            width: 14; height: 14; radius: 7; 
                            color: brightSlider.pressed ? "#E5E9F0" : "#E2D5C3"
                            border.color: "#1A1D24"
                            border.width: 1
                        }
                    }
                    Text {
                        text: Math.floor(brightSlider.value) + "%"
                        color: "#E5E9F0"
                        font.family: "Maple Mono"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        width: 34
                    }
                }

                // --- DIVIDER ---
                Rectangle { Layout.fillWidth: true; height: 1; color: "#4C566A" }

                // --- BLUETOOTH HEADER ---
                RowLayout {
                    spacing: 10
                    Text {
                        text: "󰂯"
                        color: "#88C0D0" // Ice Blue (color4)
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                    }
                    Text {
                        text: "Bluetooth"
                        color: "#E5E9F0"
                        font.family: "Maple Mono"
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                    }
                    Button {
                        contentItem: Text {
                            text: settingsPopup.btExpanded ? "▲" : "▼"
                            color: "#88C0D0"
                            font.family: "Maple Mono"
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                        }
                        background: Rectangle {
                            implicitWidth: 28; implicitHeight: 22
                            color: parent.pressed ? "#1A1D24" : "#4C566A" 
                            radius: 4
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }
                        onClicked: {
                            if (!settingsPopup.btExpanded) {
                                btDevicesModel.clear()
                                btScanProcess.running = true
                            }
                            settingsPopup.btExpanded = !settingsPopup.btExpanded
                        }
                    }
                }

                // --- BLUETOOTH DEVICE LIST ---
                ListView {
                    id: btListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: settingsPopup.btExpanded
                    clip: true
                    model: btDevicesModel
                    spacing: 6

                    delegate: RowLayout {
                        width: btListView.width
                        spacing: 6

                        Text {
                            text: model.name !== "" ? model.name : model.mac
                            color: model.connected ? "#4AF626" : "#E5E9F0"
                            font.family: "Maple Mono"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Button {
                            contentItem: Text {
                                text: model.connected ? "Disc." : "Conn."
                                // Crimson if connected (warning: clicking will disconnect), Terminal Green if disconnected
                                color: model.connected ? "#FF6B7A" : "#4AF626"
                                font.family: "Maple Mono"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                horizontalAlignment: Text.AlignHCenter
                            }
                            background: Rectangle {
                                implicitWidth: 48; implicitHeight: 22
                                color: "#1F232A"; radius: 4
                                border.width: 1
                                border.color: model.connected ? "#FF6B7A" : "#4AF626"
                            }
                            onClicked: {
                                var cmd = model.connected
                                    ? "bluetoothctl disconnect " + model.mac
                                    : "bluetoothctl connect " + model.mac
                                Quickshell.execDetached(["sh", "-c", cmd])
                                // Optimistically toggle UI
                                btDevicesModel.setProperty(index, "connected", !model.connected)
                            }
                        }
                    }

                    // Empty state
                    Text {
                        anchors.centerIn: parent
                        visible: btDevicesModel.count === 0
                        text: btScanProcess.running ? "Scanning…" : "No devices found"
                        color: "#5E81AC" // Slate Blue
                        font.family: "Maple Mono"
                        font.pixelSize: 11
                    }
                }

                // --- DIVIDER ---
                Rectangle { Layout.fillWidth: true; height: 1; color: "#4C566A" }

                // --- POWER OPTIONS ---
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        Layout.fillWidth: true
                        contentItem: Text {
                            text: "Reboot"
                            color: parent.pressed ? "#1A1D24" : "#E5E9F0"
                            font.family: "Maple Mono"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                        }
                        background: Rectangle {
                            color: parent.pressed ? "#E5E9F0" : "#4C566A"
                            radius: 4
                            border.width: 1; border.color: "#4C566A"
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }
                        onClicked: root.run("reboot")
                    }
                    Button {
                        Layout.fillWidth: true
                        contentItem: Text {
                            text: "Shut Down"
                            // Invert colors on press for a snappy, tactile feel
                            color: parent.pressed ? "#1A1D24" : "#FF6B7A" 
                            font.family: "Maple Mono"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                        }
                        background: Rectangle {
                            color: parent.pressed ? "#FF6B7A" : "#1F232A"
                            radius: 4
                            border.width: 1; border.color: "#FF6B7A"
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }
                        onClicked: root.run("shutdown now")
                    }
                }
            }
        }
    }

    // Skull Trigger Button
    Rectangle {
        implicitWidth: 36
        implicitHeight: 22
        radius: 11 
        // 80% opacity Deep Slate, transitioning to Base Black when pressed
        color: tapTrigger.pressed ? "#1A1D24" : "#CC1F232A"
        border.color: "#4C566A"  // color8: Dark Grey outline
        border.width: 1

        Behavior on color { ColorAnimation { duration: 80 } }

        Text {
            anchors.centerIn: parent
            text: "" // Skull icon
            font.pixelSize: 16
            color: "#FF6B7A" // fsociety Crimson
            font.family: "Symbols Nerd Font"
        }

        TapHandler {
            id: tapTrigger
            onTapped: settingsPopup.visible = !settingsPopup.visible
        }
    }

    ClockWidget {}
}
