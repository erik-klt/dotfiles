import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Networking

Item {
    id: root
    implicitWidth: layout.implicitWidth + 20
    implicitHeight: layout.implicitHeight + 10

    readonly property var wifiDevice: {
        if (Networking.devices && Networking.devices.values) {
            const devs = Networking.devices.values;
            for (let i = 0; i < devs.length; i++) {
                if (devs[i].type === DeviceType.Wifi) return devs[i];
            }
        }
        return null;
    }

    readonly property bool isWifiEnabled: wifiDevice ? wifiDevice.enabled : false
    readonly property real strength: wifiNet ? (wifiNet.signalStrength ?? 0) : 0

    readonly property var wifiNet: {
        if (wifiDevice && wifiDevice.networks && wifiDevice.networks.values) {
            const nets = wifiDevice.networks.values;
            for (let j = 0; j < nets.length; j++) {
                if (nets[j].connected) return nets[j];
            }
        }
        return null;
    }

    readonly property string ssid: wifiNet ? wifiNet.name : "No WiFi"

    // Main Widget Pill
    Rectangle {
        anchors.fill: parent
        radius: 30
        // Deep slate background (#1F232A) at 80% opacity
        color: "#CC1F232A"
        border.color: "#4C566A"  // color8: Dark Grey outline
        border.width: 1
    }

    RowLayout {
        id: layout
        spacing: 4
        anchors.centerIn: parent

        Text {
            text: {
                if (!root.wifiNet && !root.isWifiEnabled) return "󰤮"
                const s = root.strength;
                if (s >= 0.8) return "󰤨";
                else if (s >= 0.6) return "󰤥";
                else if (s >= 0.4) return "󰤢";
                else if (s >= 0.2) return "󰤟";
                else return "󰤯";
            }
            // Connected: Cream White (#E5E9F0) | Disconnected: Crimson (#FF6B7A)
            color: root.wifiNet ? "#E5E9F0" : "#FF6B7A"
            font.pixelSize: 14
            font.family: "Symbols Nerd Font"
        }

        Text {
            text: root.ssid
            color: root.wifiNet ? "#E5E9F0" : "#FF6B7A"
            font.pixelSize: 12
            font.family: "Maple Mono"
            font.weight: Font.Bold
            elide: Text.ElideRight
            maximumLineCount: 1
            Layout.maximumWidth: 120
        }
    }

    TapHandler {
        onTapped: wifiPopup.visible = !wifiPopup.visible
    }

    // Popup Detail Window
    PopupWindow {
        id: wifiPopup
        width: 220
        height: 280
        visible: false
        grabFocus: true
        color: "transparent"

        anchor {
            item: root
            edges: Edges.Bottom
            gravity: Edges.Bottom
        }

        Rectangle {
            anchors.fill: parent
            // Darker slate for the popup (#1A1D24) at 80% opacity
            color: "#CC1A1D24"
            border.color: "#88C0D0" // Ice Blue to uniquely identify the network popup
            border.width: 1
            radius: 8

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Wi-Fi"
                        color: "#E5E9F0"
                        font.family: "Maple Mono"
                        font.pixelSize: 14
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    // Toggle Switch
                    Rectangle {
                        width: 40; height: 24; radius: 12
                        // Green when enabled, Dark Grey when disabled
                        color: root.isWifiEnabled ? "#4AF626" : "#4C566A"
                        
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            width: 18; height: 18; radius: 9; 
                            color: "#1A1D24"; y: 3
                            // Corrected logic: Knob goes right when enabled, left when disabled
                            x: !root.isWifiEnabled ? parent.width - width - 3 : 3
                            Behavior on x { NumberAnimation { duration: 150 } }
                        }

                        TapHandler {
                            onTapped: {
                                if (Networking.wirelessEnabled !== undefined) {
                                    Networking.wirelessEnabled = !Networking.wirelessEnabled;
                                } else if (root.wifiDevice) {
                                    root.wifiDevice.enabled = !root.wifiDevice.enabled;
                                }
                            }
                        }
                    }
                }

                // Divider Line
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#4C566A" // Dark Grey
                }

                // Network List
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 2

                        Repeater {
                            model: (root.wifiDevice && root.wifiDevice.networks) ? root.wifiDevice.networks.values : []

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: modelData.name !== "" ? 32 : 0
                                visible: modelData.name !== ""
                                // Subtle highlight on press
                                color: netTap.pressed ? "#1F232A" : "transparent"
                                radius: 4

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8

                                    Text {
                                        text: modelData.name
                                        // Terminal Green for connected network, White for others
                                        color: modelData.connected ? "#4AF626" : "#E5E9F0"
                                        font.family: "Maple Mono"
                                        font.pixelSize: 12
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.connected ? "󰄬" : "󰤨"
                                        // Green checkmark for connected, Muted Slate-Blue for available networks
                                        color: modelData.connected ? "#4AF626" : "#5E81AC"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 14
                                    }
                                }

                                TapHandler {
                                    id: netTap
                                    onTapped: {
                                        if (!modelData.connected && typeof modelData.connect === "function") {
                                            modelData.connect();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
