// ============================================
// ChatMessage.qml
pragma ComponentBehavior: Bound
import qs.config
import QtQuick
import qs.services

Rectangle {
    id: root

    property string messageText: ""
    property bool fromUser: false

    height: msgText.height + 16
    color: fromUser ? Colours.palette.m3primaryContainer : Colours.palette.m3secondaryContainer
    radius: 8

    Text {
        id: msgText
        anchors {
            left: parent.left
            right: parent.right
            margins: 8
            verticalCenter: parent.verticalCenter
        }
        text: root.messageText
        wrapMode: Text.Wrap
        color: Colours.palette.m3onSurface
    }
}
