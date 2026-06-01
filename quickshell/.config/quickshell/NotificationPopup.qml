import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

PanelWindow {
    id: root
    anchors {
        right: true
        top: true
    }
    color: "transparent"
    implicitWidth: notifColumn.width
    implicitHeight: notifColumn.implicitHeight + 1
    margins {
        right: 20
        top: 20
    }
    property var server
    visible: true
    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.namespace: "notifications"
    WlrLayershell.exclusiveZone: -1

    Column {
        id: notifColumn
        spacing: 12
        width: 380

        Repeater {
            model: server ? server.trackedNotifications : null

            delegate: Item {
                id: delegateRoot
                required property var modelData
                width: notifColumn.width
                height: bgRect.height

                // --- Entrance Animation ---
                opacity: 0
                x: 50
                Component.onCompleted: enterAnim.start()

                ParallelAnimation {
                    id: enterAnim
                    NumberAnimation { target: delegateRoot; property: "opacity"; to: 1; duration: 300; easing.type: Easing.OutCubic }
                    NumberAnimation { target: delegateRoot; property: "x"; to: 0; duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
                }

                // --- Main Notification Card ---
                Rectangle {
                    id: bgRect
                    width: parent.width
                    height: mainLayout.implicitHeight + 24
                    radius: 12
                    // Deep slate background at 80% opacity
                    color: "#CC1F232A" 
                    border.color: "#4C566A" // Dark Grey outline
                    border.width: 1
                    clip: true

                    // Urgency Accent Bar on the left
                    Rectangle {
                        width: 4
                        height: parent.height - 16
                        x: 6
                        y: 8
                        radius: 2
                        // Critical: Crimson | Low: Slate Blue | Normal: Ice Blue
                        color: modelData.urgency === NotificationUrgency.Critical ? "#FF6B7A" : 
                               modelData.urgency === NotificationUrgency.Low ? "#5E81AC" :      
                               "#88C0D0"                                                        
                    }

                    RowLayout {
                        id: mainLayout
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            leftMargin: 20
                            rightMargin: 12
                            topMargin: 12
                        }
                        spacing: 14

                        // App Icon Container
                        Rectangle {
                            Layout.alignment: Qt.AlignTop
                            Layout.preferredWidth: 42
                            Layout.preferredHeight: 42
                            radius: 10
                            color: "#1A1D24" // Base Black for contrast behind the icon
                            visible: !!modelData.appIcon
                            border.color: "#4C566A"
                            border.width: 1

                            Image {
                                anchors.centerIn: parent
                                width: 28
                                height: 28
                                source: modelData.appIcon ? ("image://icon/" + modelData.appIcon) : ""
                                fillMode: Image.PreserveAspectFit
                                mipmap: true
                            }
                        }

                        // Text Column
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            // Header row: Summary + App Name
                            RowLayout {
                                Layout.fillWidth: true
                                
                                Text {
                                    Layout.fillWidth: true
                                    color: "#E5E9F0" // Cream White
                                    text: modelData.summary || ""
                                    font.family: "Maple Mono"
                                    font.bold: true
                                    font.pixelSize: 14
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    color: "#5E81AC" // Slate Blue for secondary metadata
                                    text: modelData.appName ? modelData.appName.toUpperCase() : ""
                                    font.family: "Maple Mono"
                                    font.pixelSize: 10
                                    font.letterSpacing: 0.5
                                    font.bold: true
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                }
                            }

                            // Body text
                            Text {
                                Layout.fillWidth: true
                                color: "#D8DEE9" // Muted White for readability
                                text: modelData.body || ""
                                font.family: "Maple Mono"
                                font.pixelSize: 13
                                wrapMode: Text.WordWrap
                                textFormat: Text.StyledText
                                visible: !!modelData.body
                                lineHeight: 1.15
                            }
                        }

                        // Interactive Close Button
                        Rectangle {
                            Layout.alignment: Qt.AlignTop
                            Layout.preferredWidth: 26
                            Layout.preferredHeight: 26
                            radius: 13
                            color: closeMouseArea.containsMouse ? "#1A1D24" : "transparent"
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                color: closeMouseArea.containsMouse ? "#FF6B7A" : "#4C566A"
                                text: "󰅖"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 16
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            MouseArea {
                                id: closeMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: modelData.dismiss()
                            }
                        }
                    }

                    // --- Visual Timeout Progress Bar ---
                    Rectangle {
                        id: progressBar
                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                        }
                        height: 3
                        // Matches urgency: Crimson or Ice Blue
                        color: modelData.urgency === NotificationUrgency.Critical ? "#FF6B7A" : "#88C0D0"
                        
                        readonly property bool canExpire: modelData.expireTimeout !== 0 && 
                                                          modelData.urgency !== NotificationUrgency.Critical

                        readonly property int totalTime: {
                            if (modelData.expireTimeout > 0) {
                                return modelData.expireTimeout; 
                            }
                            return 5000; 
                        }

                        visible: canExpire
                        width: canExpire ? bgRect.width : 0

                        PropertyAnimation {
                            id: progressAnim
                            target: progressBar
                            property: "width"
                            from: bgRect.width
                            to: 0
                            duration: progressBar.totalTime
                            running: false 
                            
                            onFinished: {
                                if (progressBar.canExpire) {
                                    modelData.expire()
                                }
                            }
                        }

                        Component.onCompleted: {
                            if (canExpire) {
                                progressAnim.restart()
                            }
                        }
                    } 
                }
            }
        }
    }
}
