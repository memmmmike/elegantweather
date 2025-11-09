#ifndef AIAGENT_H
#define AIAGENT_H

#include <QObject>
#include <QProcess>
#include <QString>
#include <QStringList>
#include <QVariantMap>

// Forward declarations for faster compilation
class QJsonObject;

class AIAgent : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isReady READ isReady NOTIFY isReadyChanged)
    Q_PROPERTY(bool isProcessing READ isProcessing NOTIFY isProcessingChanged)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)
    Q_PROPERTY(QString currentLocation READ currentLocation NOTIFY currentLocationChanged)
    Q_PROPERTY(QStringList chatHistory READ chatHistory NOTIFY chatHistoryChanged)

public:
    explicit AIAgent(QObject *parent = nullptr);
    ~AIAgent();

    bool isReady() const { return m_isReady; }
    bool isProcessing() const { return m_isProcessing; }
    QString error() const { return m_error; }
    QString currentLocation() const { return m_currentLocation; }
    QStringList chatHistory() const { return m_chatHistory; }

    Q_INVOKABLE void startService();
    Q_INVOKABLE void stopService();
    Q_INVOKABLE void setWeatherData(const QString &location, const QVariantMap &weatherData);
    Q_INVOKABLE void sendQuery(const QString &query);
    Q_INVOKABLE void clearHistory();

signals:
    void isReadyChanged();
    void isProcessingChanged();
    void errorChanged();
    void currentLocationChanged();
    void chatHistoryChanged();
    void responseReceived(const QString &response);

private slots:
    void onProcessReadyRead();
    void onProcessStarted();
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onProcessError(QProcess::ProcessError error);

private:
    void sendCommand(const QJsonObject &command);
    void handleResponse(const QJsonObject &response);
    void setIsReady(bool ready);
    void setIsProcessing(bool processing);
    void setError(const QString &error);
    void setCurrentLocation(const QString &location);
    void addToChatHistory(const QString &role, const QString &message);

    QProcess *m_process;
    bool m_isReady;
    bool m_isProcessing;
    QString m_error;
    QString m_currentLocation;
    QStringList m_chatHistory;
    QByteArray m_buffer;
};

#endif // AIAGENT_H
