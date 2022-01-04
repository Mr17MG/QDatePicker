import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QDatePicker

Item {
    id: root

    required width
    required height

    required property string locale
    required property string calendar

    required property ApplicationWindow mainWindow

    property string placeholderText: ""
    property string selectedDateText: ""
    required property color primaryColor

    property date selectedDate
    property date minDate
    property date maxDate

    property bool hasTimeSelection: false

    function reset()
    {
        root.selectedDate = new Date("Invalid Date")
        root.selectedDateText  = ''
    }

    QDatePicker {
        id: qDatePicker

        locale: root.locale
        calendar: root.calendar
    }

    Rectangle {
        color: "transparent"
        anchors.fill: parent
        radius: 10
        border {
            width: 1
            color: "#CDCDCD"
        }
    }

    Label {
        text: root.selectedDateText !== "" ? root.selectedDateText
                                           : root.placeholderText
        width: parent.width
        height: parent.height
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Qt.ElideRight
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            dateTimeDialog.open()
        }
    }

    Dialog {
        id: dateTimeDialog

        modal: true
        width: 350
        height: 400
        bottomPadding: 0
        topPadding: 0

        parent: mainWindow.contentItem
        anchors{
            centerIn: parent
        }

        property bool isTimeSelection: false
        property bool isMinuteSelction: false

        property date tempSelectedDate: root.selectedDate.toString() !== "Invalid Date" ? new Date(root.selectedDate)
                                                                                        : new Date();

        onTempSelectedDateChanged: {
            if (minDate.toString() !== "Invalid Date" && minDate > tempSelectedDate)
                tempSelectedDate = minDate;
            else if (maxDate.toString() !== "Invalid Date" && maxDate < tempSelectedDate)
                tempSelectedDate = maxDate;
        }

        function setLocaleDate(localeYear,localeMonth,localeDay)
        {
            var GregorianDate = qDatePicker.localeToGregorianDate(localeYear,localeMonth,localeDay)
            dateTimeDialog.tempSelectedDate = new Date(GregorianDate)
        }

        function isDateInRange(gregorianDate)
        {
            var minDate = root.minDate
            var maxDate = root.maxDate

            if(dateTimeDialog.isTimeSelection === false)
            {
                minDate = new Date(minDate.setHours(0,0,0,0))
                maxDate = new Date(maxDate.setHours(23,59,59,0))
            }

            if(minDate.toString() !== "Invalid Date" && maxDate.toString() !== "Invalid Date")
                return minDate <= gregorianDate && gregorianDate <= maxDate
            if (minDate.toString() !== "Invalid Date")
                return minDate <= gregorianDate
            else if (maxDate.toString() !== "Invalid Date")
                return gregorianDate <= maxDate

            return true
        }

        header: Pane {
            id: headerRect

            property var selectedDateString: qDatePicker.calendar !=="" ? qDatePicker.dateToLocalDateString(dateTimeDialog.tempSelectedDate.getFullYear(),
                                                                                                            dateTimeDialog.tempSelectedDate.getMonth()+1, // because getMonth() is in 0 to 11
                                                                                                            dateTimeDialog.tempSelectedDate.getDate()
                                                                                                            )
                                                                        : []

            property int selectedYear: Number(selectedDateString[0])??0;
            property int selectedMonth: Number(selectedDateString[1])??0;
            property int selectedDay: Number(selectedDateString[2])??0;

            property string selectedDayWeekName: selectedDateString[3]??"";
            property string selectedMonthName: selectedDateString[4]??"";

            height: 70
            padding: 0
            background: Rectangle{
                color: root.primaryColor
            }


            ColumnLayout{
                // This Header will show when user choosing date

                visible: enabled
                enabled: !dateTimeDialog.isTimeSelection
                layoutDirection: Qt.locale(qDatePicker.locale).textDirection

                anchors{
                    fill: parent
                    margins: 10
                }

                Label{
                    text: headerRect.selectedYear
                    horizontalAlignment: Text.AlignHCenter
                }
                Label{
                    text:("%1 %2 %3").arg(headerRect.selectedDayWeekName)
                    .arg(headerRect.selectedDay)
                    .arg(headerRect.selectedMonthName)

                    horizontalAlignment: Text.AlignHCenter
                }
            }

            RowLayout {
                // This Header will show when user choosing time
                visible: enabled
                enabled: dateTimeDialog.isTimeSelection

                anchors{
                    centerIn: parent
                }

                ButtonGroup { id: groupTime }

                Button{
                    text: dateTimeDialog.tempSelectedDate.getHours().toString().replace(/^(\d)$/, '0$1')
                    flat: true
                    checkable: true
                    checked: !dateTimeDialog.isMinuteSelction
                    ButtonGroup.group: groupTime

                    font{
                        pixelSize: 14
                        bold: true
                    }

                    onClicked: dateTimeDialog.isMinuteSelction = false

                }
                Label {
                    id: colonLbl
                    text: ":"
                    font{
                        pixelSize: 14
                        bold: true
                    }
                }
                Button{
                    text: dateTimeDialog.tempSelectedDate.getMinutes().toString().replace(/^(\d)$/, '0$1')
                    flat: true
                    checkable: true
                    checked: dateTimeDialog.isMinuteSelction
                    ButtonGroup.group: groupTime
                    font{
                        pixelSize: 14
                        bold: true
                    }
                    onClicked: dateTimeDialog.isMinuteSelction = true
                }

            }
        }

        Popup{
            id: monthSelectorPopup

            x: (monthTxt.width - width)/2
            y:monthTxt.height
            parent: monthTxt
            width: 100
            height: 300
            enabled: !dateTimeDialog.isTimeSelection

            Flickable{
                anchors.fill: parent
                clip: true
                contentHeight: column.height

                Column{
                    id:column
                    width: parent.width
                    Repeater{
                        model: qDatePicker.calendar!=="" ? qDatePicker.getShortMonthsName()
                                                         : []
                        delegate: Button{
                            text: modelData
                            enabled: dateTimeDialog.isDateInRange (
                                         qDatePicker.localeToGregorianDate (headerRect.selectedYear,
                                                                            index+1,
                                                                            headerRect.selectedDay
                                                                            )
                                         )
                            height: 60
                            width: parent.width
                            flat: !highlighted
                            highlighted: text === headerRect.selectedMonthName
                            onClicked: {
                                dateTimeDialog.setLocaleDate(headerRect.selectedYear,
                                                             index+1,
                                                             headerRect.selectedDay
                                                             )
                                monthSelectorPopup.close()
                            }
                        }
                    }
                }
            }
        }

        Popup{
            id: yearSelectorPopup

            x: (yearTxt.width - width)/2
            y:yearTxt.height
            parent: yearTxt
            width: 100
            height: 300
            enabled: !dateTimeDialog.isTimeSelection

            Flickable{
                anchors.fill: parent
                clip: true
                contentHeight: yearColumn.height

                Column{
                    id: yearColumn
                    width: parent.width
                    Repeater{
                        model: [-3,-2,-1,0,1,2,3]
                        delegate: Button{
                            text: headerRect.selectedYear + modelData
                            enabled: dateTimeDialog.isDateInRange (
                                         qDatePicker.localeToGregorianDate (Number(text),
                                                                            headerRect.selectedMonth,
                                                                            headerRect.selectedDay)
                                         )
                            height: 60
                            width: parent.width
                            flat: !highlighted
                            highlighted: Number(text) === headerRect.selectedYear
                            onClicked: {
                                dateTimeDialog.setLocaleDate(Number(text),headerRect.selectedMonth,headerRect.selectedDay)
                                yearSelectorPopup.close()
                            }
                        }
                    }
                }
            }
        }

        Flow{
            anchors.fill: parent

            Flow{
                id: dateSelectionItem

                width: parent.width
                height: parent.height - btnsLayout.height
                enabled: !dateTimeDialog.isTimeSelection
                visible: enabled
                spacing: 5

                RowLayout{
                    id: dateRow
                    width: parent.width
                    height: 30
                    layoutDirection: Qt.locale(qDatePicker.locale).textDirection

                    RoundButton {
                        text: dateRow.layoutDirection === Qt.RightToLeft? ">":"<"
                        flat: true
                        highlighted: true
                        font{
                            bold: true
                        }
                        enabled: dateTimeDialog.isDateInRange(qDatePicker.localeToGregorianDate(headerRect.selectedYear,
                                                                                                headerRect.selectedMonth-1,
                                                                                                headerRect.selectedDay
                                                                                                ))
                        onClicked: {
                            dateTimeDialog.setLocaleDate(headerRect.selectedYear,
                                                         headerRect.selectedMonth-1,
                                                         headerRect.selectedDay
                                                         )
                        }
                    }

                    RoundButton {
                        id: monthTxt
                        text: headerRect.selectedMonthName
                        Layout.fillWidth: true
                        flat: true
                        onClicked: {
                            monthSelectorPopup.open()
                        }
                    }

                    RoundButton {
                        id: yearTxt
                        text: headerRect.selectedYear
                        flat: true
                        Layout.fillWidth: true
                        onClicked: {
                            yearSelectorPopup.open()
                        }
                    }

                    RoundButton {
                        text: dateRow.layoutDirection  === Qt.RightToLeft? "<":">"
                        flat: true
                        highlighted: true
                        LayoutMirroring.enabled: true
                        enabled: dateTimeDialog.isDateInRange(qDatePicker.localeToGregorianDate(headerRect.selectedYear,
                                                                                                headerRect.selectedMonth+1,
                                                                                                headerRect.selectedDay
                                                                                                ))
                        font{
                            bold: true
                        }
                        onClicked: {
                            dateTimeDialog.setLocaleDate(headerRect.selectedYear,
                                                         headerRect.selectedMonth+1,
                                                         headerRect.selectedDay
                                                         )
                        }
                    }
                }

                RowLayout {
                    width: parent.width
                    height: 50
                    layoutDirection: Qt.locale(qDatePicker.locale).textDirection
                    Repeater{
                        model: qDatePicker.calendar!=="" ? qDatePicker.getNarrowWeekDaysName()
                                                         : []
                        delegate: Text{
                            text: modelData
                            color: root.primaryColor
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font{
                                pixelSize: 13
                                bold: true
                            }
                        }
                    }
                }

                GridLayout {
                    width: parent.width
                    columns: 7
                    height: 175
                    layoutDirection: Qt.locale(qDatePicker.locale).textDirection

                    Repeater{
                        model: qDatePicker.getGridDaysOfMonth(headerRect.selectedYear,headerRect.selectedMonth)
                        delegate: RoundButton{
                            property date gregorianDate: qDatePicker.localeToGregorianDate(headerRect.selectedYear,headerRect.selectedMonth,Number(modelData))
                            text: modelData === "0"? "": modelData
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            flat: !highlighted
                            highlighted: Number(modelData) === headerRect.selectedDay

                            font{
                                pixelSize: 12
                            }

                            enabled:  {
                                if (modelData !== "0")
                                {
                                    return dateTimeDialog.isDateInRange(gregorianDate)
                                }
                                else
                                    return false
                            }

                            onClicked: {
                                dateTimeDialog.tempSelectedDate = new Date(gregorianDate)
                            }
                        }
                    }
                }
            }

            Item {
                id: timeSelctionItem

                width: parent.width
                height: parent.height - btnsLayout.height
                enabled: dateTimeDialog.isTimeSelection
                visible: enabled

                Item {
                    id: clockPlate
                    enabled: !dateTimeDialog.isMinuteSelction
                    visible: enabled
                    anchors.centerIn: parent
                    height: Math.min(timeSelctionItem.width, timeSelctionItem.height)
                    width: height

                    Repeater {
                        model: 60
                        Item {
                            x: clockPlate.width/2
                            y: 0
                            height: clockPlate.height/2
                            rotation: index * 6
                            transformOrigin: Item.Bottom
                            Rectangle {
                                height: clockPlate.height*0.01
                                width: height
                                radius: width/2
                                color: "gray"
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: 4
                            }
                        }
                    }

                    Repeater {
                        model: 24
                        Item {
                            id: hourContainer

                            property int hour: index


                            enabled: !dateTimeDialog.isMinuteSelction
                            visible: enabled
                            x: clockPlate.width/2
                            y: 0
                            height: clockPlate.height/2
                            rotation: index * 30
                            transformOrigin: Item.Bottom

                            RoundButton {
                                x: 0
                                y: hourContainer.hour >= 12 ? clockPlate.height*0.10
                                                            : clockPlate.height*0.01
                                width: 40
                                height: width
                                text: String(hourContainer.hour).replace(/^(\d)$/, '0$1')
                                rotation: 360 - index * 30
                                flat: !highlighted
                                highlighted: Number(hourContainer.hour) === dateTimeDialog.tempSelectedDate.getHours()
                                enabled: dateTimeDialog.isDateInRange(new Date (dateTimeDialog.tempSelectedDate.setHours(hourContainer.hour)))

                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                }
                                font{
                                    pixelSize: hourContainer.hour>=12 ? 12
                                                                      : 14
                                }
                                onClicked: {
                                    dateTimeDialog.tempSelectedDate = new Date(dateTimeDialog.tempSelectedDate.setHours(Number(hourContainer.hour)))
                                    dateTimeDialog.isMinuteSelction = true
                                }
                            }
                        }
                    }
                }

                Item {
                    id:  minutesPlate

                    enabled: dateTimeDialog.isMinuteSelction
                    visible: enabled
                    anchors.centerIn: parent
                    height: Math.min(timeSelctionItem.width, timeSelctionItem.height)
                    width: height

                    Repeater {
                        model: 60
                        Item {
                            id: minuteContainer
                            property int minute: index

                            x: clockPlate.width/2
                            y: 0
                            height: clockPlate.height/2
                            rotation: index * 6
                            transformOrigin: Item.Bottom
                            Rectangle {
                                height: clockPlate.height*0.01
                                width: height
                                radius: width/2
                                color: "gray"
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: 4
                            }

                            RoundButton {
                                x: 0
                                y: minuteContainer.minute%5===0? clockPlate.height*0.01
                                                               : clockPlate.height*0.02
                                width: minuteContainer.minute%5===0?40:25
                                height: width
                                text: minuteContainer.minute%5 === 0?minuteContainer.minute:""
                                rotation: 360 - index * 6
                                flat: !highlighted
                                highlighted: Number(minuteContainer.minute) === dateTimeDialog.tempSelectedDate.getMinutes()

                                enabled: dateTimeDialog.isDateInRange(new Date (dateTimeDialog.tempSelectedDate.setMinutes(minuteContainer.minute)))

                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                }
                                font{
                                    pixelSize: minuteContainer.minute%5 === 0? 14:11
                                }
                                onClicked: {
                                    dateTimeDialog.tempSelectedDate = new Date(dateTimeDialog.tempSelectedDate.setMinutes(Number(minuteContainer.minute)))
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    height: clockPlate.height*0.05
                    width: height
                    radius: width/2
                    color: root.primaryColor
                }

                Item {
                    id: minuteNeedle

                    property int value: dateTimeDialog.tempSelectedDate.getMinutes()
                    property int granularity: 60

                    rotation: 360/granularity * (value % granularity)
                    antialiasing: true

                    anchors {
                        top: clockPlate.top
                        bottom: clockPlate.bottom
                        horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        width: 2
                        height: minuteNeedle.height * 0.35
                        color: !dateTimeDialog.isMinuteSelction?"gray": root.primaryColor
                        antialiasing: true

                        anchors {
                            horizontalCenter: minuteNeedle.horizontalCenter
                            bottom: minuteNeedle.verticalCenter
                        }
                    }

                }

                Item {
                    id: hourNeedle

                    property int value: dateTimeDialog.tempSelectedDate.getHours()
                    property int valueminute: 0
                    property int granularity: 12

                    rotation: 360/granularity * (value%granularity) + 360/granularity * (valueminute / 60)
                    antialiasing: true

                    anchors {
                        top: clockPlate.top
                        bottom: clockPlate.bottom
                        horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        width: 2
                        height: hourNeedle.height * 0.25
                        color: dateTimeDialog.isMinuteSelction?"gray":root.primaryColor
                        anchors {
                            horizontalCenter: hourNeedle.horizontalCenter
                            bottom: hourNeedle.verticalCenter
                        }
                        antialiasing: true
                    }
                }
            }

            RowLayout{
                id: btnsLayout
                width: parent.width
                height: 50
                layoutDirection: Qt.locale(qDatePicker.locale).textDirection

                RoundButton {
                    text: dateTimeDialog.isTimeSelection ? qsTr("Back")
                                                         : qsTr("Cancel")
                    flat: true
                    Layout.fillWidth: true
                    onClicked: {
                        if(hasTimeSelection === true && dateTimeDialog.isTimeSelection)
                        {
                            dateTimeDialog.isTimeSelection = false
                        }
                        else
                            dateTimeDialog.close()
                    }
                }

                RoundButton {
                    id: nowBtn
                    text: dateTimeDialog.isTimeSelection ? qsTr("Now")
                                                         : qsTr("Today")
                    flat: true
                    Layout.fillWidth: true
                    onClicked: {
                        dateTimeDialog.tempSelectedDate = new Date()
                    }
                }

                RoundButton {
                    text: qsTr("Ok")
                    flat: true
                    Layout.fillWidth: true
                    onClicked: {
                        if(hasTimeSelection === false)
                        {
                            root.selectedDate = dateTimeDialog.tempSelectedDate
                            root.selectedDateText = ("%1 %2 %3 %4")
                            .arg(headerRect.selectedDayWeekName)
                            .arg(headerRect.selectedDay)
                            .arg((headerRect.selectedMonthName))
                            .arg(headerRect.selectedYear)

                            dateTimeDialog.close()
                        }
                        else if(dateTimeDialog.isTimeSelection === true)
                        {
                            root.selectedDate = dateTimeDialog.tempSelectedDate
                            root.selectedDateText = ("%1 %2 %3 %4 - %5:%6")
                            .arg(headerRect.selectedDayWeekName)
                            .arg(headerRect.selectedDay)
                            .arg((headerRect.selectedMonthName))
                            .arg(headerRect.selectedYear)
                            .arg(dateTimeDialog.tempSelectedDate.getHours().toString().replace(/^(\d)$/, '0$1'))
                            .arg(dateTimeDialog.tempSelectedDate.getMinutes().toString().replace(/^(\d)$/, '0$1'))

                            dateTimeDialog.close()
                        }

                        else {
                            dateTimeDialog.isTimeSelection = true
                        }
                    }
                }
            }
        }

    }

}
