// shell.qml
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

ShellRoot {
    NotificationServer {
        id: globalNotifServer
        
        onNotification: (notif) => {
            notif.tracked = true 
        }
    }

    Bar {
        // Match this property name to what Bar.qml expects
        notifServer: globalNotifServer 
    }

    NotificationPopup {
        server: globalNotifServer
    }
}

