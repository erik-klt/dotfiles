// WorkspaceSwitcher.qml - Pill with workspace buttons (niri-qml)
import QtQuick
import QtQuick.Layouts
import Niri 0.1

Item {
    implicitWidth: row.implicitWidth + 16
    implicitHeight: 22

    Niri {
        id: niri
        Component.onCompleted: connect()
    }

    // Outer pill background
    Rectangle {
        anchors.fill: parent
        radius: 13
        color: "#050505"
        border.color: "#1C1C1C"   // Ultra-subtle charcoal border
        border.width: 1

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 2

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
