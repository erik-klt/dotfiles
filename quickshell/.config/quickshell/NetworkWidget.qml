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

    Rectangle {
        anchors.fill: parent
        radius: 30
        color: "#050505"
        border.color: "#1C1C1C"   // Ultra-subtle charcoal border
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
            color: root.wifiNet ? "#cdd6f4" : "#585b70"
            font.pixelSize: 14
            font.family: "Symbols Nerd Font"
        }

        Text {
            text: root.ssid
            color: root.wifiNet ? "#cdd6f4" : "#585b70"
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
        }

        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            border.color: "#45475a"
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
                        color: "#cdd6f4"
                        font.family: "Maple Mono"
                        font.pixelSize: 14
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 40; height: 24; radius: 12
                        color: !root.isWifiEnabled ? "#a6e3a1" : "#45475a"

                        Rectangle {
                            width: 18; height: 18; radius: 9; color: "#1e1e2e"; y: 3
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

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#313244"
                }

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
                                color: netTap.pressed ? "#313244" : "transparent"
                                radius: 4

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8

                                    Text {
                                        text: modelData.name
                                        color: modelData.connected ? "#a6e3a1" : "#cdd6f4"
                                        font.family: "Maple Mono"
                                        font.pixelSize: 12
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.connected ? "󰄬" : "󰤨"
                                        color: modelData.connected ? "#a6e3a1" : "#a6adc8"
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
