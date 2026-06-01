import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root
    implicitWidth: row.implicitWidth + 20
    implicitHeight: row.implicitHeight + 7
 
    property var server

    // Main Widget Pill
    Rectangle {
        anchors.fill: parent
        radius: 30
        // Deep slate background (#1F232A) at 80% opacity
        color: "#CC1F232A"
        border.color: "#4C566A"  // color8: Dark Grey outline
        border.width: 1
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: server && server.trackedNotifications.count > 0 ? "󰂚" : "󰂜" 
            // Crimson (#FF6B7A) when active, Muted Cream White when empty
            color: server && server.trackedNotifications.count > 0 ? "#FF6B7A" : "#E5E9F0"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 14
        }

        Text {
            visible: server && server.trackedNotifications.count > 0
            text: server ? server.trackedNotifications.count : 0
            color: "#FF6B7A"
            font.family: "Maple Mono"
            font.pixelSize: 12
            font.weight: Font.Bold
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (server && server.trackedNotifications.count > 0) {
                for (let i = server.trackedNotifications.count - 1; i >= 0; i--) {
                    server.trackedNotifications.objectAt(i).dismiss()
                }
            }
        }
    }
}
