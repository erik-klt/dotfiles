// RightWidgets.qml - Audio % + WiFi name + Battery %
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 2

    SpotifyWidget {}

    property var notifServer

    // Audio / headphone volume
    AudioWidget {}

    // WiFi network name
    NetworkWidget {}

    // Battery
    BatteryWidget {}     
}
