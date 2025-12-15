// ============================================
// ColorPicker.qml
pragma ComponentBehavior: Bound
import qs.components
import qs.config
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services

ColumnLayout {
    id: root
    spacing: Appearance.padding.normal

    property color currentColor: Qt.rgba(redSlider.value / 255, greenSlider.value / 255, blueSlider.value / 255, 1)

    Text {
        text: "Color Picker"
        font.pointSize: Appearance.font.size.large
        font.bold: true
        color: Colours.palette.m3onSurface
    }

    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 200
        Layout.preferredHeight: 200
        radius: 8
        color: root.currentColor
        border.color: Colours.palette.m3outline
        border.width: 2

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }

    GridLayout {
        columns: 2
        columnSpacing: Appearance.padding.normal
        rowSpacing: Appearance.padding.small
        Layout.fillWidth: true

        Text {
            text: "Rojo:"
            color: Colours.palette.m3onSurface
        }
        Slider {
            id: redSlider
            from: 0
            to: 255
            value: 128
            stepSize: 1
            Layout.fillWidth: true
        }

        Text {
            text: "Verde:"
            color: Colours.palette.m3onSurface
        }
        Slider {
            id: greenSlider
            from: 0
            to: 255
            value: 128
            stepSize: 1
            Layout.fillWidth: true
        }

        Text {
            text: "Azul:"
            color: Colours.palette.m3onSurface
        }
        Slider {
            id: blueSlider
            from: 0
            to: 255
            value: 128
            stepSize: 1
            Layout.fillWidth: true
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.padding.small

        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 4
            color: root.currentColor
            border.color: Colours.palette.m3outline
            border.width: 1
        }

        Text {
            id: colorHex
            text: getHexColor()
            font.family: "monospace"
            font.pointSize: Appearance.font.size.normal
            color: Colours.palette.m3onSurface
        }

        Button {
            text: "Copiar"
            onClicked: {
                // Implementar copia al portapapeles
                console.log("Color copiado:", colorHex.text);
            }
        }
    }

    function getHexColor() {
        return "#" + Math.floor(redSlider.value).toString(16).padStart(2, '0').toUpperCase() + Math.floor(greenSlider.value).toString(16).padStart(2, '0').toUpperCase() + Math.floor(blueSlider.value).toString(16).padStart(2, '0').toUpperCase();
    }
}
