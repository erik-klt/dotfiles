import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    implicitWidth: layout.implicitWidth + 20
    implicitHeight: layout.implicitHeight + 5

    property bool showDate: false

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Rectangle {
        anchors.fill: parent
        radius: 30
        color: "#2b2b2b"
    }

    RowLayout {
        id: layout
        spacing: 8
        anchors.centerIn: parent

        Text {
            text: "󱑂"
            color: "#89b4fa"
            font.pixelSize: 14
            font.family: "Symbols Nerd Font"
        }

        Text {
            id: timeLabel
            text: root.showDate
                  ? Qt.formatDate(clock.date, "ddd, MMM dd")
                  : Qt.formatTime(clock.date, "hh:mm")
            color: root.showDate ? "#94e2d5" : "#cdd6f4"
            font.pixelSize: 13
            font.family: "Maple Mono"
            font.weight: Font.Medium
            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }

    TapHandler {
        onTapped: root.showDate = !root.showDate
    }
}