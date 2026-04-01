// WorkspaceButton.qml - Single workspace slot inside the pill (niri-qml)
import QtQuick

Item {
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

        color: parent.urgent ? "#e05e00" : (parent.active ? "#5b9bd5" : "#3a3a3a")

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Text {
            anchors.centerIn: parent
            // show 1-based number when active, dot otherwise
            text: parent.parent.active ? (parent.parent.wsIndex).toString() : " " 
            color: (parent.parent.active || parent.parent.urgent) ? "white" : "#888888"
            font.pixelSize: parent.parent.active ? 12 : 10
            font.weight: parent.parent.active ? Font.SemiBold : Font.Normal
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.activated()
    }
}
