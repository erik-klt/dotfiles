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

    // --- Process to get current brightness ---
    Process {
        id: brightnessGetProcess
        command: ["sh", "-c", "brightnessctl get"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var current = parseInt(data.trim())
                if (!isNaN(current)) {
                    brightSlider.value = Math.round((current / brightnessGetProcess.maxBrightness) * 100)
                }
            }
        }
    }

    // --- Process to get max brightness ---
    Process {
        id: maxBrightnessProcess
        property int maxBrightness: 255
        command: ["sh", "-c", "brightnessctl max"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var max = parseInt(data.trim())
                if (!isNaN(max)) maxBrightnessProcess.maxBrightness = max
            }
        }
    }

    // --- Brightness setter (debounced via timer) ---
    Timer {
        id: brightnessDebounce
        interval: 80
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

        anchor { item: root; edges: Edges.Bottom }

        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            border.color: "#45475a"
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
                        color: "#f9e2af"
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
                            Quickshell.execDetached(["/usr/bin/brightnessctl", "set", Math.floor(value) + "%"])
                        }

                        background: Rectangle {
                            x: brightSlider.leftPadding
                            y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
                            width: brightSlider.availableWidth
                            height: 6
                            radius: 3
                            color: "#313244"
                            Rectangle {
                                width: brightSlider.visualPosition * parent.width
                                height: parent.height
                                color: "#f9e2af"
                                radius: 3
                            }
                        }

    handle: Rectangle {
        x: brightSlider.leftPadding + brightSlider.visualPosition * (brightSlider.availableWidth - width)
        y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
        width: 14; height: 14; radius: 7; color: "#f9e2af"
    }
}
                    Text {
                        text: Math.floor(brightSlider.value) + "%"
                        color: "#a6adc8"
                        font.family: "Maple Mono"
                        font.pixelSize: 11
                        width: 34
                    }
                }

                // --- DIVIDER ---
                Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

                // --- BLUETOOTH HEADER ---
                RowLayout {
                    spacing: 10
                    Text {
                        text: "󰂯"
                        color: "#89b4fa"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                    }
                    Text {
                        text: "Bluetooth"
                        color: "#cdd6f4"
                        font.family: "Maple Mono"
                        Layout.fillWidth: true
                    }
                    Button {
                        contentItem: Text {
                            text: settingsPopup.btExpanded ? "▲" : "▼"
                            color: "#89b4fa"
                            font.family: "Maple Mono"
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                        }
                        background: Rectangle {
                            implicitWidth: 28; implicitHeight: 22
                            color: "#313244"; radius: 4
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
                            color: "#cdd6f4"
                            font.family: "Maple Mono"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Button {
                            contentItem: Text {
                                text: model.connected ? "Disc." : "Conn."
                                color: model.connected ? "#f38ba8" : "#a6e3a1"
                                font.family: "Maple Mono"
                                font.pixelSize: 10
                                horizontalAlignment: Text.AlignHCenter
                            }
                            background: Rectangle {
                                implicitWidth: 48; implicitHeight: 22
                                color: "#313244"; radius: 4
                                border.width: 1
                                border.color: model.connected ? "#f38ba8" : "#a6e3a1"
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
                        color: "#585b70"
                        font.family: "Maple Mono"
                        font.pixelSize: 11
                    }
                }

                // --- DIVIDER ---
                Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

                // --- POWER OPTIONS ---
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        Layout.fillWidth: true
                        contentItem: Text {
                            text: "Reboot"
                            color: "#cdd6f4"
                            font.family: "Maple Mono"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                        }
                        background: Rectangle {
                            color: "#313244"; radius: 4
                            border.width: 1; border.color: "#45475a"
                        }
                        onClicked: root.run("reboot")
                    }
                    Button {
                        Layout.fillWidth: true
                        contentItem: Text {
                            text: "Shut Down"
                            color: "#f38ba8"
                            font.family: "Maple Mono"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                        }
                        background: Rectangle {
                            color: "#313244"; radius: 4
                            border.width: 1; border.color: "#f38ba8"
                        }
                        onClicked: root.run("shutdown now")
                    }
                }
            }
        }
    }

    // Arch Logo Button (the trigger)
    Rectangle {
        implicitWidth: 36
        implicitHeight: 22
        radius: 13
        color: tapArch.pressed ? "#3b3b3b" : "#050505"
        border.color: "#1C1C1C"   // Ultra-subtle charcoal border
        border.width: 1

        Behavior on color { ColorAnimation { duration: 80 } }

        Text {
            anchors.centerIn: parent
            text: "󰣇"
            font.pixelSize: 16
            color: "#1793d1"
            font.family: "Symbols Nerd Font"
        }

        TapHandler {
            id: tapArch
            onTapped: settingsPopup.visible = !settingsPopup.visible
        }
    }


    ClockWidget {}
}
