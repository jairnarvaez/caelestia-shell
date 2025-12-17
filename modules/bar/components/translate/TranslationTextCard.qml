import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

Rectangle {
    id: card

    property string titleText: ""
    property bool showCounter: false
    property string counterText: ""
    property bool showCopyButton: false
    property string placeholderText: ""
    property string textContent: ""
    property bool isReadOnly: false

    signal copyClicked
    signal textChanged(string newText)

    radius: Appearance.rounding.small
    color: Colours.tPalette.m3surfaceContainerHighest
    border.width: textArea.activeFocus ? 2 : 0
    border.color: Colours.tPalette.m3primary

    Behavior on border.width {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.small

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: card.titleText
                font.pointSize: Appearance.font.size.small
                font.weight: Font.Medium
                color: Colours.tPalette.m3onSurfaceVariant
                Layout.fillWidth: true
            }

            Text {
                visible: card.showCounter
                text: card.counterText
                font.pointSize: Appearance.font.size.small
                color: Colours.tPalette.m3onSurfaceVariant
                opacity: 0.7
            }

            IconButton {
                visible: card.showCopyButton
                iconText: "content_copy"
                iconSize: Appearance.font.size.larger
                onClicked: card.copyClicked()
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            TextArea {
                id: textArea
                text: card.textContent
                placeholderText: card.placeholderText
                wrapMode: TextArea.Wrap
                color: Colours.tPalette.m3onSurface
                font.pointSize: Appearance.font.size.small
                selectByMouse: true
                readOnly: card.isReadOnly

                onTextChanged: card.textChanged(text)

                background: Rectangle {
                    color: "transparent"
                }
            }
        }
    }
}
