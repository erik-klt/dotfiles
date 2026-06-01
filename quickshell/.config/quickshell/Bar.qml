// Bar.qml - Main bar panel
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

PanelWindow {
    id: root

    property var notifServer

    // Anchor to top of screen
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 28
    color: "transparent"
    exclusiveZone: height

    Item {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        // LEFT section
        LeftWidgets {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        // CENTER section (Absolutely centered, never shifts)
        CenterWidgets {
            anchors.centerIn: parent
        }

        // RIGHT section
        RightWidgets {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            notifServer: root.notifServer
        }
    }
}
