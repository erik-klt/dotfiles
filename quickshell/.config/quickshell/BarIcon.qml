// BarIcon.qml - Reusable icon button
import QtQuick

Item {
    implicitWidth: 28
    implicitHeight: 28

    property string iconText: ""
    signal clicked()

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: mouse.containsMouse ? "#2e2e2e" : "transparent"

        Behavior on color {
            ColorAnimation { duration: 100 }
        }

        Text {
            anchors.centerIn: parent
            text: parent.parent.iconText
            font.pixelSize: 15
            color: "#c0c0c0"
            font.family: "symbols-nerd-font"
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.clicked()
    }
}
