// NotificationBadge.qml - Orange notification count pill
import QtQuick
import Quickshell.Services.Notifications

Item {
    implicitWidth: badge.implicitWidth + 4
    implicitHeight: badge.implicitHeight

    // NotificationServer is the daemon sink; track count via its model
    NotificationServer {
        id: notifServer
        // Keep notifications around so we can count them
        keepOnReload: true
    }

    property int count: notifServer.notifications.count

    visible: count > 0

    Rectangle {
        id: badge
        anchors.centerIn: parent
        implicitWidth: Math.max(22, badgeText.implicitWidth + 12)
        implicitHeight: 20
        radius: 10
        color: "#e05e00"

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: parent.parent.count
            color: "white"
            font.pixelSize: 11
            font.weight: Font.Bold
        }
    }
}
