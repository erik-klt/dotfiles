import QtQuick

Item {
    id: root
    implicitWidth: active ? 28 : 18
    implicitHeight: 20

    property int wsId: 0
    property int wsIndex: 0   // 0-based index from niri model
    property bool active: false
    property bool urgent: false

    signal activated()

    Behavior on implicitWidth {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.centerIn: parent
        width: parent.implicitWidth - 2
        height: 18
        radius: 9

        // Urgent: Cream White (#E5E9F0) | Active: Crimson/Salmon (#FF6B7A) | Inactive: Dark Grey (#4C566A)
        color: root.urgent ? "#E5E9F0" : (root.active ? "#FF6B7A" : "#4C566A")

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Text {
            anchors.centerIn: parent
            // Show the number if active OR urgent so you know where the alert is coming from
            text: (root.active || root.urgent) ? root.wsIndex.toString() : "" 
            
            // Invert the text color on the bright backgrounds for maximum readability
            color: (root.active || root.urgent) ? "#1A1D24" : "#E5E9F0"
            font.pixelSize: root.active ? 12 : 10
            font.family: "Maple Mono"
            font.weight: root.active ? Font.Bold : Font.Normal
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
