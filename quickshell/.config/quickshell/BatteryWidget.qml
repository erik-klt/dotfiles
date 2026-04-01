import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

Item {
    id: root
    implicitWidth: layout.implicitWidth + 20
    implicitHeight: layout.implicitHeight + 7

    readonly property var dev: {
        if (UPower.devices && UPower.devices.values) {
            let devs = UPower.devices.values
            for (let i = 0; i < devs.length; i++) {
                let d = devs[i]
                if (d && (d.isLaptopBattery || (d.nativePath && String(d.nativePath).includes("BAT")))) {
                    return d
                }
            }
        }
        return UPower.displayDevice
    }

    readonly property int pct: dev ? (dev.percentage <= 1.0 ? Math.round(dev.percentage * 100) : Math.round(dev.percentage)) : 0
    readonly property int state: dev ? dev.state : 0
    readonly property string rateStr: dev ? Math.abs(dev.changeRate).toFixed(2) + " W" : "N/A"
    readonly property string healthStr: (dev && dev.healthSupported) ? Math.round(dev.healthPercentage) + "%" : "Unknown"

    Rectangle {
        anchors.fill: parent
        radius: 30
        color: "#2b2b2b"
    }

    RowLayout {
        id: layout
        spacing: 6
        anchors.centerIn: parent

        Text {
            text: root.state === 1 ? "󰂄" : (root.pct >= 15 ? "󰁹" : "󰂃")
            color: root.state === 1 ? "#7ec8a4" : (root.pct <= 15 ? "#e05e00" : "#c0c0c0")
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
        }
        Text {
            text: root.pct + "%"
            color: root.pct <= 15 ? "#e05e00" : "#c0c0c0"
            font.family: "Maple Mono"
            font.pixelSize: 12
            font.weight: Font.Bold
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: infoPopup.visible = !infoPopup.visible
    }

    PopupWindow {
        id: infoPopup
        width: 180
        height: 110
        visible: false
        grabFocus: true
        color: "transparent"   // ← was: transparent (no quotes = undefined = white corners)

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
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: root.state === 1 ? "󱐋 Charging" : "󰚥 Discharging"
                    color: "#cdd6f4"
                    font.family: "Maple Mono"
                }
                Text {
                    text: "Rate: " + root.rateStr
                    color: "#a6adc8"
                    font.family: "Maple Mono"
                }
                Text {
                    text: "Health: " + root.healthStr
                    color: "#94e2d5"
                    font.family: "Maple Mono"
                }
                Text {
                    text: "Target: " + (root.dev && root.dev.nativePath ? root.dev.nativePath : "Composite")
                    color: "#6c7086"
                    font.family: "Maple Mono"
                    font.pixelSize: 10
                }
            }
        }
    }
}