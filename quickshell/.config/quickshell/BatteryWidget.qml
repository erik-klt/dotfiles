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
        color: "#050505"
        border.color: "#1C1C1C"   // Ultra-subtle charcoal border
        border.width: 1          // Deep shadow matching the room
    }

    RowLayout {
        id: layout
        spacing: 6
        anchors.centerIn: parent

        Text {
            text: root.state === 1 ? "󰂄" : (root.pct >= 15 ? "󰁹" : "󰂃")
            color: root.state === 1 ? "#A1C85A" : (root.pct <= 15 ? "#FF5B22" : "#D0DED4")
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
        }
        Text {
            text: root.pct + "%"
            color: root.pct <= 15 ? "#FF5B22" : "#D0DED4"
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
        color: "transparent"   

        anchor {
            item: root
            edges: Edges.Bottom
        }

        Rectangle {
            anchors.fill: parent
            color: "#0A0F0A"         // Matches the top pill
            border.color: "#4A8C5B"  // Muted emerald green border
            border.width: 1
            radius: 8

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: root.state === 1 ? "󱐋 Charging" : "󰚥 Discharging"
                    color: root.state === 1 ? "#A1C85A" : "#D0DED4"
                    font.family: "Maple Mono"
                    font.weight: Font.Bold
                }
                Text {
                    text: "Rate: " + root.rateStr
                    color: "#69A87A" // Softer green
                    font.family: "Maple Mono"
                }
                Text {
                    text: "Health: " + root.healthStr
                    color: "#467A4D" // Medium green
                    font.family: "Maple Mono"
                }
                Text {
                    text: "Target: " + (root.dev && root.dev.nativePath ? root.dev.nativePath : "Composite")
                    color: "#2E5232" // Dark, dimmed green
                    font.family: "Maple Mono"
                    font.pixelSize: 10
                }
            }
        }
    }
}
