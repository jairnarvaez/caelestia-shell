// ============================================
// YouTubeDownloader.qml - Material Design 3
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

    property bool isDownloading: false
    property real downloadProgress: 0.0

    ColumnLayout {
        anchors.fill: parent
        //   anchors.margins: 24
        spacing: 20

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: Colours.tPalette.m3errorContainer

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "download"
                    font.pointSize: 18
                    color: Colours.tPalette.m3onErrorContainer
                }
            }

            Text {
                text: "YouTube Downloader"
                font.pointSize: Appearance.font.size.large
                font.weight: Font.Medium
                color: Colours.tPalette.m3onSurface
                Layout.fillWidth: true
            }
        }

        // URL Input Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            radius: 16
            color: Colours.tPalette.m3surfaceContainerHighest
            border.width: urlInput.activeFocus ? 2 : 0
            border.color: Colours.tPalette.m3primary

            Behavior on border.width {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                MaterialIcon {
                    text: "link"
                    font.pointSize: 20
                    color: Colours.tPalette.m3onSurfaceVariant
                }

                TextField {
                    id: urlInput
                    Layout.fillWidth: true
                    placeholderText: "Pega la URL del video aquí..."
                    color: Colours.tPalette.m3onSurface
                    font.pointSize: Appearance.font.size.normal
                    enabled: !root.isDownloading
                    selectByMouse: true

                    background: Rectangle {
                        color: "transparent"
                    }

                    onTextChanged: {
                        validateButton.enabled = isValidYouTubeUrl(text);
                    }
                }

                Rectangle {
                    width: 88
                    height: 40
                    radius: 20
                    color: validateButton.enabled ? (validateArea.containsMouse ? Qt.lighter(Colours.tPalette.m3secondaryContainer, 1.1) : Colours.tPalette.m3secondaryContainer) : Colours.tPalette.m3surfaceVariant
                    opacity: validateButton.enabled ? 1 : 0.38

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        id: validateButton
                        anchors.centerIn: parent
                        text: "Verificar"
                        font.pointSize: Appearance.font.size.small
                        font.weight: Font.Medium
                        color: validateButton.enabled ? Colours.tPalette.m3onSecondaryContainer : Colours.tPalette.m3onSurface
                        enabled: false
                    }

                    MouseArea {
                        id: validateArea
                        anchors.fill: parent
                        cursorShape: validateButton.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        hoverEnabled: true
                        enabled: validateButton.enabled

                        onClicked: {
                            videoInfo.visible = true;
                            videoTitle.text = "Título del Video Ejemplo - Tutorial Completo";
                            videoDuration.text = "3:45";
                            videoChannel.text = "Canal Ejemplo";
                        }
                    }
                }
            }
        }

        // Video Info Card
        Rectangle {
            id: videoInfo
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            radius: 16
            color: Colours.tPalette.m3surfaceContainer
            visible: false

            Behavior on visible {
                NumberAnimation {
                    target: videoInfo
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                // Thumbnail
                Rectangle {
                    Layout.preferredWidth: 160
                    Layout.preferredHeight: 90
                    radius: 12
                    color: Colours.tPalette.m3surfaceContainerHighest

                    layer.enabled: true
                    layer.effect: ShaderEffect {
                        property real spread: 0.15
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: Qt.rgba(1, 0, 0, 0.8)
                            }
                            GradientStop {
                                position: 1.0
                                color: Qt.rgba(0.8, 0, 0, 0.9)
                            }
                        }
                    }

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "play_circle"
                        font.pointSize: 32
                        color: "white"
                    }

                    // Duration badge
                    Rectangle {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 6
                        width: durationText.width + 12
                        height: 20
                        radius: 4
                        color: Qt.rgba(0, 0, 0, 0.8)

                        Text {
                            id: durationText
                            anchors.centerIn: parent
                            text: videoDuration.text
                            font.pointSize: Appearance.font.size.tiny
                            font.weight: Font.Bold
                            color: "white"
                        }
                    }
                }

                // Video Details
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 6

                    Text {
                        id: videoTitle
                        Layout.fillWidth: true
                        text: ""
                        font.pointSize: Appearance.font.size.normal
                        font.weight: Font.DemiBold
                        color: Colours.tPalette.m3onSurface
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        spacing: 8

                        MaterialIcon {
                            text: "account_circle"
                            font.pointSize: 14
                            color: Colours.tPalette.m3onSurfaceVariant
                        }

                        Text {
                            id: videoChannel
                            text: ""
                            font.pointSize: Appearance.font.size.small
                            color: Colours.tPalette.m3onSurfaceVariant
                        }
                    }

                    Text {
                        id: videoDuration
                        text: ""
                        visible: false
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }

        // Format & Quality Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            radius: 16
            color: Colours.tPalette.m3surfaceContainerHigh

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "Configuración de descarga"
                    font.pointSize: Appearance.font.size.small
                    font.weight: Font.Medium
                    color: Colours.tPalette.m3onSurfaceVariant
                }

                // Format Selection
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        radius: 12
                        color: mp3Radio.checked ? Colours.tPalette.m3primaryContainer : Colours.tPalette.m3surfaceContainer

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            MaterialIcon {
                                text: "audiotrack"
                                font.pointSize: 18
                                color: mp3Radio.checked ? Colours.tPalette.m3onPrimaryContainer : Colours.tPalette.m3onSurfaceVariant
                            }

                            Text {
                                text: "MP3"
                                font.pointSize: Appearance.font.size.small
                                font.weight: Font.Medium
                                color: mp3Radio.checked ? Colours.tPalette.m3onPrimaryContainer : Colours.tPalette.m3onSurface
                            }
                        }

                        RadioButton {
                            id: mp3Radio
                            anchors.fill: parent
                            checked: true
                            enabled: !root.isDownloading
                            opacity: 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: !root.isDownloading
                            onClicked: mp3Radio.checked = true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        radius: 12
                        color: mp4Radio.checked ? Colours.tPalette.m3secondaryContainer : Colours.tPalette.m3surfaceContainer

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            MaterialIcon {
                                text: "videocam"
                                font.pointSize: 18
                                color: mp4Radio.checked ? Colours.tPalette.m3onSecondaryContainer : Colours.tPalette.m3onSurfaceVariant
                            }

                            Text {
                                text: "MP4"
                                font.pointSize: Appearance.font.size.small
                                font.weight: Font.Medium
                                color: mp4Radio.checked ? Colours.tPalette.m3onSecondaryContainer : Colours.tPalette.m3onSurface
                            }
                        }

                        RadioButton {
                            id: mp4Radio
                            anchors.fill: parent
                            enabled: !root.isDownloading
                            opacity: 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: !root.isDownloading
                            onClicked: mp4Radio.checked = true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        radius: 12
                        color: webmRadio.checked ? Colours.tPalette.m3tertiaryContainer : Colours.tPalette.m3surfaceContainer

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            MaterialIcon {
                                text: "movie"
                                font.pointSize: 18
                                color: webmRadio.checked ? Colours.tPalette.m3onTertiaryContainer : Colours.tPalette.m3onSurfaceVariant
                            }

                            Text {
                                text: "WebM"
                                font.pointSize: Appearance.font.size.small
                                font.weight: Font.Medium
                                color: webmRadio.checked ? Colours.tPalette.m3onTertiaryContainer : Colours.tPalette.m3onSurface
                            }
                        }

                        RadioButton {
                            id: webmRadio
                            anchors.fill: parent
                            enabled: !root.isDownloading
                            opacity: 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: !root.isDownloading
                            onClicked: webmRadio.checked = true
                        }
                    }
                }

                // Quality Selection
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    radius: 12
                    color: Colours.light ? Qt.rgba(0, 0, 0, 0.05) : Qt.rgba(1, 1, 1, 0.05)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        MaterialIcon {
                            text: "high_quality"
                            font.pointSize: 20
                            color: Colours.tPalette.m3onSurfaceVariant
                        }

                        Text {
                            text: "Calidad:"
                            font.pointSize: Appearance.font.size.normal
                            font.weight: Font.Medium
                            color: Colours.tPalette.m3onSurface
                        }

                        ComboBox {
                            id: qualityCombo
                            Layout.fillWidth: true
                            model: mp3Radio.checked ? ["128 kbps", "192 kbps", "256 kbps", "320 kbps"] : ["360p", "480p", "720p", "1080p"]
                            currentIndex: mp3Radio.checked ? 3 : 2
                            enabled: !root.isDownloading

                            background: Rectangle {
                                color: "transparent"
                            }

                            contentItem: Text {
                                text: qualityCombo.displayText
                                font.pointSize: Appearance.font.size.normal
                                font.weight: Font.Medium
                                color: Colours.tPalette.m3primary
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }
        }

        // Download Progress
        Rectangle {
            id: progressContainer
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            radius: 16
            color: Colours.tPalette.m3primaryContainer
            visible: root.isDownloading

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    MaterialIcon {
                        text: "downloading"
                        font.pointSize: 20
                        color: Colours.tPalette.m3onPrimaryContainer

                        RotationAnimator on rotation {
                            from: 0
                            to: 360
                            duration: 2000
                            loops: Animation.Infinite
                            running: root.isDownloading
                        }
                    }

                    Text {
                        text: "Descargando..."
                        color: Colours.tPalette.m3onPrimaryContainer
                        font.pointSize: Appearance.font.size.normal
                        font.weight: Font.Medium
                        Layout.fillWidth: true
                    }

                    Text {
                        text: Math.round(root.downloadProgress * 100) + "%"
                        color: Colours.tPalette.m3primary
                        font.pointSize: Appearance.font.size.medium
                        font.weight: Font.Bold
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: Colours.light ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.1)

                    Rectangle {
                        width: parent.width * root.downloadProgress
                        height: parent.height
                        radius: 4
                        color: Colours.tPalette.m3primary

                        Behavior on width {
                            NumberAnimation {
                                duration: 100
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    MaterialIcon {
                        text: "speed"
                        font.pointSize: 14
                        color: Colours.tPalette.m3onPrimaryContainer
                    }

                    Text {
                        text: "2.5 MB/s"
                        color: Colours.tPalette.m3onPrimaryContainer
                        font.pointSize: Appearance.font.size.small
                        Layout.fillWidth: true
                    }

                    MaterialIcon {
                        text: "schedule"
                        font.pointSize: 14
                        color: Colours.tPalette.m3onPrimaryContainer
                    }

                    Text {
                        text: "15s restantes"
                        color: Colours.tPalette.m3onPrimaryContainer
                        font.pointSize: Appearance.font.size.small
                    }
                }
            }
        }

        // Download Button
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            radius: 28
            color: root.isDownloading ? (downloadBtnArea.containsMouse ? Qt.lighter(Colours.tPalette.m3errorContainer, 1.1) : Colours.tPalette.m3errorContainer) : (downloadBtnArea.containsMouse ? Qt.lighter(Colours.tPalette.m3primary, 1.1) : Colours.tPalette.m3primary)
            opacity: videoInfo.visible ? 1 : 0.38

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 12

                MaterialIcon {
                    text: root.isDownloading ? "close" : "download"
                    font.pointSize: 20
                    color: root.isDownloading ? Colours.tPalette.m3onErrorContainer : Colours.tPalette.m3onPrimary
                }

                Text {
                    text: root.isDownloading ? "Cancelar descarga" : "Iniciar descarga"
                    font.pointSize: Appearance.font.size.normal
                    font.weight: Font.Medium
                    color: root.isDownloading ? Colours.tPalette.m3onErrorContainer : Colours.tPalette.m3onPrimary
                }
            }

            MouseArea {
                id: downloadBtnArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
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
        }

        // Download History
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                MaterialIcon {
                    text: "history"
                    font.pointSize: 16
                    color: Colours.tPalette.m3onSurfaceVariant
                }

                Text {
                    text: "Descargas recientes"
                    font.pointSize: Appearance.font.size.normal
                    font.weight: Font.Medium
                    color: Colours.tPalette.m3onSurface
                    Layout.fillWidth: true
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: historyList
                    spacing: 8

                    model: ListModel {
                        id: historyModel
                    }

                    delegate: Rectangle {
                        required property string title
                        required property string format
                        required property string size

                        width: historyList.width
                        height: 64
                        radius: 12
                        color: historyMouseArea.containsMouse ? Colours.tPalette.m3secondaryContainer : Colours.tPalette.m3surfaceContainerHigh

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 20
                                color: Colours.tPalette.m3successContainer

                                MaterialIcon {
                                    anchors.centerIn: parent
                                    text: "check_circle"
                                    color: Colours.tPalette.m3onSuccessContainer
                                    font.pointSize: 18
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: title
                                    color: Colours.tPalette.m3onSurface
                                    font.pointSize: Appearance.font.size.normal
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: format + " • " + size
                                    color: Colours.tPalette.m3onSurfaceVariant
                                    font.pointSize: Appearance.font.size.small
                                }
                            }

                            Rectangle {
                                width: 36
                                height: 36
                                radius: 18
                                color: historyMouseArea.containsMouse ? Colours.tPalette.m3tertiaryContainer : "transparent"

                                MaterialIcon {
                                    anchors.centerIn: parent
                                    text: "folder_open"
                                    color: Colours.tPalette.m3onSurfaceVariant
                                    font.pointSize: 18
                                }
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
