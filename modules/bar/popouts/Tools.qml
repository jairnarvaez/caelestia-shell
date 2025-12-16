// Tools.qml
pragma ComponentBehavior: Bound
import qs.components
import qs.components.controls
import qs.services
import qs.config
import qs.modules.bar.popouts.tools
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    property int currentIndex: 0

    readonly property var tools: [
        {
            icon: "translate",
            name: "Traductor",
            component: "Translate.qml"
        },
        {
            icon: "colorize",
            name: "Color Picker",
            component: "ColorPicker.qml"
        },
        {
            icon: "robot",
            name: "Chat IA",
            component: "AI.qml"
        },
        {
            icon: "youtube_activity",
            name: "Youtube Downloader",
            component: "YoutubeDowloader.qml"
        }
    ]

    RowLayout {
        id: layout
        spacing: Appearance.padding.normal

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: root.currentIndex == -1 ? 1 : 0
            color: Colours.palette.m3outlineVariant
            radius: 1
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "transparent"
                }
                GradientStop {
                    position: 0.5
                    color: Colours.palette.m3outlineVariant
                }
                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }
        }

        // Columna de iconos
        ColumnLayout {
            spacing: Appearance.padding.scale

            Repeater {
                model: root.tools

                delegate: IconButton {
                    required property var modelData
                    required property int index

                    iconName: modelData.icon
                    isActive: root.currentIndex === index

                    onHovered: {
                        root.currentIndex = index;
                    }
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: root.currentIndex == -1 ? 0 : 1
            color: Colours.palette.m3outlineVariant
            radius: 1
            gradient: Gradient {
                GradientStop {
                    position: 0//root.currentIndex == -1 ? 0.0 : 0.25
                    color: "transparent"
                }
                GradientStop {
                    position: 0.5
                    color: Colours.palette.m3outlineVariant
                }
                GradientStop {
                    position: 1.0//root.currentIndex == -1 ? 1.0 : 0.75
                    color: "transparent"
                }
            }
        }

        // Panel de contenido
        Rectangle {
            Layout.preferredWidth: 350
            Layout.preferredHeight: 450
            radius: 12
            color: Colours.palette.m3surface
            border.color: Colours.palette.m3outlineVariant
            border.width: 0
            visible: root.currentIndex >= 0

            clip: true

            Behavior on visible {
                NumberAnimation {
                    duration: 200
                }
            }

            StackLayout {
                anchors.fill: parent
                anchors.margins: Appearance.padding.normal
                currentIndex: root.currentIndex

                TranslatePopout {}
                ColorPicker {}
                AI {}
                YoutubeDowloader {}
            }
        }
    }
}
