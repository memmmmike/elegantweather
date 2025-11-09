#ifndef WEATHERSERVICE_H
#define WEATHERSERVICE_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QMap>

// Forward declarations for faster compilation
class QNetworkAccessManager;
class QNetworkReply;
class QSettings;
class QTimer;

class WeatherService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString city READ city WRITE setCity NOTIFY cityChanged)
    Q_PROPERTY(double temperature READ temperature NOTIFY weatherDataChanged)
    Q_PROPERTY(QString description READ description NOTIFY weatherDataChanged)
    Q_PROPERTY(QString weatherIcon READ weatherIcon NOTIFY weatherDataChanged)
    Q_PROPERTY(double highTemp READ highTemp NOTIFY weatherDataChanged)
    Q_PROPERTY(double lowTemp READ lowTemp NOTIFY weatherDataChanged)
    Q_PROPERTY(int humidity READ humidity NOTIFY weatherDataChanged)
    Q_PROPERTY(double windSpeed READ windSpeed NOTIFY weatherDataChanged)
    Q_PROPERTY(double feelsLike READ feelsLike NOTIFY weatherDataChanged)
    Q_PROPERTY(int uvIndex READ uvIndex NOTIFY weatherDataChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)
    Q_PROPERTY(bool apiKeySet READ apiKeySet NOTIFY apiKeySetChanged)
    Q_PROPERTY(QStringList citySuggestions READ citySuggestions NOTIFY citySuggestionsChanged)
    Q_PROPERTY(QString backgroundImageUrl READ backgroundImageUrl NOTIFY backgroundImageUrlChanged)
    Q_PROPERTY(QString currentPlanet READ currentPlanet WRITE setCurrentPlanet NOTIFY currentPlanetChanged)
    Q_PROPERTY(bool showingPlanet READ showingPlanet NOTIFY showingPlanetChanged)
    Q_PROPERTY(QString temperatureUnit READ temperatureUnit WRITE setTemperatureUnit NOTIFY temperatureUnitChanged)
    Q_PROPERTY(QString timeFormat READ timeFormat WRITE setTimeFormat NOTIFY timeFormatChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QString temperatureUnitSymbol READ temperatureUnitSymbol NOTIFY temperatureUnitChanged)

public:
    explicit WeatherService(QObject *parent = nullptr);

    QString city() const { return m_city; }
    void setCity(const QString &city);

    double temperature() const { return convertTemperature(m_temperatureKelvin); }
    QString description() const { return m_description; }
    QString weatherIcon() const { return m_weatherIcon; }
    double highTemp() const { return convertTemperature(m_highTempKelvin); }
    double lowTemp() const { return convertTemperature(m_lowTempKelvin); }
    int humidity() const { return m_humidity; }
    double windSpeed() const { return m_windSpeed; }
    double feelsLike() const { return convertTemperature(m_feelsLikeKelvin); }
    int uvIndex() const { return m_uvIndex; }
    bool loading() const { return m_loading; }
    QString error() const { return m_error; }
    bool apiKeySet() const { return m_apiKeySet; }
    Q_INVOKABLE QString apiKey() const { return m_apiKey; }
    Q_INVOKABLE QString unsplashAccessKey() const { return m_unsplashAccessKey; }
    QStringList citySuggestions() const { return m_citySuggestions; }
    QString backgroundImageUrl() const { return m_backgroundImageUrl; }
    QString currentPlanet() const { return m_currentPlanet; }
    void setCurrentPlanet(const QString &planet);
    bool showingPlanet() const { return m_currentPlanet != "Earth"; }

    QString temperatureUnit() const { return m_temperatureUnit; }
    void setTemperatureUnit(const QString &unit);
    QString temperatureUnitSymbol() const;

    QString timeFormat() const { return m_timeFormat; }
    void setTimeFormat(const QString &format);

    QString language() const { return m_language; }
    void setLanguage(const QString &lang);

    Q_INVOKABLE void fetchWeather();
    Q_INVOKABLE void setApiKey(const QString &apiKey);
    Q_INVOKABLE void searchCities(const QString &query);
    Q_INVOKABLE void setUnsplashAccessKey(const QString &accessKey);
    Q_INVOKABLE void fetchCityBackground(const QString &cityName);
    Q_INVOKABLE void fetchMarsWeather();

signals:
    void cityChanged();
    void weatherDataChanged();
    void loadingChanged();
    void errorChanged();
    void apiKeySetChanged();
    void citySuggestionsChanged();
    void backgroundImageUrlChanged();
    void currentPlanetChanged();
    void showingPlanetChanged();
    void temperatureUnitChanged();
    void timeFormatChanged();
    void languageChanged();

private slots:
    void onWeatherReplyFinished();
    void onUvReplyFinished();
    void onGeocodingReplyFinished();
    void onUnsplashReplyFinished();
    void onMarsWeatherReplyFinished();
    void performCitySearch();

private:
    void parseWeatherData(const QByteArray &data);
    void parseUvData(const QByteArray &data);
    void setLoading(bool loading);
    void setError(const QString &error);
    QString getWeatherIcon(const QString &condition);
    void loadSettings();
    void saveSettings();
    void initializeCityMappings();
    QString getApiCityName(const QString &displayName);
    QString getTimeOfDay() const;
    double convertTemperature(double kelvin) const;

    QNetworkAccessManager *m_networkManager;
    QString m_apiKey;
    QString m_unsplashAccessKey;
    QString m_city;
    QMap<QString, QString> m_cityMappings; // Display name -> API name
    QStringList m_citySuggestions;
    QTimer *m_searchTimer;
    QString m_pendingSearchQuery;
    QString m_backgroundImageUrl;
    QString m_currentPlanet;
    double m_temperatureKelvin; // Store in Kelvin, convert in getter
    QString m_description;
    QString m_weatherIcon;
    double m_highTempKelvin; // Store in Kelvin, convert in getter
    double m_lowTempKelvin; // Store in Kelvin, convert in getter
    int m_humidity;
    double m_windSpeed;
    double m_feelsLikeKelvin; // Store in Kelvin, convert in getter
    int m_uvIndex;
    bool m_loading;
    QString m_error;
    double m_latitude;
    double m_longitude;
    int m_timezoneOffset; // Timezone offset in seconds from UTC
    bool m_apiKeySet;
    QString m_temperatureUnit; // "Celsius", "Fahrenheit", or "Kelvin"
    QString m_timeFormat; // "12" or "24"
    QString m_language; // Language code: "en", "es", "fr", "de", etc.
};

#endif // WEATHERSERVICE_H
