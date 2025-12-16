// ============================================
// Translate.qml - Material Design 3
pragma ComponentBehavior: Bound
import qs.components
import qs.config
import qs.services
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    color: Colours.tPalette.m3surface
    radius: 28

    ColumnLayout {
        anchors.fill: parent
        // anchors.margins: 24
        spacing: 20

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: Colours.tPalette.m3primaryContainer

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "translate"
                    font.pointSize: 18
                    color: Colours.tPalette.m3onPrimaryContainer
                }
            }

            Text {
                text: "Traductor"
                font.pointSize: Appearance.font.size.large
                font.weight: Font.Medium
                color: Colours.tPalette.m3onSurface
                Layout.fillWidth: true
            }
        }

        // Language Selection Card
        Rectangle {
            Layout.fillWidth: true
            height: 72
            radius: 16
            color: Colours.tPalette.m3surfaceContainerHigh

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                // From Language
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 12
                    color: Colours.light ? Qt.rgba(0, 0, 0, 0.05) : Qt.rgba(1, 1, 1, 0.05)

                    ComboBox {
                        id: fromLang
                        anchors.fill: parent
                        model: ["Español", "Inglés", "Francés", "Alemán", "Italiano", "Portugués"]
                        currentIndex: 0

                        background: Rectangle {
                            color: "transparent"
                            radius: 12
                        }

                        contentItem: Text {
                            text: fromLang.displayText
                            font.pointSize: Appearance.font.size.normal
                            font.weight: Font.Medium
                            color: Colours.tPalette.m3onSurface
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 16
                        }
                    }
                }

                // Swap Button
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: swapArea.containsMouse ? Colours.tPalette.m3secondaryContainer : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "swap_horiz"
                        font.pointSize: 20
                        color: Colours.tPalette.m3onSurfaceVariant

                        RotationAnimator on rotation {
                            id: swapAnimation
                            from: 0
                            to: 180
                            duration: 300
                            running: false
                            easing.type: Easing.OutBack
                        }
                    }

                    MouseArea {
                        id: swapArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            swapAnimation.start();
                            const temp = fromLang.currentIndex;
                            fromLang.currentIndex = toLang.currentIndex;
                            toLang.currentIndex = temp;
                        }
                    }
                }

                // To Language
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 12
                    color: Colours.light ? Qt.rgba(0, 0, 0, 0.05) : Qt.rgba(1, 1, 1, 0.05)

                    ComboBox {
                        id: toLang
                        anchors.fill: parent
                        model: ["Inglés", "Español", "Francés", "Alemán", "Italiano", "Portugués"]
                        currentIndex: 0

                        background: Rectangle {
                            color: "transparent"
                            radius: 12
                        }

                        contentItem: Text {
                            text: toLang.displayText
                            font.pointSize: Appearance.font.size.normal
                            font.weight: Font.Medium
                            color: Colours.tPalette.m3onSurface
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 16
                        }
                    }
                }
            }
        }

        // Input Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            radius: 16
            color: Colours.tPalette.m3surfaceContainerHighest
            border.width: inputText.activeFocus ? 2 : 0
            border.color: Colours.tPalette.m3primary

            Behavior on border.width {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Texto original"
                        font.pointSize: Appearance.font.size.small
                        font.weight: Font.Medium
                        color: Colours.tPalette.m3onSurfaceVariant
                        Layout.fillWidth: true
                    }

                    Text {
                        text: inputText.length + " / 500"
                        font.pointSize: Appearance.font.size.small
                        color: Colours.tPalette.m3onSurfaceVariant
                        opacity: 0.7
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    TextArea {
                        id: inputText
                        placeholderText: "Escribe o pega el texto aquí..."
                        wrapMode: TextArea.Wrap
                        color: Colours.tPalette.m3onSurface
                        font.pointSize: Appearance.font.size.normal
                        selectByMouse: true

                        background: Rectangle {
                            color: "transparent"
                        }
                    }
                }
            }
        }

        // Translate Button
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            radius: 24
            color: btnArea.containsMouse ? Qt.lighter(Colours.tPalette.m3primary, 1.1) : Colours.tPalette.m3primary
            opacity: inputText.text.trim() !== "" ? 1 : 0.38

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                MaterialIcon {
                    text: "g_translate"
                    font.pointSize: 18
                    color: Colours.tPalette.m3onPrimary
                }

                Text {
                    text: "Traducir"
                    font.pointSize: Appearance.font.size.normal
                    font.weight: Font.Medium
                    color: Colours.tPalette.m3onPrimary
                }
            }

            MouseArea {
                id: btnArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                enabled: inputText.text.trim() !== ""
                onClicked: {
                    outputText.text = "Traducción simulada:\n\n" + inputText.text;
                }
            }
        }

        // Output Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            radius: 16
            color: Colours.tPalette.m3surfaceContainer

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Traducción"
                        font.pointSize: Appearance.font.size.small
                        font.weight: Font.Medium
                        color: Colours.tPalette.m3onSurfaceVariant
                        Layout.fillWidth: true
                    }

                    // Copy Button
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: copyArea.containsMouse ? Colours.tPalette.m3secondaryContainer : "transparent"
                        visible: outputText.text !== "La traducción aparecerá aquí..."

                        MaterialIcon {
                            anchors.centerIn: parent
                            text: "content_copy"
                            font.pointSize: 16
                            color: Colours.tPalette.m3onSurfaceVariant
                        }

                        MouseArea {
                            id: copyArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked:
                            // Aquí iría la lógica de copiar al portapapeles
                            {}
                        }
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        id: outputText
                        text: "La traducción aparecerá aquí..."
                        wrapMode: Text.Wrap
                        color: outputText.text === "La traducción aparecerá aquí..." ? Colours.tPalette.m3onSurfaceVariant : Colours.tPalette.m3onSurface
                        font.pointSize: Appearance.font.size.normal
                        opacity: outputText.text === "La traducción aparecerá aquí..." ? 0.6 : 1
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
