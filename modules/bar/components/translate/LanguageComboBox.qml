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

    // Hacer focusable
    focus: true
    activeFocusOnTab: true

    // NUEVO: Sistema de búsqueda por código
    property string searchBuffer: ""
    property var searchTimer: Timer {
        interval: 1000  // 1 segundo para resetear búsqueda
        repeat: false
        onTriggered: languageSelector.searchBuffer = ""
    }

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

    // NUEVO: Buscar idioma por código
    function _findIndexByCode(code) {
        for (let i = 0; i < dataModel.languages.length; i++) {
            if (dataModel.languages[i].code.toLowerCase().startsWith(code.toLowerCase())) {
                return i;
            }
        }
        return -1;
    }

    // NUEVO: Seleccionar idioma por índice
    function _selectLanguageAtIndex(index) {
        if (index >= 0 && index < languageVariants.instances.length) {
            currentIndex = index;
            languageMenu.active = languageVariants.instances[index];
            selectedLanguage = languageVariants.instances[index].text;
        }
    }

    // Función pública para enfoque
    function focusInput() {
        languageSelector.forceActiveFocus();
    }

    // NUEVO: Manejador de teclado
    Keys.onPressed: function (event) {
        // Flecha arriba: idioma anterior
        if (event.key === Qt.Key_Up) {
            event.accepted = true;
            if (currentIndex > 0) {
                _selectLanguageAtIndex(currentIndex - 1);
            }
        } else

        // Flecha abajo: idioma siguiente
        if (event.key === Qt.Key_Down) {
            event.accepted = true;
            if (currentIndex < languageVariants.instances.length - 1) {
                _selectLanguageAtIndex(currentIndex + 1);
            }
        } else

        // Enter o Space: abrir/cerrar menú
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            event.accepted = true;
            languageMenu.expanded = !languageMenu.expanded;
        } else

        // Escape: cerrar menú si está abierto
        if (event.key === Qt.Key_Escape) {
            if (languageMenu.expanded) {
                event.accepted = true;
                languageMenu.expanded = false;
            }
        } else

        // Números 1-9: selección rápida por índice
        if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
            const numIndex = event.key - Qt.Key_1;  // 0-8
            if (numIndex < languageVariants.instances.length) {
                event.accepted = true;
                _selectLanguageAtIndex(numIndex);
            }
        } else

        // Home: primer idioma
        if (event.key === Qt.Key_Home) {
            event.accepted = true;
            _selectLanguageAtIndex(0);
        } else

        // End: último idioma
        if (event.key === Qt.Key_End) {
            event.accepted = true;
            _selectLanguageAtIndex(languageVariants.instances.length - 1);
        } else

        // NUEVO: Letras A-Z: búsqueda por código
        if (event.key >= Qt.Key_A && event.key <= Qt.Key_Z) {
            event.accepted = true;
            const letter = String.fromCharCode(event.key).toLowerCase();

            // Agregar letra al buffer de búsqueda
            searchBuffer += letter;

            // Buscar idioma que coincida con el código
            const foundIndex = _findIndexByCode(searchBuffer);

            if (foundIndex >= 0) {
                _selectLanguageAtIndex(foundIndex);
                console.log(`Buscando: "${searchBuffer}" → encontrado en índice ${foundIndex}`);
            } else {
                console.log(`Buscando: "${searchBuffer}" → no encontrado`);
            }

            // Reiniciar el timer
            searchTimer.restart();
        }
    }

    StyledRect {
        id: comboButton
        anchors.left: parent.left
        anchors.right: parent.right
        height: texto.implicitHeight + Appearance.spacing.large
        radius: Appearance.rounding.small
        color: Colours.light ? Qt.rgba(0, 0, 0, 0.05) : Qt.rgba(1, 1, 1, 0.05)

        // NUEVO: Indicador visual de foco
        border.width: languageSelector.activeFocus ? 2 : 0
        border.color: Colours.palette.m3primary

        Behavior on border.width {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

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
            onClicked: {
                languageMenu.expanded = !languageMenu.expanded;
                languageSelector.forceActiveFocus();
            }
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
                property int index: model ? model.index : 0

                text: modelData.name
                icon: "language"

                // NUEVO: Mostrar número de acceso rápido si el índice está disponible
                property string shortcutHint: index >= 0 ? (index + 1).toString() : ""
            }
        }
    }
}
