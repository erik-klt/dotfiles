import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root
    implicitWidth: pill.implicitWidth + 20
    implicitHeight: pill.implicitHeight + 10

    // --- Notification Server ---
    NotificationServer {
        id: notifServer
        keepOnReload: true

        onNotification: (notif) => {
            // Add to our model
            notifModel.insert(0, {
                nid:     notif.id,
                app:     notif.appName   || "",
                summary: notif.summary   || "",
                body:    notif.body      || "",
                urgency: notif.urgency   || 0
            })
            // Cap history at 20
            if (notifModel.count > 20) notifModel.remove(20)
            // Auto-dismiss low/normal urgency after 5s
            if (notif.urgency < 2) autoDismiss.restart()
        }
    }

    ListModel { id: notifModel }

    Timer {
        id: autoDismiss
        interval: 5000
        repeat: false
        onTriggered: toastPopup.visible = false
    }

    readonly property int unread: notifModel.count

    // --- Pill ---
    Rectangle {
        id: pillBg
        anchors.fill: parent
        radius: 30
        color: "#2b2b2b"
    }

    RowLayout {
        id: pillContent
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: root.unread > 0 ? "󰂚" : "󰂜"
            color: root.unread > 0 ? "#cdd6f4" : "#585b70"
            font.pixelSize: 14
            font.family: "Symbols Nerd Font"
        }

        Text {
            visible: root.unread > 0
            text: root.unread
            color: "#cdd6f4"
            font.pixelSize: 12
            font.family: "Maple Mono"
            font.weight: Font.Bold
        }
    }

    TapHandler {
        onTapped: {
            if (notifModel.count > 0) {
                notifPopup.visible = !notifPopup.visible
            }
        }
    }

    // --- Toast popup (latest notification) ---
    PopupWindow {
        id: toastPopup
        width: 320
        height: toastContent.implicitHeight + 24
        visible: false
        grabFocus: false
        color: "transparent"

        anchor { item: root; edges: Edges.Bottom }

        Rectangle {
            id: toastContent
            anchors.fill: parent
            color: "#1e1e2e"
            border.color: {
                var u = notifModel.count > 0 ? notifModel.get(0).urgency : 0
                return u === 2 ? "#f38ba8" : "#45475a"
            }
            border.width: 1
            radius: 8

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: notifModel.count > 0 ? notifModel.get(0).app : ""
                        color: "#89b4fa"
                        font.family: "Maple Mono"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: "✕"
                        color: "#585b70"
                        font.pixelSize: 11
                        font.family: "Maple Mono"
                        TapHandler { onTapped: toastPopup.visible = false }
                    }
                }

                Text {
                    text: notifModel.count > 0 ? notifModel.get(0).summary : ""
                    color: "#cdd6f4"
                    font.family: "Maple Mono"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    visible: text !== ""
                }

                Text {
                    text: notifModel.count > 0 ? notifModel.get(0).body : ""
                    color: "#a6adc8"
                    font.family: "Maple Mono"
                    font.pixelSize: 11
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    visible: text !== ""
                }
            }
        }
    }

    // --- History popup ---
    PopupWindow {
        id: notifPopup
        width: 320
        height: Math.min(notifModel.count * 80 + 48, 400)
        visible: false
        grabFocus: true
        color: "transparent"

        Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        anchor { item: root; edges: Edges.Bottom }

        Rectangle {
            anchors.fill: parent
            color: "#1e1e2e"
            border.color: "#45475a"
            border.width: 1
            radius: 8
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // Header
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Notifications"
                        color: "#cdd6f4"
                        font.family: "Maple Mono"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "Clear all"
                        color: "#585b70"
                        font.family: "Maple Mono"
                        font.pixelSize: 11

                        TapHandler {
                            onTapped: {
                                notifModel.clear()
                                notifPopup.visible = false
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

                // List
                ListView {
                    id: notifList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: notifModel
                    spacing: 6

                    delegate: Rectangle {
                        width: notifList.width
                        height: notifItemLayout.implicitHeight + 16
                        color: "#252535"
                        radius: 6
                        border.width: 1
                        border.color: model.urgency === 2 ? "#f38ba8" : "#313244"

                        ColumnLayout {
                            id: notifItemLayout
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 3

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    text: model.app
                                    color: "#89b4fa"
                                    font.family: "Maple Mono"
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: "✕"
                                    color: "#585b70"
                                    font.pixelSize: 11
                                    font.family: "Maple Mono"

                                    TapHandler {
                                        onTapped: notifModel.remove(index)
                                    }
                                }
                            }

                            Text {
                                text: model.summary
                                color: "#cdd6f4"
                                font.family: "Maple Mono"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                visible: text !== ""
                            }

                            Text {
                                text: model.body
                                color: "#a6adc8"
                                font.family: "Maple Mono"
                                font.pixelSize: 10
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                visible: text !== ""
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }
}
