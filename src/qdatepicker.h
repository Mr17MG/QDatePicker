#ifndef QDATEPICKER_H
#define QDATEPICKER_H

#include <QDate>
#include <QObject>
#include <QLocale>
#include <QCalendar>
#include <QDateTime>

class QDatePicker : public QObject
{
    Q_OBJECT
    QLocale locale;
    QCalendar calendar;

    Q_PROPERTY(QString locale READ getLocaleText WRITE setLocaleText NOTIFY localeChanged)
    Q_PROPERTY(QString calendar READ getCalendarText WRITE setCalnedarText NOTIFY calendarChanged)

public:
    explicit QDatePicker(QObject *parent = nullptr);
    explicit QDatePicker(QLocale locale, QObject *parent = nullptr);
    explicit QDatePicker(QLocale locale, QCalendar calendar, QObject *parent = nullptr);

    const QLocale &getLocale() const;
    void setLocale(const QLocale &newLocale);

    const QCalendar &getCalendar() const;
    void setCalendar(const QCalendar &newCalendar);

    const QString getLocaleText() const;
    void setLocaleText(const QString &newLocaleString);

    const QString getCalendarText() const;
    void setCalnedarText(const QString &newCalendarString);

    Q_INVOKABLE QList<QString> getLongWeekDaysName();
    Q_INVOKABLE QList<QString> getShortWeekDaysName();
    Q_INVOKABLE QList<QString> getNarrowWeekDaysName();

    Q_INVOKABLE QList<QString> getLongMonthsName();
    Q_INVOKABLE QList<QString> getShortMonthsName();
    Q_INVOKABLE QList<QString> getNarrowMonthsName();

    Q_INVOKABLE QList<QString> getAvailableCalendars();

    Q_INVOKABLE QList<QString> getGridDaysOfMonth(int year, int month);

    Q_INVOKABLE QString getCurrentLocalDateString();
    Q_INVOKABLE QString getCurrentLocalDateTimeString();

    Q_INVOKABLE QStringList dateToLocalDateString(int year, int month, int day);

    Q_INVOKABLE QDate localeToGregorianDate(int localeYear, int localeMonth, int localeDay);

    Q_INVOKABLE int shiftAmountForFirstDayOfWeek();
    Q_INVOKABLE QList<QString> shiftListForFirstdayOfWeek(QList<QString> list);


signals:
    void localeChanged();
    void calendarChanged();

    void selectedDateChanged();

};

#endif // QDATEPICKER_H
