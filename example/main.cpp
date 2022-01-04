#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

#include "../src/qdatepicker.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Material");

    qmlRegisterType<QDatePicker>("QDatePicker",1,0,"QDatePicker");

    QQmlApplicationEngine engine;

    const QUrl url("qrc:/main.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
