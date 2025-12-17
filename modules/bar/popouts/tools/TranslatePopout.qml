pragma ComponentBehavior: Bound
import qs.components
import qs.config
import qs.services
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.components.controls

Item {
    id: root

    readonly property int maxCharacters: 500
    readonly property string defaultOutputPlaceholder: "La traducción aparecerá aquí..."

    property bool showMenu: false

    QtObject {
        id: dataModel

        readonly property var languages: [
            {
                code: "es",
                name: "Español"
            },
            {
                code: "en",
                name: "Inglés"
            },
            {
                code: "fr",
                name: "Francés"
            },
            {
                code: "de",
                name: "Alemán"
            },
            {
                code: "it",
                name: "Italiano"
            },
            {
                code: "pt",
                name: "Portugués"
            }
        ]

        property var languageNames: languages.map(lang => lang.name)
    }

    QtObject {
        id: translationLogic

        function swapLanguages() {
            const temp = fromLang.currentIndex;
            fromLang.currentIndex = toLang.currentIndex;
            toLang.currentIndex = temp;
        }

        function translateText() {
            if (inputText.text.trim() === "") {
                return;
            }

            const fromLangCode = dataModel.languages[fromLang.currentIndex].code;
            const toLangCode = dataModel.languages[toLang.currentIndex].code;

            // TODO: Integrar con API de traducción real
            outputText.text = `Traducción de ${fromLangCode} a ${toLangCode}:\n\n${inputText.text}`;
        }

        function copyToClipboard() {
            // TODO: Implementar copia al portapapeles
            console.log("Copiando al portapapeles:", outputText.text);
        }

        function validateInputLength(text) {
            if (text.length > root.maxCharacters) {
                return text.substring(0, root.maxCharacters);
            }
            return text;
        }
    }

    states: [
        State {
            name: "empty"
            when: inputText.text.trim() === ""
            PropertyChanges {
                target: translateButton
                enabled: false
                opacity: 0.5
            }
        },
        State {
            name: "ready"
            when: inputText.text.trim() !== ""
            PropertyChanges {
                target: translateButton
                enabled: true
                opacity: 1.0
            }
        }
    ]

    transitions: Transition {
        PropertyAnimation {
            properties: "opacity"
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Appearance.spacing.larger

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.normal

            StyledRect {
                implicitWidth: implicitHeight
                implicitHeight: headerIcon.implicitHeight + Appearance.padding.large
                radius: Appearance.rounding.full
                color: Colours.palette.m3secondaryContainer

                MaterialIcon {
                    id: headerIcon
                    anchors.centerIn: parent
                    text: "translate"
                    color: IdleInhibitor.enabled ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                    font.pointSize: Appearance.font.size.large
                }
            }

            Text {
                text: "Traductor"
                font.pointSize: Appearance.font.size.normal
                font.weight: Font.Medium
                color: Colours.tPalette.m3onSurface
                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            radius: Appearance.rounding.normal
            color: Colours.tPalette.m3surface
            z: 100

            RowLayout {
                width: parent.width
                spacing: Appearance.spacing.small

                // From Language
                LanguageComboBox {
                    id: fromLang
                    Layout.fillWidth: true
                }

                // Swap Button
                IconButton {
                    id: swapButton
                    iconText: "swap_horiz"
                    iconSize: Appearance.font.size.large
                    onClicked: {
                        swapAnimation.start();
                        translationLogic.swapLanguages();
                    }

                    RotationAnimator on rotation {
                        id: swapAnimation
                        from: 0
                        to: 180
                        duration: 300
                        running: false
                        easing.type: Easing.OutBack
                    }
                }

                // To Language
                LanguageComboBox {
                    id: toLang
                    Layout.fillWidth: true
                }
            }
        }

        TranslationTextCard {
            id: inputCard
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 120

            titleText: "Texto original"
            showCounter: true
            counterText: inputText.length + " / " + root.maxCharacters
            placeholderText: "Escribe o pega el texto aquí..."
            textContent: inputText.text

            onTextChanged: function (newText) {
                inputText.text = translationLogic.validateInputLength(newText);
            }

            TextArea {
                id: inputText
                visible: false
            }
        }
        StyledRect {
            id: translateButton
            Layout.fillWidth: true
            Layout.maximumWidth: translateBtnContent.implicitWidth + Appearance.padding.large * 10
            Layout.alignment: Qt.AlignHCenter
            implicitHeight: translateBtnContent.implicitHeight + Appearance.padding.small
            radius: Appearance.rounding.normal
            color: Colours.palette.m3primaryContainer

            StateLayer {
                color: Colours.palette.m3onPrimaryContainer
            }

            RowLayout {
                id: translateBtnContent
                anchors.centerIn: parent
                spacing: Appearance.spacing.small

                MaterialIcon {
                    text: "g_translate"
                    font.pointSize: Appearance.font.size.large
                    color: Colours.palette.m3onPrimaryContainer
                }

                StyledText {
                    text: qsTr("Traducir")
                    font.pointSize: Appearance.font.size.small
                    color: Colours.palette.m3onPrimaryContainer
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                enabled: translateButton.enabled
                onClicked: translationLogic.translateText()

                Accessible.role: Accessible.Button
                Accessible.name: "Traducir texto"
                Accessible.description: "Traduce el texto ingresado al idioma seleccionado"
            }
        }

        TranslationTextCard {
            id: outputCard
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 120

            titleText: "Traducción"
            showCounter: false
            showCopyButton: outputText.text !== "" && outputText.text !== root.defaultOutputPlaceholder
            placeholderText: root.defaultOutputPlaceholder
            textContent: outputText.text
            isReadOnly: false

            onCopyClicked: translationLogic.copyToClipboard()
            onTextChanged: function (newText) {
                outputText.text = newText;
            }

            TextArea {
                id: outputText
                visible: false
            }
        }
    }

    component LanguageComboBox: Item {
        id: languageSelector
        Layout.fillWidth: true
        Layout.preferredHeight: comboButton.height

        MouseArea {
            parent: root
            anchors.fill: parent
            visible: languageMenu.expanded
            z: 9998
            onClicked: {
                languageMenu.expanded = false;
            }
        }

        // Botón tipo combobox
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
                    text: languageMenu.active ? languageMenu.active.text : ""
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
                cursorShape: Qt.PointingHandCursor  // Cambia el cursor a mano
                hoverEnabled: true
                onClicked: {
                    languageMenu.expanded = !languageMenu.expanded;
                }
            }
        }

        // Menú desplegable
        Menu {
            id: languageMenu
            anchors.top: comboButton.bottom
            anchors.left: comboButton.left
            anchors.topMargin: Appearance.spacing.small
            width: comboButton.width
            items: languageVariants.instances
            active: languageVariants.instances.length > 0 ? languageVariants.instances[0] : null
            expanded: root.showMenu

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

    component IconButton: Rectangle {
        id: iconBtn

        property string iconText: ""
        property int iconSize: Appearance.font.size.large
        property alias rotation: icon.rotation
        signal clicked

        implicitWidth: implicitHeight
        implicitHeight: icon.implicitHeight + Appearance.padding.smaller * 2
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

    component TranslationTextCard: Rectangle {
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
}
