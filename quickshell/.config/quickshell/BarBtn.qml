// BarBtn.qml  — internal button used by SpotifyWidget
// Drop alongside SpotifyWidget.qml. Not intended for use elsewhere.
import QtQuick
import QtQuick.Controls

AbstractButton {
    id: btn

    implicitWidth:  22
    implicitHeight: 28

    contentItem: Text {
        text:                  btn.text
        font.family:           "Symbols Nerd Font"
        font.pixelSize:        14 // Bumped to 14 to match the rest of the bar's icons
        
        // Disabled: Dark Grey | Pressed: Crimson Accent | Hovered: Cream White | Default: Standard White
        color:                 !btn.enabled   ? "#4C566A"
                             : btn.pressed    ? "#FF6B7A"
                             : btn.hovered    ? "#E5E9F0"
                             :                  "#D8DEE9"
                             
        horizontalAlignment:   Text.AlignHCenter
        verticalAlignment:     Text.AlignVCenter
        Behavior on color { ColorAnimation { duration: 80 } }
    }

    background: Rectangle {
        // Pressed: Base Black/Grey | Hovered: Dark Grey | Default: Transparent
        color:  btn.pressed ? "#1A1D24" : btn.hovered ? "#4C566A" : "transparent"
        radius: 4
        Behavior on color { ColorAnimation { duration: 80 } }
    }

    opacity: enabled ? 1.0 : 0.35
    Behavior on opacity { NumberAnimation { duration: 100 } }

    scale: pressed ? 0.85 : 1.0
    Behavior on scale { NumberAnimation { duration: 60; easing.type: Easing.OutBack } }
}
