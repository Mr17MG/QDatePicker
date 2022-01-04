#include "qdatepicker.h"


QDatePicker::QDatePicker(QObject *parent)
    : QObject{parent}
{

}

QDatePicker::QDatePicker(QLocale locale,QObject *parent)
    : QObject{parent}
{
    this->locale = locale;
}

QDatePicker::QDatePicker(QLocale locale, QCalendar calendar,QObject *parent)
    : QObject{parent}
{
    this->locale = locale;
    this->calendar = calendar;
}

const QLocale &QDatePicker::getLocale() const
{
    return locale;
}

void QDatePicker::setLocale(const QLocale &newLocale)
{
    locale = newLocale;
    emit localeChanged();
}

const QCalendar &QDatePicker::getCalendar() const
{
    return calendar;
}

void QDatePicker::setCalendar(const QCalendar &newCalendar)
{
    calendar = newCalendar;
    emit calendarChanged();
}

const QString QDatePicker::getLocaleText() const
{
    return this->locale.languageToCode(this->locale.language());
}

void QDatePicker::setLocaleText(const QString &newLocaleString)
{
    this->setLocale(QLocale(newLocaleString));
}

const QString QDatePicker::getCalendarText() const
{
    return this->calendar.name();
}

void QDatePicker::setCalnedarText(const QString &newCalendarString)
{
    this->setCalendar(QCalendar(newCalendarString));
}

QList<QString> QDatePicker::getLongWeekDaysName()
{
    QList<QString> weekDays;
    for(int i=1; i<=7; i++)
    {
        weekDays << this->calendar.weekDayName(this->locale,i,QLocale::LongFormat);
    }
    return this->shiftListForFirstdayOfWeek(weekDays);
}

QList<QString> QDatePicker::getShortWeekDaysName()
{
    QList<QString> weekDays;
    for(int i=1; i<=7; i++)
    {
        weekDays << this->calendar.weekDayName(this->locale,i,QLocale::ShortFormat);
    }
    return this->shiftListForFirstdayOfWeek(weekDays);
}

QList<QString> QDatePicker::getNarrowWeekDaysName()
{
    QList<QString> weekDays;
    for(int i=1; i<=7; i++)
    {
        weekDays << this->calendar.weekDayName(this->locale,i,QLocale::NarrowFormat);
    }
    return this->shiftListForFirstdayOfWeek(weekDays);
}

QList<QString> QDatePicker::getLongMonthsName()
{
    QList<QString> months;
    for(int i=1; i<= this->calendar.maximumMonthsInYear(); i++)
    {
        months << this->calendar.monthName(this->locale,i,QLocale::LongFormat);
    }
    return months;
}

QList<QString> QDatePicker::getShortMonthsName()
{
    QList<QString> months;
    for(int i=1; i<= this->calendar.maximumMonthsInYear(); i++)
    {
        months << this->calendar.monthName(this->locale,i,QLocale::ShortFormat);
    }
    return months;
}

QList<QString> QDatePicker::getNarrowMonthsName()
{
    QList<QString> months;
    for(int i=1; i<= this->calendar.maximumMonthsInYear(); i++)
    {
        months << this->calendar.monthName(this->locale,i,QLocale::NarrowFormat);
    }
    return months;
}

QList<QString> QDatePicker::getAvailableCalendars()
{
    return QCalendar::availableCalendars();
}

QList<QString> QDatePicker::getGridDaysOfMonth(int year, int month)
{
    QList<QString> grid;
    QDate date(year,month,1,this->calendar);

    int maxWeekInMonth = (this->calendar.dayOfWeek(date)+abs(shiftAmountForFirstDayOfWeek())<5?5:6);

    for (int i=1, day=0; i <= (maxWeekInMonth*7); i++)
    {
        if(i >= this->calendar.dayOfWeek(date) && day<this->calendar.daysInMonth(month,year) )
            grid << QString::number(++day);
        else grid << "0";
    }

    grid = this->shiftListForFirstdayOfWeek(grid);

    if(grid[0] == "0" && grid[6]=="0")
        grid.remove(0,7);

    while(grid.last()=="0")
        grid.takeLast();

    return grid;
}

QString QDatePicker::getCurrentLocalDateString()
{
    QDate currentDate(QDate::currentDate());
    return currentDate.toString(this->locale.dateFormat(),this->calendar);
}

QString QDatePicker::getCurrentLocalDateTimeString()
{
    QDateTime currentDate(QDateTime::currentDateTime());
    return currentDate.toString(this->locale.dateTimeFormat(),this->calendar);
}

QStringList QDatePicker::dateToLocalDateString(int year, int month, int day)
{
    QDate date(year,month,day);

    QStringList convertedDate = date.toString("yyyy-MM-dd", this->calendar).split("-");

    convertedDate.append(this->calendar.weekDayName(this->locale,this->calendar.dayOfWeek(date)));
    convertedDate.append(this->calendar.monthName(this->locale,convertedDate[1].toInt(),convertedDate[0].toInt()));

    return  convertedDate;
}

QDate QDatePicker::localeToGregorianDate(int localeYear, int localeMonth, int localeDay)
{
    if(localeDay == 0)
    {
        localeDay = this->calendar.daysInMonth(localeMonth);
        localeMonth--;
    }

    if(localeMonth == 0)
    {
        localeMonth = this->calendar.monthsInYear(localeYear);
        localeYear--;
    }

    if(localeDay > this->calendar.daysInMonth(localeMonth))
    {
        localeDay = 1;
        localeMonth++;
    }


    if(localeMonth > this->calendar.monthsInYear(localeYear))
    {
        localeMonth = 1;
        localeYear++;
    }

    QDate date(localeYear,localeMonth,localeDay,this->calendar);

    return date;
}

int QDatePicker::shiftAmountForFirstDayOfWeek()
{
    int shift;
    switch (this->locale.firstDayOfWeek()) {
    case Qt::Monday:
        shift = 0;
        break;
    case Qt::Tuesday:
        shift = 1;
        break;
    case Qt::Wednesday:
        shift = 2;
        break;
    case Qt::Thursday:
        shift = 3;
        break;
    case Qt::Friday:
        shift = 4;
        break;
    case Qt::Saturday:
        shift = -2;
        break;
    case Qt::Sunday:
        shift = -1;
        break;
    }
    return shift;
}

QList<QString> QDatePicker::shiftListForFirstdayOfWeek(QList<QString> list)
{
    for(int i=0; i< abs(this->shiftAmountForFirstDayOfWeek()); i++)
    {
        list.insert(0,list.takeLast());
    }
    return list;

}

