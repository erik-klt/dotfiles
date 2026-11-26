import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: notifPanel

    property var shellRoot

    anchors {
        top: true
        right: true
    }
    margins {
        top: 8
        right: 8
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-notifications"

    color: "transparent"
    implicitWidth: 340
    implicitHeight: notifColumn.height

    NotificationServer {
        id: notifServer
        keepOnReload: true
        actionsSupported: true
        bodyMarkupSupported: true

        onNotification: notification => {
            notification.tracked = true
        }
    }

    Column {
        id: notifColumn
        width: parent.width
        spacing: 10

        Repeater {
            model: notifServer.trackedNotifications

            delegate: Rectangle {
                id: card
                required property var modelData

                width: notifColumn.width
                height: cardLayout.implicitHeight + 24
                radius: 16
                color: Qt.rgba(0.02, 0.02, 0.02, 0.95)
                border.color: modelData.urgency === NotificationUrgency.Critical
                              ? Qt.rgba(1, 0.3, 0.3, 0.4)
                              : Qt.rgba(1, 1, 1, 0.1)
                border.width: 1

                property bool dismissing: false
                opacity: dismissing ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: 180 } }
                Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutQuad } }

                Timer {
                    id: lifeTimer
                    interval: modelData.expireTimeout > 0 ? modelData.expireTimeout : 5000
                    running: true
                    onTriggered: {
                        card.dismissing = true
                        closeTimer.start()
                    }
                }

                // Small buffer so the fade-out anim finishes before the model entry
                // is actually removed (avoids an abrupt pop).
                Timer {
                    id: closeTimer
                    interval: 200
                    onTriggered: modelData.dismiss()
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: lifeTimer.stop()
                    onExited: if (!card.dismissing) lifeTimer.restart()
                }

                RowLayout {
                    id: cardLayout
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 12
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        Layout.alignment: Qt.AlignTop
                        radius: 12
                        color: Qt.rgba(1, 1, 1, 0.08)

                        Image {
                            anchors.fill: parent
                            anchors.margins: 6
                            source: modelData.appIcon
                            visible: modelData.appIcon !== ""
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: modelData.appIcon === ""
                            text: "󰂚"
                            font.pixelSize: 16
                            color: "#88C0D0"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                Layout.fillWidth: true
                                text: modelData.summary
                                color: "#E5E9F0"
                                font.family: "Maple Mono"
                                font.pixelSize: 12
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: "󰅖"
                                font.pixelSize: 11
                                color: Qt.rgba(1, 1, 1, 0.4)

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -6
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        card.dismissing = true
                                        closeTimer.start()
                                    }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: modelData.body !== ""
                            text: modelData.body
                            color: Qt.rgba(1, 1, 1, 0.6)
                            font.family: "Maple Mono"
                            font.pixelSize: 10
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
