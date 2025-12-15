// ============================================
// IconButton.qml
pragma ComponentBehavior: Bound
import qs.components
import qs.components.controls
import qs.config
import QtQuick
import QtQuick.Layouts
import qs.services

Item {
    id: iconButton

    Layout.preferredWidth: 40
    Layout.preferredHeight: 40

    property string iconName: ""
    property bool isActive: false

    signal hovered

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: hoverArea.containsMouse || iconButton.isActive ? Colours.palette.m3secondaryContainer : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }

    MaterialIcon {
        anchors.centerIn: parent
        text: iconButton.iconName
        font.pointSize: Appearance.font.size.larger
        color: iconButton.isActive ? Colours.palette.m3primary : Colours.palette.m3secondary

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            iconButton.hovered();
        }
    }
}
