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

    // Main Widget Pill
    Rectangle {
        anchors.fill: parent
        radius: 30
        // Deep slate background (#1F232A) at 80% opacity
        color: "#CC1F232A"
        border.color: "#4C566A"  // color8: Dark Grey for a subtle outline
        border.width: 1
    }

    RowLayout {
        id: layout
        spacing: 8
        anchors.centerIn: parent

        Text {
            text: "󱑂"
            // Muted cream/beige (color3) from the mask's skin tone
            color: "#E2D5C3" 
            font.pixelSize: 14
            font.family: "Symbols Nerd Font"
        }

        Text {
            id: timeLabel
            text: root.showDate
                  ? Qt.formatDate(clock.date, "ddd, MMM dd")
                  : Qt.formatTime(clock.date, "hh:mm")
                  
            // Date mode: Ice Blue (#88C0D0) | Time mode: Crisp cream-white (#E5E9F0)
            color: root.showDate ? "#88C0D0" : "#E5E9F0"
            font.pixelSize: 13
            font.family: "Maple Mono"
            font.weight: Font.Medium
            
            Behavior on color { 
                ColorAnimation { duration: 200 } 
            }
        }
    }

    TapHandler {
        onTapped: root.showDate = !root.showDate
    }
}
