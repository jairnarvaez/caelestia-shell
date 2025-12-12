pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.components.controls
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root

    spacing: Appearance.spacing.small
    width: 280
    implicitWidth: 280
    implicitHeight: 280

    anchors.margins: Appearance.padding.large

    property var state: QtObject {
        property var currentDate: new Date()
        property var selectedDate: null
        property bool eventsExpanded: false
        
        function setCurrentDate(date) {
            currentDate = date;
        }
        
        function setSelectedDate(date) {
            selectedDate = date;
        }
        
        function toggleEventsExpanded() {
            eventsExpanded = !eventsExpanded;
        }
    }

    readonly property int currMonth: state.currentDate.getMonth()
    readonly property int currYear: state.currentDate.getFullYear()

    RowLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        Item {
            implicitWidth: implicitHeight
            implicitHeight: prevMonthText.implicitHeight + Appearance.padding.small * 2

            StateLayer {
                radius: Appearance.rounding.full

                function onClicked(): void {
                    root.state.setCurrentDate(new Date(root.currYear, root.currMonth - 1, 1));
                }
            }

            MaterialIcon {
                id: prevMonthText

                anchors.centerIn: parent
                text: "chevron_left"
                color: Colours.palette.m3tertiary
                font.pointSize: Appearance.font.size.normal
                font.weight: 700
            }
        }

        Item {
            Layout.fillWidth: true

            implicitWidth: monthYearDisplay.implicitWidth + Appearance.padding.small * 2
            implicitHeight: monthYearDisplay.implicitHeight + Appearance.padding.small * 2

            StateLayer {
                anchors.fill: monthYearDisplay
                anchors.margins: -Appearance.padding.small
                anchors.leftMargin: -Appearance.padding.normal
                anchors.rightMargin: -Appearance.padding.normal

                radius: Appearance.rounding.full
                disabled: {
                    const now = new Date();
                    return root.currMonth === now.getMonth() && root.currYear === now.getFullYear();
                }

                function onClicked(): void {
                    root.state.setCurrentDate(new Date());
                }
            }

            StyledText {
                id: monthYearDisplay

                anchors.centerIn: parent
                text: grid.title
                color: Colours.palette.m3primary
                font.pointSize: Appearance.font.size.normal
                font.weight: 500
                font.capitalization: Font.Capitalize
            }
        }

        Item {
            implicitWidth: implicitHeight
            implicitHeight: nextMonthText.implicitHeight + Appearance.padding.small * 2

            StateLayer {
                radius: Appearance.rounding.full

                function onClicked(): void {
                    root.state.setCurrentDate(new Date(root.currYear, root.currMonth + 1, 1));
                }
            }

            MaterialIcon {
                id: nextMonthText

                anchors.centerIn: parent
                text: "chevron_right"
                color: Colours.palette.m3tertiary
                font.pointSize: Appearance.font.size.normal
                font.weight: 700
            }
        }
    }

    // Day of week headers
    DayOfWeekRow {
        Layout.fillWidth: true
        locale: grid.locale

        delegate: StyledText {
            required property var model

            horizontalAlignment: Text.AlignHCenter
            text: model.shortName
            font.weight: 500
            color: (model.day === 0 || model.day === 6) ? Colours.palette.m3secondary : Colours.palette.m3onSurfaceVariant
        }
    }

    // Calendar grid
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.max(grid.implicitHeight, 200)
        implicitHeight: Math.max(grid.implicitHeight, 200)

        MonthGrid {
            id: grid

            month: root.currMonth
            year: root.currYear

            anchors.fill: parent
            width: parent.width
            height: parent.height

            spacing: 3
            locale: Qt.locale()

            delegate: Item {
                id: dayItem

                required property var model

                implicitWidth: implicitHeight
                implicitHeight: text.implicitHeight + Appearance.padding.small * 2

                Rectangle {
                    id: hoverFrame
                    anchors.fill: parent
                    color: "transparent"
                    border.width: mouseArea.containsMouse ? 1.5 : 0
                    border.color: Colours.palette.m3secondary
                    radius: 6
                }

                StyledText {
                    id: text

                    anchors.centerIn: parent

                    horizontalAlignment: Text.AlignHCenter
                    text: grid.locale.toString(dayItem.model.day)
                    color: {
                        const dayOfWeek = dayItem.model.date.getUTCDay();
                        if (dayOfWeek === 0 || dayOfWeek === 6)
                            return Colours.palette.m3secondary;

                        return Colours.palette.m3onSurfaceVariant;
                    }
                    opacity: dayItem.model.today || dayItem.model.month === grid.month ? 1 : 0.4
                    font.pointSize: Appearance.font.size.normal
                    font.weight: 500
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        root.state.setSelectedDate(dayItem.model.date);
                    }
                }
            }
        }

        // Today indicator
        StyledRect {
            id: todayIndicator

            readonly property Item todayItem: grid.contentItem.children.find(c => c.model.today) ?? null
            property Item today

            onTodayItemChanged: {
                if (todayItem)
                    today = todayItem;
            }

            x: today ? today.x + (today.width - implicitWidth) / 2 : 0
            y: today?.y ?? 0

            implicitWidth: today?.implicitWidth ?? 0
            implicitHeight: today?.implicitHeight ?? 0

            clip: true
            radius: Appearance.rounding.full
            color: Colours.palette.m3primary

            opacity: todayItem ? 1 : 0
            scale: todayItem ? 1 : 0.7

            Colouriser {
                x: -todayIndicator.x
                y: -todayIndicator.y

                implicitWidth: grid.width
                implicitHeight: grid.height

                source: grid
                sourceColor: Colours.palette.m3onSurface
                colorizationColor: Colours.palette.m3onPrimary
            }

            Behavior on opacity {
                Anim {}
            }

            Behavior on scale {
                Anim {}
            }

            Behavior on x {
                Anim {
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                }
            }

            Behavior on y {
                Anim {
                    duration: Appearance.anim.durations.expressiveDefaultSpatial
                    easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                }
            }
        }
    }

    // Events section
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Appearance.spacing.small
        visible: root.state.selectedDate !== null
        opacity: root.state.selectedDate !== null ? 1 : 0

        Behavior on opacity {
	        Anim {
				duration: Appearance.anim.durations.small
				easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
			}
        }

        // Header with date and add button
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            StyledText {
                Layout.fillWidth: true
                text: {
                    if (!root.state.selectedDate) return "";
                    const date = root.state.selectedDate;
                    const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
                    return date.toLocaleDateString(Qt.locale(), options);
                }
                color: Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.normal
                font.weight: 500
                font.capitalization: Font.Capitalize
            }

            Item {
                implicitWidth: implicitHeight
                implicitHeight: addIcon.implicitHeight + Appearance.padding.small * 2

                StateLayer {
                    radius: Appearance.rounding.full

                    function onClicked(): void {
                        // TODO: Implementar agregar evento
                        console.log("Agregar evento");
                    }
                }

                MaterialIcon {
                    id: addIcon

                    anchors.centerIn: parent
                    text: "add"
                    color: Colours.palette.m3primary
                    font.pointSize: Appearance.font.size.large
                    font.weight: 700
                }
            }
        }

        // Events list
        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: root.state.eventsExpanded ? 240 : 120
            
            color: Colours.palette.m3surfaceContainerLow
            radius: Appearance.rounding.normal

            Behavior on Layout.preferredHeight {
               Anim {
	                duration: Appearance.anim.durations.small
                    easing.bezierCurve: Appearance.anim.curves.standard
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Appearance.spacing.small

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    text: "event_busy"
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.extraLarge
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No hay eventos para este día"
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.normal
                }
            }
        }

        // Expand/Collapse button
        Item {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: implicitHeight
            implicitHeight: expandIcon.implicitHeight + Appearance.padding.small * 2

            StateLayer {
                radius: Appearance.rounding.full

                function onClicked(): void {
                    root.state.toggleEventsExpanded();
                }
            }

            MaterialIcon {
                id: expandIcon

                anchors.centerIn: parent
                text: root.state.eventsExpanded ? "expand_less" : "expand_more"
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.large
                font.weight: 700
            }
        }
    }
}