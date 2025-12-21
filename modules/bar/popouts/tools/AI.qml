// ============================================
// AI.qml - Material Design 3
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

    property bool isTyping: false

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        RowLayout {
            spacing: Appearance.spacing.normal

            StyledRect {
                implicitWidth: implicitHeight
                implicitHeight: headerIcon.implicitHeight + Appearance.padding.large
                radius: Appearance.rounding.full
                color: Colours.palette.m3secondaryContainer

                MaterialIcon {
                    id: headerIcon
                    anchors.centerIn: parent
                    text: "psychology"
                    color: Colours.palette.m3onSecondaryContainer
                    font.pointSize: Appearance.font.size.large
                }
            }

            Text {
                text: "Asistente IA"
                font.pointSize: Appearance.font.size.normal
                font.weight: Font.Medium
                color: Colours.tPalette.m3onSurface
                Layout.fillWidth: true
            }

            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: optionsArea.containsMouse ? Colours.tPalette.m3surfaceContainerHighest : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "more_vert"
                    font.pointSize: 18
                    color: Colours.tPalette.m3onSurfaceVariant
                }

                MouseArea {
                    id: optionsArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                }
            }
        }

        // Chat Area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colours.tPalette.m3surface

            ScrollView {
                anchors.fill: parent
                anchors.margins: 5
                anchors.bottomMargin: 12
                clip: true

                ListView {
                    id: chatView
                    spacing: 5
                    verticalLayoutDirection: ListView.BottomToTop

                    model: ListModel {
                        id: chatModel
                        Component.onCompleted: {
                            append({
                                message: "¡Hola! Soy tu asistente IA. ¿En qué puedo ayudarte hoy?",
                                isUser: false,
                                timestamp: "Ahora"
                            });
                        }
                    }

                    delegate: Item {
                        required property string message
                        required property bool isUser
                        required property string timestamp

                        width: chatView.width
                        height: messageContainer.height + 8

                        RowLayout {
                            id: messageContainer
                            width: parent.width
                            spacing: 5

                            Item {
                                Layout.preferredWidth: isUser ? parent.width * 0.15 : 0
                                Layout.preferredHeight: 1
                            }

                            // Message Bubble
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.maximumWidth: parent.width * 0.75
                                spacing: 4

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: messageText.implicitHeight + 24
                                    radius: 16

                                    color: isUser ? Colours.tPalette.m3primaryContainer : Colours.tPalette.m3surfaceContainerHighest

                                    // Tail for message bubble
                                    Canvas {
                                        width: 12
                                        height: 12
                                        anchors.left: isUser ? undefined : parent.left
                                        anchors.right: isUser ? parent.right : undefined
                                        anchors.top: parent.top
                                        anchors.leftMargin: isUser ? 0 : -6
                                        anchors.rightMargin: isUser ? -6 : 0
                                        anchors.topMargin: 8

                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.reset();
                                            ctx.fillStyle = isUser ? Colours.tPalette.m3primaryContainer : Colours.tPalette.m3surfaceContainerHighest;
                                            ctx.beginPath();

                                            if (isUser) {
                                                ctx.moveTo(0, 0);
                                                ctx.lineTo(12, 0);
                                                ctx.lineTo(0, 12);
                                            } else {
                                                ctx.moveTo(12, 0);
                                                ctx.lineTo(0, 0);
                                                ctx.lineTo(12, 12);
                                            }

                                            ctx.closePath();
                                            ctx.fill();
                                        }
                                    }

                                    Text {
                                        id: messageText
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        text: message
                                        wrapMode: Text.Wrap
                                        color: isUser ? Colours.tPalette.m3onPrimaryContainer : Colours.tPalette.m3onSurface
                                        font.pointSize: Appearance.font.size.small
                                        lineHeight: 1.4
                                    }
                                }

                                Text {
                                    Layout.alignment: isUser ? Qt.AlignRight : Qt.AlignLeft
                                    text: timestamp
                                    font.pointSize: Appearance.font.size.tiny
                                    color: Colours.tPalette.m3onSurfaceVariant
                                    opacity: 0.7
                                }
                            }

                            Item {
                                Layout.preferredWidth: isUser ? 0 : parent.width * 0.15
                                Layout.preferredHeight: 1
                            }
                        }
                    }

                    // Typing indicator
                    add: Transition {
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            property: "scale"
                            from: 0.8
                            to: 1
                            duration: 300
                            easing.type: Easing.OutBack
                        }
                    }
                }
            }

            // Typing Indicator
            Rectangle {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: 20
                width: 80
                height: 48
                radius: 24
                color: Colours.tPalette.m3surfaceContainerHighest
                visible: root.isTyping

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Repeater {
                        model: 3

                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: Colours.tPalette.m3onSurfaceVariant

                            SequentialAnimation on y {
                                loops: Animation.Infinite
                                running: root.isTyping

                                PauseAnimation {
                                    duration: index * 150
                                }
                                NumberAnimation {
                                    from: 0
                                    to: -6
                                    duration: 400
                                    easing.type: Easing.InOutSine
                                }
                                NumberAnimation {
                                    from: -6
                                    to: 0
                                    duration: 400
                                    easing.type: Easing.InOutSine
                                }
                            }
                        }
                    }
                }
            }
        }

        // Input Area
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: Colours.tPalette.m3surfaceContainer
            radius: 28

            // Rectangle {
            //     anchors.fill: parent
            //     anchors.topMargin: -28
            //     anchors.bottomMargin: 0
            //     color: parent.color
            //     radius: parent.radius
            // }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Attach button
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: attachArea.containsMouse ? Colours.tPalette.m3surfaceContainerHighest : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "attach_file"
                        font.pointSize: 18
                        color: Colours.tPalette.m3onSurfaceVariant
                    }

                    MouseArea {
                        id: attachArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                    }
                }

                // Input field
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    radius: 24
                    color: Colours.tPalette.m3surfaceContainerHighest
                    border.width: chatInput.activeFocus ? 2 : 0
                    border.color: Colours.tPalette.m3primary

                    Behavior on border.width {
                        NumberAnimation {
                            duration: 150
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 12
                        spacing: 8

                        TextField {
                            id: chatInput
                            Layout.fillWidth: true
                            placeholderText: "Escribe un mensaje..."
                            color: Colours.tPalette.m3onSurface
                            font.pointSize: Appearance.font.size.normal
                            selectByMouse: true
                            verticalAlignment: TextInput.AlignVCenter

                            background: Rectangle {
                                color: "transparent"
                            }

                            onAccepted: root.sendMessage()

                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Return && !event.modifiers) {
                                    root.sendMessage();
                                    event.accepted = true;
                                }
                            }
                        }

                        // Emoji button
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: emojiArea.containsMouse ? Colours.tPalette.m3secondaryContainer : "transparent"

                            MaterialIcon {
                                anchors.centerIn: parent
                                text: "mood"
                                font.pointSize: 18
                                color: Colours.tPalette.m3onSurfaceVariant
                            }

                            MouseArea {
                                id: emojiArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                            }
                        }
                    }
                }

                // Send button
                Rectangle {
                    width: 48
                    height: 48
                    radius: 24
                    color: chatInput.text.trim() !== "" ? (sendArea.containsMouse ? Qt.lighter(Colours.tPalette.m3primary, 1.1) : Colours.tPalette.m3primary) : Colours.tPalette.m3surfaceContainerHighest
                    opacity: chatInput.text.trim() !== "" ? 1 : 0.38

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "send"
                        font.pointSize: 18
                        color: chatInput.text.trim() !== "" ? Colours.tPalette.m3onPrimary : Colours.tPalette.m3onSurfaceVariant

                        rotation: -45
                    }

                    MouseArea {
                        id: sendArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        enabled: chatInput.text.trim() !== ""

                        onClicked: root.sendMessage()
                    }

                    // Press animation
                    scale: sendArea.pressed ? 0.9 : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: typingTimer
        interval: 1500
        onTriggered: {
            root.isTyping = false;
            const responses = ["Interesante pregunta. Basándome en mi conocimiento, puedo decirte que...", "Entiendo perfectamente lo que mencionas. Permíteme elaborar sobre eso...", "Esa es una excelente observación. Aquí hay algunos puntos clave...", "Gracias por compartir eso. Mi análisis indica que...", "¿Podrías darme más contexto sobre eso? Mientras tanto, te puedo decir..."];

            chatModel.insert(0, {
                message: responses[Math.floor(Math.random() * responses.length)],
                isUser: false,
                timestamp: ""
            });
        }
    }

    function sendMessage() {
        if (chatInput.text.trim() === "")
            return;

        const userMsg = chatInput.text;
        chatModel.insert(0, {
            message: userMsg,
            isUser: true,
            timestamp: ""
        });

        chatInput.text = "";

        // Show typing indicator
        root.isTyping = true;
        typingTimer.restart();
    }
}
