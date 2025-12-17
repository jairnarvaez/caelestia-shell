import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

Rectangle {
    id: iconBtn

    property string iconText: ""
    property int iconSize: Appearance.font.size.large
    property alias rotation: icon.rotation

    signal clicked

    implicitWidth: implicitHeight
    implicitHeight: icon.implicitHeight
    radius: Appearance.rounding.full
    color: mouseArea.containsMouse ? Colours.tPalette.m3secondaryContainer : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    MaterialIcon {
        id: icon
        anchors.centerIn: parent
        text: iconBtn.iconText
        font.pointSize: iconBtn.iconSize
        color: Colours.tPalette.m3onSurfaceVariant
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: iconBtn.clicked()
    }
}
