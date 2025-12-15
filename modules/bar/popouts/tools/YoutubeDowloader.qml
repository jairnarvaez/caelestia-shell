// ============================================
// YouTubeDownloader.qml
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

    property bool isDownloading: false
    property real downloadProgress: 0.0

    Text {
        text: "YouTube Downloader"
        font.pointSize: Appearance.font.size.large
        font.bold: true
        color: Colours.palette.m3onSurface
    }

    // URL Input
    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.padding.small

        TextField {
            id: urlInput
            Layout.fillWidth: true
            placeholderText: "Pega la URL del video de YouTube..."
            color: Colours.palette.m3onSurface
            enabled: !root.isDownloading

            onTextChanged: {
                validateButton.enabled = isValidYouTubeUrl(text);
            }
        }

        Button {
            id: validateButton
            text: "Verificar"
            enabled: false

            onClicked: {
                videoInfo.visible = true;
                videoTitle.text = "Título del Video Ejemplo";
                videoDuration.text = "Duración: 3:45";
                videoThumbnail.source = ""; // Aquí iría la miniatura
            }
        }
    }

    // Video Info
    Rectangle {
        id: videoInfo
        Layout.fillWidth: true
        Layout.preferredHeight: 100
        radius: 8
        color: Colours.palette.m3surfaceVariant
        visible: false

        RowLayout {
            anchors.fill: parent
            anchors.margins: Appearance.padding.small
            spacing: Appearance.padding.normal

            Rectangle {
                id: videoThumbnail
                Layout.preferredWidth: 120
                Layout.preferredHeight: 68
                radius: 4
                color: Colours.palette.m3surface

                property string source: ""

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "music_video"
                    font.pointSize: Appearance.font.size.larger * 2
                    color: Colours.palette.m3secondary
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Appearance.padding.tiny

                Text {
                    id: videoTitle
                    Layout.fillWidth: true
                    text: ""
                    font.pointSize: Appearance.font.size.normal
                    font.bold: true
                    color: Colours.palette.m3onSurface
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    maximumLineCount: 2
                }

                Text {
                    id: videoDuration
                    text: ""
                    font.pointSize: Appearance.font.size.small
                    color: Colours.palette.m3secondary
                }
            }
        }
    }

    // Format Selection
    GroupBox {
        Layout.fillWidth: true
        title: "Formato de descarga"

        background: Rectangle {
            color: "transparent"
            border.color: Colours.palette.m3outline
            border.width: 1
            radius: 8
        }

        ColumnLayout {
            width: parent.width
            spacing: Appearance.padding.small

            RadioButton {
                id: mp3Radio
                text: "MP3 (Audio solamente)"
                checked: true
                enabled: !root.isDownloading
            }

            RadioButton {
                id: mp4Radio
                text: "MP4 (Video + Audio)"
                enabled: !root.isDownloading
            }

            RadioButton {
                id: webmRadio
                text: "WebM (Video + Audio)"
                enabled: !root.isDownloading
            }
        }
    }

    // Quality Selection
    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.padding.normal

        Text {
            text: "Calidad:"
            color: Colours.palette.m3onSurface
        }

        ComboBox {
            id: qualityCombo
            Layout.fillWidth: true
            model: mp3Radio.checked ? ["128 kbps", "192 kbps", "256 kbps", "320 kbps"] : ["360p", "480p", "720p", "1080p"]
            currentIndex: mp3Radio.checked ? 3 : 2
            enabled: !root.isDownloading
        }
    }

    // Download Progress
    Rectangle {
        id: progressContainer
        Layout.fillWidth: true
        Layout.preferredHeight: 60
        radius: 8
        color: Colours.palette.m3surfaceVariant
        visible: root.isDownloading

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Appearance.padding.small
            spacing: Appearance.padding.tiny

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Descargando..."
                    color: Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.small
                }

                Text {
                    Layout.alignment: Qt.AlignRight
                    text: Math.round(root.downloadProgress * 100) + "%"
                    color: Colours.palette.m3primary
                    font.bold: true
                }
            }

            ProgressBar {
                Layout.fillWidth: true
                from: 0
                to: 1
                value: root.downloadProgress
            }

            Text {
                text: "Velocidad: 2.5 MB/s • Tiempo restante: 15s"
                color: Colours.palette.m3secondary
                font.pointSize: Appearance.font.size.tiny
            }
        }
    }

    // Download Button
    Button {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 200
        text: root.isDownloading ? "Cancelar" : "Descargar"
        enabled: videoInfo.visible

        onClicked: {
            if (root.isDownloading) {
                root.isDownloading = false;
                downloadTimer.stop();
                root.downloadProgress = 0;
            } else {
                root.startDownload();
            }
        }
    }

    // Download History
    Text {
        text: "Descargas recientes"
        font.pointSize: Appearance.font.size.small
        font.bold: true
        color: Colours.palette.m3onSurface
        Layout.topMargin: Appearance.padding.small
    }

    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ListView {
            id: historyList
            spacing: Appearance.padding.tiny

            model: ListModel {
                id: historyModel
            }

            delegate: Rectangle {
                required property string title
                required property string format
                required property string size

                width: historyList.width
                height: 40
                radius: 6
                color: historyMouseArea.containsMouse ? Colours.palette.m3secondaryContainer : Colours.palette.m3surfaceVariant

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: Appearance.padding.small

                    MaterialIcon {
                        text: "check_circle"
                        color: Colours.palette.m3primary
                        font.pointSize: Appearance.font.size.normal
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            text: title
                            color: Colours.palette.m3onSurface
                            font.pointSize: Appearance.font.size.small
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: format + " • " + size
                            color: Colours.palette.m3secondary
                            font.pointSize: Appearance.font.size.tiny
                        }
                    }

                    MaterialIcon {
                        text: "folder_open"
                        color: Colours.palette.m3secondary
                        font.pointSize: Appearance.font.size.normal
                    }
                }

                MouseArea {
                    id: historyMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        console.log("Abrir archivo:", title);
                    }
                }
            }
        }
    }

    Timer {
        id: downloadTimer
        interval: 100
        repeat: true

        onTriggered: {
            root.downloadProgress += 0.02;

            if (root.downloadProgress >= 1.0) {
                root.downloadProgress = 1.0;
                downloadTimer.stop();
                root.isDownloading = false;

                // Agregar a historial
                historyModel.insert(0, {
                    title: videoTitle.text,
                    format: mp3Radio.checked ? "MP3" : (mp4Radio.checked ? "MP4" : "WebM"),
                    size: "4.2 MB"
                });

                root.downloadProgress = 0;
            }
        }
    }

    function isValidYouTubeUrl(url) {
        return url.includes("youtube.com") || url.includes("youtu.be");
    }

    function startDownload() {
        root.isDownloading = true;
        root.downloadProgress = 0;
        downloadTimer.start();
    }
}
