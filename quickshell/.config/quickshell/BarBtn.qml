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
        font.family:           "Symbols Nerd Font, Nerd Font, sans-serif"
        font.pixelSize:        13
        color:                 !btn.enabled   ? "#555555"
                             : btn.pressed    ? "#ffffff"
                             : btn.hovered    ? "#dddddd"
                             :                  "#aaaaaa"
        horizontalAlignment:   Text.AlignHCenter
        verticalAlignment:     Text.AlignVCenter
        Behavior on color { ColorAnimation { duration: 80 } }
    }

    background: Rectangle {
        color:  btn.pressed ? "#22ffffff" : btn.hovered ? "#11ffffff" : "transparent"
        radius: 4
        Behavior on color { ColorAnimation { duration: 80 } }
    }

    opacity: enabled ? 1.0 : 0.35
    Behavior on opacity { NumberAnimation { duration: 100 } }

    scale: pressed ? 0.85 : 1.0
    Behavior on scale { NumberAnimation { duration: 60; easing.type: Easing.OutBack } }
}
