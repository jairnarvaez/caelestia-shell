// ============================================
// AI.qml
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
        text: "Chat con IA"
        font.pointSize: Appearance.font.size.large
        font.bold: true
        color: Colours.palette.m3onSurface
    }

    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ListView {
            id: chatView
            spacing: Appearance.padding.small

            model: ListModel {
                id: chatModel

                Component.onCompleted: {
                    append({
                        message: "¡Hola! Soy tu asistente IA. ¿En qué puedo ayudarte?",
                        isUser: false
                    });
                }
            }

            delegate: ChatMessage {
                required property string message
                required property bool isUser

                width: chatView.width
                messageText: message
                fromUser: isUser
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.padding.small

        TextField {
            id: chatInput
            Layout.fillWidth: true
            placeholderText: "Escribe tu mensaje..."
            color: Colours.palette.m3onSurface

            onAccepted: root.sendMessage()
        }

        Button {
            text: "Enviar"
            enabled: chatInput.text.trim() !== ""
            onClicked: root.sendMessage()
        }
    }

    function sendMessage() {
        if (chatInput.text.trim() === "")
            return;
        const userMsg = chatInput.text;
        chatModel.append({
            message: userMsg,
            isUser: true
        });
        chatInput.text = "";

        // Simular respuesta de IA con delay
        Qt.callLater(() => {
            chatModel.append({
                message: generateResponse(userMsg),
                isUser: false
            });
        });
    }

    function generateResponse(userMessage) {
        const responses = ["Interesante pregunta. Déjame pensar...", "Entiendo lo que dices. " + userMessage, "Esa es una buena observación.", "Gracias por compartir eso conmigo.", "¿Podrías darme más detalles sobre eso?"];
        return responses[Math.floor(Math.random() * responses.length)];
    }
}
