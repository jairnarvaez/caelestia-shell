pragma ComponentBehavior: Bound
import qs.components
import qs.config
import qs.services
import QtQuick
import Quickshell.Io
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.components.controls
import qs.modules.bar.components.translate
import qs.modules.bar.services

Item {
    id: root

    readonly property int maxCharacters: 500
    readonly property string defaultOutputPlaceholder: "La traducción aparecerá aquí..."

    property bool showMenu: false

    readonly property string fromLanguageSelected: TranslationState.fromLanguageIndex
    readonly property string toLanguageSelected: TranslationState.toLanguageIndex

    property var focusableItems: [inputCard, languageSelector.fromLang, swapButton, languageSelector.toLang, translateButton, outputCard]
    property int currentFocusIndex: 0

    Keys.onPressed: function (event) {
        // Ctrl+Enter o Enter (si no está en un TextArea): Traducir
        if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
            if (event.modifiers & Qt.ControlModifier || !inputCard.isTextAreaFocused()) {
                event.accepted = true;
                if (translateButton.enabled) {
                    translationLogic.translateText();
                }
            }
        } else

        // Ctrl+S: Swap idiomas
        if (event.key === Qt.Key_S && event.modifiers & Qt.ControlModifier) {
            event.accepted = true;
            translationLogic.swapLanguages();
        } else

        // Ctrl+F: Copiar traducción (si hay texto)
        if (event.key === Qt.Key_F && event.modifiers & Qt.ControlModifier) {
            if (outputCard.hasCopyableText()) {
                event.accepted = true;
                translationLogic.copyToClipboard();
            }
        }
    }

    QtObject {
        id: dataModel

        readonly property var languages: [
            {
                code: "en",
                name: "Inglés"
            },
            {
                code: "es",
                name: "Español"
            },
            {
                code: "fr",
                name: "Francés"
            },
            {
                code: "ru",
                name: "Ruso"
            },
            {
                code: "de",
                name: "Alemán"
            }
        ]

        function getLanguageByCode(code) {
            return languages.find(lang => lang.code === code) || languages[0];
        }

        function getLanguageIndexByName(name) {
            return languages.findIndex(lang => lang.name === name);
        }
    }

    TranslationLogic {
        id: translationLogic

        // Establecer referencias
        dataModel: dataModel
        languageSelector: languageSelector
        inputText: inputText
        outputText: outputText
        root: root

        onTranslationStarted: {
            console.log("Iniciando traducción...");
            // Opcionalmente mostrar un indicador de carga
        }

        onTranslationCompleted: function (translatedText) {
            console.log("Traducción completada:", translatedText);
        // Opcionalmente mostrar notificación de éxito
        }

        onTranslationFailed: function (errorMessage) {
            console.error("Error:", errorMessage);
        // Opcionalmente mostrar notificación de error
        }
    }

    state: inputText.text.trim() === "" ? "empty" : "ready"

    states: [
        State {
            name: "empty"
            PropertyChanges {
                target: translateButton
                enabled: false
                opacity: 0.5
            }
        },
        State {
            name: "ready"
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

        // Header
        Header {
            Layout.fillWidth: true
        }

        // Language Selector Row
        LanguageSelector {
            id: languageSelector
            Layout.fillWidth: true
            z: 100
        }

        // Input Card
        TranslationTextCard {
            id: inputCard
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 120

            titleText: "Texto original"
            showCounter: true
            counterText: `${inputText.length} / ${root.maxCharacters}`
            placeholderText: "Escribe o pega el texto aquí..."
            textContent: inputText.text

            onTextChanged: newText => {
                inputText.text = translationLogic.validateInputLength(newText);
                TranslationState.inputText = newText;
            }

            Component.onCompleted: {
                inputText.text = TranslationState.inputText;
                inputCard.focusTextArea();
            }

            TextArea {
                id: inputText
                visible: false
            }
        }

        // Translate Button
        TranslateButton {
            id: translateButton
            Layout.fillWidth: true
            Layout.maximumWidth: implicitWidth + Appearance.padding.large * 10
            Layout.alignment: Qt.AlignHCenter

            onClicked: translationLogic.translateText()
        }

        // Output Card
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
            onTextChanged: newText => {
                outputText.text = newText;
                TranslationState.outputText = newText;
            }

            Component.onCompleted: {
                outputText.text = TranslationState.outputText;
            }

            function hasCopyableText() {
                const text = outputText.text;
                return text !== "" && text !== root.defaultOutputPlaceholder && !text.startsWith("Error:");
            }

            TextArea {
                id: outputText
                visible: false
            }
        }
    }

    component Header: RowLayout {
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
                color: Colours.palette.m3onSecondaryContainer
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

    component LanguageSelector: Rectangle {
        property alias fromLang: fromLang
        property alias toLang: toLang

        Layout.preferredHeight: childrenRect.height
        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surface

        RowLayout {
            width: parent.width
            spacing: Appearance.spacing.small

            LanguageComboBox {
                id: fromLang
                Layout.fillWidth: true

                Component.onCompleted: {
                    currentIndex = TranslationState.fromLanguageIndex;
                }

                onCurrentIndexChanged: {
                    TranslationState.fromLanguageIndex = currentIndex;
                }
            }

            IconButton {
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

            LanguageComboBox {
                id: toLang
                Layout.fillWidth: true

                Component.onCompleted: {
                    currentIndex = TranslationState.toLanguageIndex;
                }

                onCurrentIndexChanged: {
                    TranslationState.toLanguageIndex = currentIndex;
                }
            }
        }
    }

    component TranslateButton: StyledRect {
        id: btn

        signal clicked

        implicitHeight: content.implicitHeight + Appearance.padding.small
        radius: Appearance.rounding.normal
        color: Colours.palette.m3primaryContainer

        StateLayer {
            color: Colours.palette.m3onPrimaryContainer
        }

        RowLayout {
            id: content
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
            enabled: btn.enabled
            onClicked: btn.clicked()

            Accessible.role: Accessible.Button
            Accessible.name: "Traducir texto"
            Accessible.description: "Traduce el texto ingresado al idioma seleccionado"
        }
    }
}
