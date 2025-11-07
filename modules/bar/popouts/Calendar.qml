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

	property bool requireDaySelection: true
	
    required property Item wrapper

    spacing: Appearance.spacing.small
    width: Config.bar.sizes.calendarWidth
    implicitWidth: Config.bar.sizes.calendarWidth
    implicitHeight: 280

	anchors.margins: Appearance.padding.large

    // Calendar state
    property var calendarState: QtObject {
        property var currentDate: new Date()
        property var selectedDate: null
        property bool eventsExpanded: false
        property bool showingEventForm: false
        
        function setCurrentDate(date) {
            currentDate = date;
        }
        
        function setSelectedDate(date) {
            selectedDate = date;
        }
        
        function toggleEventsExpanded() {
            eventsExpanded = !eventsExpanded;
        }
        
        function openEventForm() {
            showingEventForm = true;
        }
        
        function closeEventForm() {
            showingEventForm = false;
        }
    }

    readonly property int currMonth: calendarState.currentDate.getMonth()
    readonly property int currYear: calendarState.currentDate.getFullYear()

    // Container for carousel views
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        implicitHeight: calendarColumn.implicitHeight

        clip: true

        // Calendar view
        ColumnLayout {
            id: calendarColumn
            
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            
            spacing: Appearance.spacing.small

            // Transform for carousel effect
            transform: Translate {
                x: root.calendarState.showingEventForm ? -root.width : 0
                Behavior on x {
                    Anim {
                        duration: Appearance.anim.durations.expressiveDefaultSpatial
                        easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                    }
                }
            }

            // Header with month/year and navigation
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                Item {
                    implicitWidth: implicitHeight
                    implicitHeight: prevMonthText.implicitHeight + Appearance.padding.small * 2

                    StateLayer {
                        radius: Appearance.rounding.full

                        function onClicked(): void {
                            root.calendarState.setCurrentDate(new Date(root.currYear, root.currMonth - 1, 1));
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
                            root.calendarState.setCurrentDate(new Date());
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
                            root.calendarState.setCurrentDate(new Date(root.currYear, root.currMonth + 1, 1));
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
                                root.calendarState.setSelectedDate(dayItem.model.date);
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
			    visible: root.requireDaySelection ? true : (root.calendarState.selectedDate !== null)
			    opacity: root.requireDaySelection ? 1 : (root.calendarState.selectedDate !== null ? 1 : 0)

                Behavior on opacity {
                    Anim {}
                }

                // Header with date and add button
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    StyledText {
                        Layout.fillWidth: true
                        text: {
                            if (!root.calendarState.selectedDate) return "";
                            const date = root.calendarState.selectedDate;
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
                                root.calendarState.openEventForm();
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
                    Layout.preferredHeight: root.calendarState.eventsExpanded ? 240 : 120
                    
                    color: Colours.palette.m3surfaceContainerLow
                    radius: Appearance.rounding.normal

                    Behavior on Layout.preferredHeight {
                        Anim {}
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
                            root.calendarState.toggleEventsExpanded();
                        }
                    }

                    MaterialIcon {
                        id: expandIcon

                        anchors.centerIn: parent
                        text: root.calendarState.eventsExpanded ? "expand_less" : "expand_more"
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.large
                        font.weight: 700
                    }
                }
            }
        }

        // Event form view
        ColumnLayout {
            id: eventFormColumn
            
            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            
            spacing: Appearance.spacing.medium

            // Transform for carousel effect
            transform: Translate {
                x: root.calendarState.showingEventForm ? 0 : root.width
                Behavior on x {
                    Anim {
                        duration: Appearance.anim.durations.expressiveDefaultSpatial
                        easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
                    }
                }
            }
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small
                
                Item {
                    implicitWidth: implicitHeight
                    implicitHeight: backIcon.implicitHeight + Appearance.padding.small * 2
                    
                    StateLayer {
                        radius: Appearance.rounding.full
                        
                        function onClicked(): void {
                            root.calendarState.closeEventForm();
                        }
                    }
                    
                    MaterialIcon {
                        id: backIcon
                        
                        anchors.centerIn: parent
                        text: "arrow_forward"
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.normal
                        font.weight: 700
                    }
                }
                
                StyledText {
                    Layout.fillWidth: true
                    text: "Nuevo Evento"
                    color: Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.large
                    font.weight: 600
                }
            }
            
            // Form fields
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.normal
                
                // Title field
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.tiny
                    
                    StyledText {
                        text: "Título"
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.small
                        font.weight: 500
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        placeholderText: "Nombre del evento"
                        color: Colours.palette.m3onSurface
                        background: StyledRect {
                            color: Colours.palette.m3surfaceContainerHighest
                            radius: Appearance.rounding.small
                        }
                    }
                }
                
                // Date field
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.tiny
                    
                    StyledText {
                        text: "Fecha"
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.small
                        font.weight: 500
                    }
                    
                    StyledText {
                        text: {
                            if (!root.calendarState.selectedDate) return "";
                            const date = root.calendarState.selectedDate;
                            const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
                            return date.toLocaleDateString(Qt.locale(), options);
                        }
                        color: Colours.palette.m3onSurface
                        font.pointSize: Appearance.font.size.normal
                        font.capitalization: Font.Capitalize
                    }
                }
                
                // Time field
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.tiny
                    
                    StyledText {
                        text: "Hora"
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.small
                        font.weight: 500
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        placeholderText: "00:00"
                        color: Colours.palette.m3onSurface
                        background: StyledRect {
                            color: Colours.palette.m3surfaceContainerHighest
                            radius: Appearance.rounding.small
                        }
                    }
                }
                
                // Description field
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.tiny
                    
                    StyledText {
                        text: "Descripción"
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.small
                        font.weight: 500
                    }
                    
                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        placeholderText: "Agrega una descripción..."
                        color: Colours.palette.m3onSurface
                        wrapMode: TextArea.Wrap
                        background: StyledRect {
                            color: Colours.palette.m3surfaceContainerHighest
                            radius: Appearance.rounding.small
                        }
                    }
                }
            }
            
            Item {
                Layout.fillHeight: true
            }
            
            // Action buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small
                
                Item {
                    Layout.fillWidth: true
                    implicitHeight: cancelText.implicitHeight + Appearance.padding.normal * 2
                    
                    StateLayer {
                        radius: Appearance.rounding.small
                        
                        function onClicked(): void {
                            root.calendarState.closeEventForm();
                        }
                    }
                    
                    StyledRect {
                        anchors.fill: parent
                        color: Colours.palette.m3surfaceContainerHighest
                        radius: Appearance.rounding.small
                    }
                    
                    StyledText {
                        id: cancelText
                        anchors.centerIn: parent
                        text: "Cancelar"
                        color: Colours.palette.m3onSurface
                        font.pointSize: Appearance.font.size.normal
                        font.weight: 500
                    }
                }
                
                Item {
                    Layout.fillWidth: true
                    implicitHeight: saveText.implicitHeight + Appearance.padding.normal * 2
                    
                    StateLayer {
                        radius: Appearance.rounding.small
                        
                        function onClicked(): void {
                            // TODO: Guardar evento
                            root.calendarState.closeEventForm();
                        }
                    }
                    
                    StyledRect {
                        anchors.fill: parent
                        color: Colours.palette.m3primary
                        radius: Appearance.rounding.small
                    }
                    
                    StyledText {
                        id: saveText
                        anchors.centerIn: parent
                        text: "Guardar"
                        color: Colours.palette.m3onPrimary
                        font.pointSize: Appearance.font.size.normal
                        font.weight: 500
                    }
                }
            }
        }
    }
}
