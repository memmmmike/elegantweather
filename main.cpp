#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "weatherservice.h"
#include "aiagent.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    WeatherService weatherService;
    AIAgent aiAgent;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("weatherService", &weatherService);
    engine.rootContext()->setContextProperty("aiAgent", &aiAgent);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
