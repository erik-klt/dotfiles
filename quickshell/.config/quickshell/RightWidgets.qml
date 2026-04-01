// RightWidgets.qml - Audio % + WiFi name + Battery %
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 1

    // Audio / headphone volume
    AudioWidget {}

    // Separator dot
    Text {
        text: "·"
        color: "#444"
        font.pixelSize: 14
    }

    // WiFi network name
    NetworkWidget {}

    // Separator dot
    Text {
        text: "·"
        color: "#444"
        font.pixelSize: 14
    }

    // Battery
    BatteryWidget {}

    /*
    BarIcon {
        iconText: "󰂚"   // bell nerd font
        onClicked: {
            // toggle notification center
        }
    }
    */
}
