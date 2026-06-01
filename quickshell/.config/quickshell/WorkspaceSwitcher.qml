import QtQuick
import QtQuick.Layouts
import Niri 0.1

Item {
    id: root
    implicitWidth: row.implicitWidth + 16
    implicitHeight: 22

    Niri {
        id: niri
        Component.onCompleted: connect()
    }

    // Outer pill background
    Rectangle {
        anchors.fill: parent
        radius: 11 // Adjusted slightly for a tighter mathematical wrap around the 18px inner buttons
        // Deep slate background (#1F232A) at 80% opacity
        color: "#CC1F232A"
        border.color: "#4C566A"  // color8: Dark Grey for a subtle outline
        border.width: 1

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 4 // Bumped spacing from 2 to 4 to give the expanding pills a bit more breathing room

            Repeater {
                model: niri.workspaces

                delegate: WorkspaceButton {
                    wsId: model.id
                    wsIndex: model.index
                    active: model.isFocused
                    urgent: model.isUrgent
                    onActivated: niri.focusWorkspaceById(model.id)
                }
            }
        }
    }
}
