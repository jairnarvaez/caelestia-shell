import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import qs.components
import qs.config
import qs.services
import qs.components.controls

Item {
    id: languageSelector

    Layout.fillWidth: true
    Layout.preferredHeight: comboButton.height

    property string selectedLanguage: ""
    property int currentIndex: selectedLanguageDefault
    required property int selectedLanguageDefault

    function setLanguageByText(text) {
        const index = _findIndexByText(text);
        if (index >= 0) {
            currentIndex = index;
            languageMenu.active = languageVariants.instances[index];
            selectedLanguage = text;
        }
    }

    function _findIndexByText(text) {
        for (let i = 0; i < languageVariants.instances.length; i++) {
            if (languageVariants.instances[i].text === text) {
                return i;
            }
        }
        return -1;
    }

    StyledRect {
        id: comboButton
        anchors.left: parent.left
        anchors.right: parent.right
        height: texto.implicitHeight + Appearance.spacing.large
        radius: Appearance.rounding.small
        color: Colours.light ? Qt.rgba(0, 0, 0, 0.05) : Qt.rgba(1, 1, 1, 0.05)

        Row {
            anchors.fill: parent
            anchors.leftMargin: Appearance.spacing.normal
            anchors.rightMargin: Appearance.spacing.normal
            spacing: Appearance.spacing.small

            StyledText {
                id: texto
                text: languageMenu.active?.text ?? ""
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: Appearance.font.size.small
                width: parent.width - arrow.width - parent.spacing
            }

            Item {
                id: arrow
                width: 16
                height: 16
                anchors.verticalCenter: parent.verticalCenter

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "keyboard_arrow_down"
                    font.pointSize: Appearance.font.size.normal
                    color: texto.color
                    rotation: languageMenu.expanded ? 180 : 0

                    Behavior on rotation {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: languageMenu.expanded = !languageMenu.expanded
        }
    }

    Menu {
        id: languageMenu
        anchors.top: comboButton.bottom
        anchors.left: comboButton.left
        anchors.topMargin: Appearance.spacing.small
        width: comboButton.width
        items: languageVariants.instances
        active: languageVariants.instances[selectedLanguageDefault] ?? null
        expanded: root.showMenu

        onItemSelected: item => {
            languageSelector.selectedLanguage = item.text;
            languageSelector.currentIndex = languageVariants.instances.indexOf(item);
        }

        Variants {
            id: languageVariants
            model: dataModel.languages

            MenuItem {
                required property var modelData
                text: modelData.name
                icon: "language"
            }
        }
    }
}
