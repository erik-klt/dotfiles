import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

Item {
    id: root
    implicitWidth: layout.implicitWidth + 20
    implicitHeight: layout.implicitHeight + 7

    // Logic remains unchanged - fetching the primary battery device
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

    // Main Widget Pill
    Rectangle {
        anchors.fill: parent
        radius: 30
        // #CC1F232A is 80% opacity (CC) applied to the deep slate background (#1F232A)
        color: "#CC1F232A" 
        border.color: "#4C566A"  // color8: Dark Grey for a subtle outline
        border.width: 1          
    }

    RowLayout {
        id: layout
        spacing: 6
        anchors.centerIn: parent

        Text {
            text: root.state === 1 ? "󰂄" : (root.pct >= 15 ? "󰁹" : "󰂃")
            // Charging: Classic Green (#4AF626) | Low: Crimson (#FF6B7A) | Normal: Cream White (#E5E9F0)
            color: root.state === 1 ? "#4AF626" : (root.pct <= 15 ? "#FF6B7A" : "#E5E9F0")
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
        }
        Text {
            text: root.pct + "%"
            color: root.pct <= 15 ? "#FF6B7A" : "#E5E9F0"
            font.family: "Maple Mono"
            font.pixelSize: 12
            font.weight: Font.Bold
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: infoPopup.visible = !infoPopup.visible
    }

    // Popup Detail Window
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
            gravity: Edges.Bottom 
       }

        Rectangle {
            anchors.fill: parent
            // Slightly darker slate background for the popup (#1A1D24) at 80% opacity
            color: "#CC1A1D24"         
            border.color: "#FF6B7A"  // The salmon/crimson accent pops nicely as a border here
            border.width: 1
            radius: 8

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: root.state === 1 ? "󱐋 Charging" : "󰚥 Discharging"
                    color: root.state === 1 ? "#4AF626" : "#E5E9F0"
                    font.family: "Maple Mono"
                    font.weight: Font.Bold
                }
                Text {
                    text: "Rate: " + root.rateStr
                    color: "#88C0D0" // Ice blue (color4) for neutral data output
                    font.family: "Maple Mono"
                }
                Text {
                    text: "Health: " + root.healthStr
                    color: "#A3BE8C" // Muted green (color12) for health status
                    font.family: "Maple Mono"
                }
                Text {
                    text: "Target: " + (root.dev && root.dev.nativePath ? root.dev.nativePath : "Composite")
                    color: "#5E81AC" // Muted slate-blue (color6) for secondary metadata
                    font.family: "Maple Mono"
                    font.pixelSize: 10
                }
            }
        }
    }
}
