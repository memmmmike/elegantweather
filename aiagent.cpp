#include "aiagent.h"
#include <QProcess>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QDir>

AIAgent::AIAgent(QObject *parent)
    : QObject(parent)
    , m_process(new QProcess(this))
    , m_isReady(false)
    , m_isProcessing(false)
{
    connect(m_process, &QProcess::readyReadStandardOutput, this, &AIAgent::onProcessReadyRead);
    connect(m_process, &QProcess::readyReadStandardError, this, &AIAgent::onProcessReadyRead);
    connect(m_process, &QProcess::started, this, &AIAgent::onProcessStarted);
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &AIAgent::onProcessFinished);
    connect(m_process, &QProcess::errorOccurred, this, &AIAgent::onProcessError);
}

AIAgent::~AIAgent()
{
    stopService();
}

void AIAgent::startService()
{
    if (m_process->state() != QProcess::NotRunning) {
        qDebug() << "Service already running";
        return;
    }

    setError("");
    setIsReady(false);

    // Get the path to the service.py file
    // Use absolute path to source directory
    QString servicePath = "/home/mlayug/ElegantWeather/weather-ai-agent/service.py";
    QString workingDir = "/home/mlayug/ElegantWeather/weather-ai-agent";

    qDebug() << "Starting AI service:" << servicePath;
    qDebug() << "Working directory:" << workingDir;

    // Set the working directory for the process
    m_process->setWorkingDirectory(workingDir);

    // Start the Python service with unbuffered output (-u flag)
    m_process->start("python3", QStringList() << "-u" << servicePath);

    if (!m_process->waitForStarted(5000)) {
        setError("Failed to start AI service. Make sure Python 3 is installed.");
    }
}

void AIAgent::stopService()
{
    if (m_process->state() != QProcess::NotRunning) {
        m_process->terminate();
        if (!m_process->waitForFinished(3000)) {
            m_process->kill();
        }
    }
    setIsReady(false);
}

void AIAgent::setWeatherData(const QString &location, const QVariantMap &weatherData)
{
    if (!m_isReady) {
        setError("Service not ready");
        return;
    }

    setIsProcessing(true);
    setError("");

    // Convert QVariantMap to QJsonObject
    QJsonObject weatherJson = QJsonObject::fromVariantMap(weatherData);

    QJsonObject command;
    command["command"] = "set_weather";
    command["location"] = location;
    command["weather_data"] = weatherJson;

    sendCommand(command);
}

void AIAgent::sendQuery(const QString &query)
{
    if (!m_isReady) {
        setError("Service not ready");
        return;
    }

    if (query.trimmed().isEmpty()) {
        return;
    }

    setIsProcessing(true);
    setError("");

    // Add user message to chat history
    addToChatHistory("user", query);

    QJsonObject command;
    command["command"] = "query";
    command["prompt"] = query;

    sendCommand(command);
}

void AIAgent::clearHistory()
{
    m_chatHistory.clear();
    emit chatHistoryChanged();
}

void AIAgent::sendCommand(const QJsonObject &command)
{
    QJsonDocument doc(command);
    QString jsonString = doc.toJson(QJsonDocument::Compact) + "\n";

    qDebug() << "Sending command:" << jsonString.trimmed();
    m_process->write(jsonString.toUtf8());
}

void AIAgent::onProcessReadyRead()
{
    m_buffer += m_process->readAllStandardOutput();

    // Also read stderr for error messages
    QByteArray errorOutput = m_process->readAllStandardError();
    if (!errorOutput.isEmpty()) {
        qDebug() << "Service stderr:" << errorOutput;
    }

    // Process all complete lines
    int newlineIndex;
    while ((newlineIndex = m_buffer.indexOf('\n')) != -1) {
        QByteArray line = m_buffer.left(newlineIndex);
        m_buffer = m_buffer.mid(newlineIndex + 1);

        qDebug() << "Received line:" << line;

        QJsonDocument doc = QJsonDocument::fromJson(line);
        if (!doc.isNull() && doc.isObject()) {
            handleResponse(doc.object());
        }
    }
}

void AIAgent::onProcessStarted()
{
    qDebug() << "AI service process started";
}

void AIAgent::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    qDebug() << "AI service process finished with exit code:" << exitCode;
    setIsReady(false);
    setIsProcessing(false);

    if (exitStatus == QProcess::CrashExit) {
        setError("AI service crashed");
    } else if (exitCode != 0) {
        QString stderr = m_process->readAllStandardError();
        setError("AI service exited with error: " + stderr);
    }
}

void AIAgent::onProcessError(QProcess::ProcessError error)
{
    QString errorMsg;
    switch (error) {
        case QProcess::FailedToStart:
            errorMsg = "Failed to start AI service. Check Python installation and dependencies.";
            break;
        case QProcess::Crashed:
            errorMsg = "AI service crashed";
            break;
        case QProcess::Timedout:
            errorMsg = "AI service timed out";
            break;
        case QProcess::WriteError:
            errorMsg = "Write error to AI service";
            break;
        case QProcess::ReadError:
            errorMsg = "Read error from AI service";
            break;
        default:
            errorMsg = "Unknown error occurred";
            break;
    }

    qDebug() << "Process error:" << errorMsg;
    setError(errorMsg);
    setIsReady(false);
    setIsProcessing(false);
}

void AIAgent::handleResponse(const QJsonObject &response)
{
    QString status = response["status"].toString();
    QString command = response["command"].toString();

    qDebug() << "Received response:" << QJsonDocument(response).toJson(QJsonDocument::Compact);

    if (status == "ready") {
        setIsReady(true);
        qDebug() << "AI service is ready";
        return;
    }

    if (status == "error") {
        QString errorMsg = response["message"].toString();
        setError(errorMsg);
        setIsProcessing(false);
        return;
    }

    if (command == "set_weather") {
        setCurrentLocation(response["location"].toString());
        setIsProcessing(false);
        emit responseReceived("Weather data loaded for " + m_currentLocation);
    }
    else if (command == "query") {
        QString responseText = response["response"].toString();
        addToChatHistory("ai", responseText);
        emit responseReceived(responseText);
        setIsProcessing(false);
    }
}

void AIAgent::setIsReady(bool ready)
{
    if (m_isReady != ready) {
        m_isReady = ready;
        emit isReadyChanged();
    }
}

void AIAgent::setIsProcessing(bool processing)
{
    if (m_isProcessing != processing) {
        m_isProcessing = processing;
        emit isProcessingChanged();
    }
}

void AIAgent::setError(const QString &error)
{
    if (m_error != error) {
        m_error = error;
        emit errorChanged();
    }
}

void AIAgent::setCurrentLocation(const QString &location)
{
    if (m_currentLocation != location) {
        m_currentLocation = location;
        emit currentLocationChanged();
    }
}

void AIAgent::addToChatHistory(const QString &role, const QString &message)
{
    QString formattedMessage = role + "|" + message;
    m_chatHistory.append(formattedMessage);
    emit chatHistoryChanged();
}
