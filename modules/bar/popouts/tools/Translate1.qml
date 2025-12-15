// ============================================
// Translate.qml
pragma ComponentBehavior: Bound
import qs.components
import qs.config
import qs.services
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ColumnLayout {
    id: root
    spacing: Appearance.padding.normal

    Text {
        text: "Traductor"
        font.pointSize: Appearance.font.size.large
        font.bold: true
        color: Colours.palette.m3onSurface
    }

    RowLayout {
        spacing: Appearance.padding.small

        ComboBox {
            id: fromLang
            Layout.fillWidth: true
            model: ["Español", "Inglés", "Francés", "Alemán", "Italiano", "Portugués"]
            currentIndex: 0
        }

        MaterialIcon {
            text: "swap_horiz"
            font.pointSize: Appearance.font.size.normal
            color: Colours.palette.m3secondary

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const temp = fromLang.currentIndex;
                    fromLang.currentIndex = toLang.currentIndex;
                    toLang.currentIndex = temp;
                }
            }
        }

        ComboBox {
            id: toLang
            Layout.fillWidth: true
            model: ["Inglés", "Español", "Francés", "Alemán", "Italiano", "Portugués"]
            currentIndex: 0
        }
    }

    ScrollView {
        Layout.fillWidth: true
        Layout.preferredHeight: 120

        TextArea {
            id: inputText
            placeholderText: "Escribe el texto a traducir..."
            wrapMode: TextArea.Wrap
            color: Colours.palette.m3onSurface
        }
    }

    Button {
        Layout.alignment: Qt.AlignHCenter
        text: "Traducir"
        enabled: inputText.text.trim() !== ""

        onClicked: {
            outputText.text = "Traducción simulada: " + inputText.text;
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 100
        color: Colours.palette.m3surfaceVariant
        radius: 8

        ScrollView {
            anchors.fill: parent
            anchors.margins: 8

            Text {
                id: outputText
                text: "La traducción aparecerá aquí..."
                wrapMode: Text.Wrap
                color: Colours.palette.m3onSurfaceVariant
            }
        }
    }
}
