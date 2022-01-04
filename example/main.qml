import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

import "qrc:/../src"

ApplicationWindow {
    id: rootWindow

    width: 640
    height: 480
    visible: true
    title: qsTr("QDatePicker")

//    Material.theme: Material.Dark
    Material.accent: Material.Teal

    Text{
        id: title
        text: qsTr("Different Calendar, Different Locale")
        font{
            pixelSize: 16
            bold: true
        }

        anchors{
            top: parent.top
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }
    }
    Rectangle{
        id: horizontalLine
        color: "gray"
        width: parent.width - 30
        height: 1
        anchors{
            top: title.bottom
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
    }

    Flow{
        id: flow1

        spacing: 10
        anchors{
            top: horizontalLine.bottom
            left: parent.left
            right: parent.right
            margins: 10
        }

        DatePicker{
            placeholderText: "Gregorian, en_US"
            width: 200
            height: 70
            primaryColor: "Teal"
            locale: "en_US"
            calendar: "Gregorian"
            mainWindow: rootWindow
        }

        DatePicker{
            placeholderText: "Gregorian, fr_FR"
            width: 200
            height: 70
            primaryColor: "Teal"
            locale: "fr_FR"
            calendar: "Gregorian"
            mainWindow: rootWindow
        }

        DatePicker{
            placeholderText: "Jalali, fa_IR"
            width: 200
            height: 70
            primaryColor: "Teal"
            locale: "fa_IR"
            calendar: "Jalali"
            mainWindow: rootWindow
        }

        DatePicker{
            placeholderText: "Islamic, ar_AR"
            width: 200
            height: 70
            selectedDate: new Date()
            primaryColor: "Teal"
            locale: "ar_AR"
            calendar: "Islamic"
            mainWindow: rootWindow
        }
    }

    Text{
        id: title2
        text: qsTr("DatePicker options")
        font{
            pixelSize: 16
            bold: true
        }

        anchors{
            top: flow1.bottom
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }
    }
    Rectangle{
        id: horizontalLine2
        color: "gray"
        width: parent.width - 30
        height: 1
        anchors{
            top: title2.bottom
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
    }


    Flow{
        id: flow2
        spacing: 10
        anchors{
            top: horizontalLine2.bottom
            left: parent.left
            right: parent.right
            margins: 10
        }

        DatePicker{
            placeholderText: "With time picker"
            width: 200
            height: 70
            hasTimeSelection: true
            primaryColor: "Teal"
            locale: "en_US"
            calendar: "Gregorian"
            mainWindow: rootWindow
        }

        DatePicker{
            placeholderText: "Minimum date"
            width: 200
            height: 70
            minDate: new Date()
            primaryColor: "Teal"
            locale: "en_US"
            calendar: "Gregorian"
            mainWindow: rootWindow
        }

        DatePicker{
            placeholderText: "Maximum date"
            width: 200
            height: 70
            maxDate: new Date()
            primaryColor: "Teal"
            locale: "en_US"
            calendar: "Gregorian"
            mainWindow: rootWindow
        }

        DatePicker{
            placeholderText: "Minimum date With time picker"
            width: 300
            height: 70
            minDate: new Date()
            hasTimeSelection: true
            primaryColor: "Teal"
            locale: "en_US"
            calendar: "Gregorian"
            mainWindow: rootWindow
        }

        DatePicker{
            placeholderText: "Maximum date With time picker"
            width: 300
            height: 70
            maxDate: new Date()
            hasTimeSelection: true
            primaryColor: "Teal"
            locale: "en_US"
            calendar: "Gregorian"
            mainWindow: rootWindow
        }
    }
}
