// ============================================
// ColorPicker.qml - Material Design 3
pragma ComponentBehavior: Bound
import qs.components
import qs.config
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services

Rectangle {
    id: root
    color: Colours.tPalette.m3surface
    radius: 28

    property color currentColor: "#FF6B9D"
    property bool copied: false

    ColumnLayout {
        anchors.fill: parent
        //  anchors.margins: 24
        spacing: 10

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: Colours.tPalette.m3tertiaryContainer

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "palette"
                    font.pointSize: 18
                    color: Colours.tPalette.m3onTertiaryContainer
                }
            }

            Text {
                text: "Color Picker"
                font.pointSize: Appearance.font.size.large
                font.weight: Font.Medium
                color: Colours.tPalette.m3onSurface
                Layout.fillWidth: true
            }
        }

        // Color Preview Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 240
            radius: 20
            color: Colours.tPalette.m3surfaceContainerHigh

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                // Main color preview
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 16
                    color: root.currentColor

                    layer.enabled: true
                    layer.effect: ShaderEffect {
                        property real spread: 0.2
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }

                    // Checkered background for transparency
                    Canvas {
                        anchors.fill: parent
                        z: -1

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();

                            var tileSize = 10;
                            var tilesX = Math.ceil(width / tileSize);
                            var tilesY = Math.ceil(height / tileSize);

                            for (var i = 0; i < tilesX; i++) {
                                for (var j = 0; j < tilesY; j++) {
                                    ctx.fillStyle = ((i + j) % 2 === 0) ? "#E0E0E0" : "#FFFFFF";
                                    ctx.fillRect(i * tileSize, j * tileSize, tileSize, tileSize);
                                }
                            }
                        }
                    }

                    // Color value overlay
                    Rectangle {
                        anchors.centerIn: parent
                        width: colorValueText.width + 32
                        height: 44
                        radius: 22
                        color: Qt.rgba(0, 0, 0, 0.6)

                        Text {
                            id: colorValueText
                            anchors.centerIn: parent
                            text: root.currentColor.toString().toUpperCase()
                            font.pointSize: Appearance.font.size.medium
                            font.weight: Font.Bold
                            font.family: "monospace"
                            color: "white"
                        }
                    }
                }

                // Color harmony preview
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Armonía:"
                        font.pointSize: Appearance.font.size.small
                        color: Colours.tPalette.m3onSurfaceVariant
                    }

                    Repeater {
                        model: [Qt.lighter(root.currentColor, 1.3), root.currentColor, Qt.darker(root.currentColor, 1.3)]

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 16
                            color: modelData
                            border.width: 2
                            border.color: Colours.light ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.1)
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // Input Methods Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 320
            radius: 16
            color: Colours.tPalette.m3surfaceContainer

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                Text {
                    text: "Seleccionar color"
                    font.pointSize: Appearance.font.size.normal
                    font.weight: Font.Medium
                    color: Colours.tPalette.m3onSurface
                }

                // Hex Input
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: root.currentColor
                        border.width: 2
                        border.color: Colours.light ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.1)
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        radius: 12
                        color: Colours.tPalette.m3surfaceContainerHighest
                        border.width: hexInput.activeFocus ? 2 : 0
                        border.color: Colours.tPalette.m3primary

                        Behavior on border.width {
                            NumberAnimation {
                                duration: 150
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: "#"
                                font.pointSize: Appearance.font.size.large
                                font.weight: Font.Bold
                                font.family: "monospace"
                                color: Colours.tPalette.m3onSurfaceVariant
                            }

                            TextField {
                                id: hexInput
                                Layout.fillWidth: true
                                text: root.currentColor.toString().substring(1).toUpperCase()
                                placeholderText: "FF6B9D"
                                font.pointSize: Appearance.font.size.normal
                                font.family: "monospace"
                                color: Colours.tPalette.m3onSurface
                                selectByMouse: true
                                maximumLength: 8
                                verticalAlignment: TextInput.AlignVCenter

                                background: Rectangle {
                                    color: "transparent"
                                }

                                onTextEdited: {
                                    var cleanHex = text.replace(/[^0-9A-Fa-f]/g, '');
                                    if (cleanHex.length >= 6) {
                                        root.currentColor = "#" + cleanHex.substring(0, 8);
                                    }
                                }

                                validator: RegularExpressionValidator {
                                    regularExpression: /^[0-9A-Fa-f]{0,8}$/
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Colours.tPalette.m3outlineVariant
                }

                // RGB Inputs
                Text {
                    text: "RGB"
                    font.pointSize: Appearance.font.size.small
                    font.weight: Font.Medium
                    color: Colours.tPalette.m3onSurfaceVariant
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: 12
                    rowSpacing: 12

                    // Red
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        radius: 12
                        color: Colours.light ? Qt.rgba(1, 0, 0, 0.1) : Qt.rgba(1, 0, 0, 0.15)

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 4

                            Text {
                                text: "R"
                                font.pointSize: Appearance.font.size.small
                                font.weight: Font.Bold
                                color: Qt.rgba(0.8, 0.2, 0.2, 1)
                            }

                            TextField {
                                id: redInput
                                Layout.fillWidth: true
                                text: Math.round(root.currentColor.r * 255)
                                font.pointSize: Appearance.font.size.medium
                                font.weight: Font.Bold
                                font.family: "monospace"
                                color: Colours.tPalette.m3onSurface
                                horizontalAlignment: TextInput.AlignHCenter
                                selectByMouse: true

                                background: Rectangle {
                                    color: "transparent"
                                }

                                validator: IntValidator {
                                    bottom: 0
                                    top: 255
                                }

                                onTextEdited: {
                                    var val = parseInt(text) || 0;
                                    val = Math.max(0, Math.min(255, val));
                                    root.currentColor = Qt.rgba(val / 255, root.currentColor.g, root.currentColor.b, root.currentColor.a);
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "0-255"
                                font.pointSize: Appearance.font.size.tiny
                                color: Colours.tPalette.m3onSurfaceVariant
                                opacity: 0.6
                            }
                        }
                    }

                    // Green
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        radius: 12
                        color: Colours.light ? Qt.rgba(0, 1, 0, 0.1) : Qt.rgba(0, 1, 0, 0.15)

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 4

                            Text {
                                text: "G"
                                font.pointSize: Appearance.font.size.small
                                font.weight: Font.Bold
                                color: Qt.rgba(0.2, 0.7, 0.2, 1)
                            }

                            TextField {
                                id: greenInput
                                Layout.fillWidth: true
                                text: Math.round(root.currentColor.g * 255)
                                font.pointSize: Appearance.font.size.medium
                                font.weight: Font.Bold
                                font.family: "monospace"
                                color: Colours.tPalette.m3onSurface
                                horizontalAlignment: TextInput.AlignHCenter
                                selectByMouse: true

                                background: Rectangle {
                                    color: "transparent"
                                }

                                validator: IntValidator {
                                    bottom: 0
                                    top: 255
                                }

                                onTextEdited: {
                                    var val = parseInt(text) || 0;
                                    val = Math.max(0, Math.min(255, val));
                                    root.currentColor = Qt.rgba(root.currentColor.r, val / 255, root.currentColor.b, root.currentColor.a);
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "0-255"
                                font.pointSize: Appearance.font.size.tiny
                                color: Colours.tPalette.m3onSurfaceVariant
                                opacity: 0.6
                            }
                        }
                    }

                    // Blue
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        radius: 12
                        color: Colours.light ? Qt.rgba(0, 0, 1, 0.1) : Qt.rgba(0, 0, 1, 0.15)

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 4

                            Text {
                                text: "B"
                                font.pointSize: Appearance.font.size.small
                                font.weight: Font.Bold
                                color: Qt.rgba(0.2, 0.4, 0.9, 1)
                            }

                            TextField {
                                id: blueInput
                                Layout.fillWidth: true
                                text: Math.round(root.currentColor.b * 255)
                                font.pointSize: Appearance.font.size.medium
                                font.weight: Font.Bold
                                font.family: "monospace"
                                color: Colours.tPalette.m3onSurface
                                horizontalAlignment: TextInput.AlignHCenter
                                selectByMouse: true

                                background: Rectangle {
                                    color: "transparent"
                                }

                                validator: IntValidator {
                                    bottom: 0
                                    top: 255
                                }

                                onTextEdited: {
                                    var val = parseInt(text) || 0;
                                    val = Math.max(0, Math.min(255, val));
                                    root.currentColor = Qt.rgba(root.currentColor.r, root.currentColor.g, val / 255, root.currentColor.a);
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "0-255"
                                font.pointSize: Appearance.font.size.tiny
                                color: Colours.tPalette.m3onSurfaceVariant
                                opacity: 0.6
                            }
                        }
                    }
                }
            }
        }

        // Preset Colors
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            radius: 16
            color: Colours.tPalette.m3surfaceContainerHigh

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "Colores predefinidos"
                    font.pointSize: Appearance.font.size.small
                    font.weight: Font.Medium
                    color: Colours.tPalette.m3onSurfaceVariant
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 8
                    columnSpacing: 8
                    rowSpacing: 8

                    Repeater {
                        model: ["#FF6B9D", "#FF8A80", "#FF80AB", "#EA80FC", "#B388FF", "#8C9EFF", "#82B1FF", "#80D8FF", "#84FFFF", "#A7FFEB", "#B9F6CA", "#CCFF90", "#F4FF81", "#FFFF8D", "#FFE57F", "#FFD180"]

                        Rectangle {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            radius: 18
                            color: modelData
                            border.width: root.currentColor.toString().toUpperCase() === modelData.toUpperCase() ? 3 : 0
                            border.color: Colours.tPalette.m3primary

                            Behavior on border.width {
                                NumberAnimation {
                                    duration: 150
                                }
                            }

                            scale: presetArea.pressed ? 0.9 : (presetArea.containsMouse ? 1.1 : 1.0)

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 100
                                    easing.type: Easing.OutCubic
                                }
                            }

                            MouseArea {
                                id: presetArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    root.currentColor = modelData;
                                }
                            }
                        }
                    }
                }
            }
        }

        // Copy Button
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            radius: 28
            color: root.copied ? Colours.tPalette.m3successContainer : (copyArea.containsMouse ? Qt.lighter(Colours.tPalette.m3primary, 1.1) : Colours.tPalette.m3primary)

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 12

                MaterialIcon {
                    text: root.copied ? "check" : "content_copy"
                    font.pointSize: 20
                    color: root.copied ? Colours.tPalette.m3onSuccessContainer : Colours.tPalette.m3onPrimary

                    Behavior on text {
                        SequentialAnimation {
                            NumberAnimation {
                                target: parent
                                property: "scale"
                                to: 0.5
                                duration: 100
                            }
                            PropertyAction {}
                            NumberAnimation {
                                target: parent
                                property: "scale"
                                to: 1.0
                                duration: 100
                            }
                        }
                    }
                }

                Text {
                    text: root.copied ? "¡Copiado al portapapeles!" : "Copiar color"
                    font.pointSize: Appearance.font.size.normal
                    font.weight: Font.Medium
                    color: root.copied ? Colours.tPalette.m3onSuccessContainer : Colours.tPalette.m3onPrimary
                }
            }

            MouseArea {
                id: copyArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onClicked: {
                    console.log("Color copiado:", root.currentColor.toString().toUpperCase());
                    root.copied = true;
                    copyTimer.restart();
                }
            }

            scale: copyArea.pressed ? 0.96 : 1.0

            Behavior on scale {
                NumberAnimation {
                    duration: 100
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    Timer {
        id: copyTimer
        interval: 2000
        onTriggered: root.copied = false
    }

    // Update inputs when color changes externally
    Connections {
        target: root
        function onCurrentColorChanged() {
            if (!hexInput.activeFocus) {
                hexInput.text = root.currentColor.toString().substring(1).toUpperCase();
            }
            if (!redInput.activeFocus) {
                redInput.text = Math.round(root.currentColor.r * 255);
            }
            if (!greenInput.activeFocus) {
                greenInput.text = Math.round(root.currentColor.g * 255);
            }
            if (!blueInput.activeFocus) {
                blueInput.text = Math.round(root.currentColor.b * 255);
            }
        }
    }
}
