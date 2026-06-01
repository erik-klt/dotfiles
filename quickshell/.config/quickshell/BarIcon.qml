import QtQuick

Item {
    id: root
    implicitWidth: 28
    implicitHeight: 28

    property string iconText: ""
    // Expose colors so parent widgets can easily theme the icon state
    property color iconColor: "#E5E9F0"  // Default Foreground: Crisp cream-white
    property color hoverColor: "#4C566A" // Default Hover: color8 Dark Grey

    signal clicked()

    Rectangle {
        anchors.fill: parent
        radius: 6 
        // Handles standard hover and adds a darker state (#1A1D24) when actively pressed
        color: mouse.containsMouse ? (mouse.pressed ? "#1A1D24" : root.hoverColor) : "transparent"

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        Text {
            anchors.centerIn: parent
            text: root.iconText
            font.pixelSize: 14 // Matched to the 14px size used in your battery/audio widgets
            color: root.iconColor
            font.family: "Symbols Nerd Font"
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
