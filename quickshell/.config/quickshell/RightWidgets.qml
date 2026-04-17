// RightWidgets.qml - Audio % + WiFi name + Battery %
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 2

    SpotifyWidget {}

    // Audio / headphone volume
    AudioWidget {}

    // WiFi network name
    NetworkWidget {}

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
