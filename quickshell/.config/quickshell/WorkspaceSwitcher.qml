import QtQuick
import QtQuick.Layouts
import Niri 0.1

Item {
    id: root
    implicitWidth: row.implicitWidth + 16
    // Bumped height from 22 to 26 to give the inner buttons vertical breathing room
    implicitHeight: 26 

    Niri {
        id: niri
        Component.onCompleted: connect()
    }

    // Outer pill background
    Rectangle {
        anchors.fill: parent
        // Adjusted radius to 13 (exactly half of 26) for perfectly round edges
        radius: 13 
        // Deep slate background (#1F232A) at 80% opacity
        color: "#CC1F232A"
        border.color: "#4C566A"  // color8: Dark Grey for a subtle outline
        border.width: 1

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 4 

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
