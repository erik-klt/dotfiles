// CenterWidgets.qml
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: layout
    spacing: 6
    
    // This prevents it from being taller than the PanelWindow
    height: parent.height 

    // Workspace switcher pill
    WorkspaceSwitcher {
        // Ensure the pill itself is centered within the RowLayout
        Layout.alignment: Qt.AlignVCenter
    }
}