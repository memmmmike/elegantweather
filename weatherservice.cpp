#include "weatherservice.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrlQuery>
#include <QDateTime>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QSettings>
#include <QTimer>
#include <QLocale>
#include <QDebug>

WeatherService::WeatherService(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_city("San Francisco")
    , m_currentPlanet("Earth")
    , m_temperatureKelvin(293.15) // Default to 20°C / 68°F
    , m_highTempKelvin(293.15)
    , m_lowTempKelvin(293.15)
    , m_humidity(0)
    , m_windSpeed(0)
    , m_feelsLikeKelvin(293.15)
    , m_uvIndex(0)
    , m_loading(false)
    , m_latitude(0)
    , m_longitude(0)
    , m_timezoneOffset(0)
    , m_apiKeySet(false)
    , m_temperatureUnit("Fahrenheit") // Force Fahrenheit for US
    , m_timeFormat("12")
    , m_language("en")
{
    qDebug() << "INIT: Starting with temperatureUnit =" << m_temperatureUnit;
    initializeCityMappings();
    loadSettings();
    qDebug() << "INIT: After loadSettings, temperatureUnit =" << m_temperatureUnit;

    // Force fix if somehow Kelvin got through
    if (m_temperatureUnit == "Kelvin") {
        qDebug() << "INIT: KELVIN DETECTED! Forcing to Fahrenheit";
        m_temperatureUnit = "Fahrenheit";
        saveSettings();
    }
    qDebug() << "INIT: Final temperatureUnit =" << m_temperatureUnit;

    // Setup search timer for debouncing
    m_searchTimer = new QTimer(this);
    m_searchTimer->setSingleShot(true);
    m_searchTimer->setInterval(300); // 300ms delay
    connect(m_searchTimer, &QTimer::timeout, this, &WeatherService::performCitySearch);
}

void WeatherService::setCity(const QString &city)
{
    if (m_city != city) {
        m_city = city;
        saveSettings();
        emit cityChanged();
    }
}

void WeatherService::setApiKey(const QString &apiKey)
{
    m_apiKey = apiKey;
    m_apiKeySet = !apiKey.isEmpty();
    saveSettings();
    emit apiKeySetChanged();
}

void WeatherService::setUnsplashAccessKey(const QString &accessKey)
{
    m_unsplashAccessKey = accessKey;
    saveSettings();
}

void WeatherService::fetchWeather()
{
    if (m_apiKey.isEmpty()) {
        setError("API key not set. Please set your OpenWeatherMap API key.");
        return;
    }

    setLoading(true);
    setError("");

    // Get the API name (might be different from display name)
    QString apiCityName = getApiCityName(m_city);

    QUrl url("https://api.openweathermap.org/data/2.5/weather");
    QUrlQuery query;
    query.addQueryItem("q", apiCityName);
    query.addQueryItem("appid", m_apiKey);
    query.addQueryItem("units", "standard"); // Request Kelvin for custom conversion
    query.addQueryItem("lang", m_language); // Localized weather descriptions
    url.setQuery(query);

    QNetworkRequest request(url);
    QNetworkReply *reply = m_networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, &WeatherService::onWeatherReplyFinished);
}

void WeatherService::onWeatherReplyFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    if (reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        parseWeatherData(data);

        // Fetch city background image
        fetchCityBackground(m_city);

        // Fetch UV index if we have coordinates
        if (m_latitude != 0 && m_longitude != 0) {
            QUrl uvUrl("https://api.openweathermap.org/data/2.5/uvi");
            QUrlQuery query;
            query.addQueryItem("lat", QString::number(m_latitude));
            query.addQueryItem("lon", QString::number(m_longitude));
            query.addQueryItem("appid", m_apiKey);
            uvUrl.setQuery(query);

            QNetworkRequest uvRequest(uvUrl);
            QNetworkReply *uvReply = m_networkManager->get(uvRequest);
            connect(uvReply, &QNetworkReply::finished, this, &WeatherService::onUvReplyFinished);
        } else {
            setLoading(false);
        }
    } else {
        setError("Failed to fetch weather data: " + reply->errorString());
        setLoading(false);
    }

    reply->deleteLater();
}

void WeatherService::onUvReplyFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    if (reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        parseUvData(data);
    }

    setLoading(false);
    reply->deleteLater();
}

void WeatherService::parseWeatherData(const QByteArray &data)
{
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (doc.isNull() || !doc.isObject()) {
        setError("Invalid weather data received");
        return;
    }

    QJsonObject obj = doc.object();

    // Parse temperature data (API returns Kelvin, store as Kelvin)
    QJsonObject main = obj["main"].toObject();
    m_temperatureKelvin = main["temp"].toDouble();
    m_highTempKelvin = main["temp_max"].toDouble();
    m_lowTempKelvin = main["temp_min"].toDouble();
    m_humidity = main["humidity"].toInt();
    m_feelsLikeKelvin = main["feels_like"].toDouble();

    // Parse weather description
    QJsonArray weatherArray = obj["weather"].toArray();
    if (!weatherArray.isEmpty()) {
        QJsonObject weather = weatherArray[0].toObject();
        m_description = weather["description"].toString();
        QString mainCondition = weather["main"].toString();
        m_weatherIcon = getWeatherIcon(mainCondition);
        // Capitalize first letter
        if (!m_description.isEmpty()) {
            m_description[0] = m_description[0].toUpper();
        }
    }

    // Parse wind speed
    QJsonObject wind = obj["wind"].toObject();
    m_windSpeed = wind["speed"].toDouble();

    // Parse coordinates for UV index
    QJsonObject coord = obj["coord"].toObject();
    m_latitude = coord["lat"].toDouble();
    m_longitude = coord["lon"].toDouble();

    // Parse timezone offset (shift in seconds from UTC)
    m_timezoneOffset = obj["timezone"].toInt();

    emit weatherDataChanged();
}

void WeatherService::parseUvData(const QByteArray &data)
{
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (doc.isNull() || !doc.isObject()) {
        return;
    }

    QJsonObject obj = doc.object();
    m_uvIndex = qRound(obj["value"].toDouble());
    emit weatherDataChanged();
}

void WeatherService::setLoading(bool loading)
{
    if (m_loading != loading) {
        m_loading = loading;
        emit loadingChanged();
    }
}

void WeatherService::setError(const QString &error)
{
    if (m_error != error) {
        m_error = error;
        emit errorChanged();
    }
}

QString WeatherService::getWeatherIcon(const QString &condition)
{
    // Map weather conditions to emoji icons
    if (condition == "Clear") return "☀️";
    if (condition == "Clouds") return "☁️";
    if (condition == "Rain") return "🌧️";
    if (condition == "Drizzle") return "🌦️";
    if (condition == "Thunderstorm") return "⛈️";
    if (condition == "Snow") return "❄️";
    if (condition == "Mist" || condition == "Fog") return "🌫️";
    if (condition == "Haze") return "🌫️";
    if (condition == "Smoke") return "💨";
    return "🌤️"; // Default
}

void WeatherService::loadSettings()
{
    QSettings settings("ElegantWeather", "ElegantWeather");
    m_apiKey = settings.value("apiKey", "").toString();
    m_apiKeySet = !m_apiKey.isEmpty();
    m_unsplashAccessKey = settings.value("unsplashAccessKey", "").toString();
    m_city = settings.value("city", "San Francisco").toString();

    // Load temperature unit, but reject Kelvin (use locale-based default instead)
    QString savedUnit = settings.value("temperatureUnit", m_temperatureUnit).toString();
    qDebug() << "loadSettings: Read temperatureUnit from config =" << savedUnit;
    if (savedUnit == "Kelvin") {
        qDebug() << "loadSettings: Rejecting Kelvin, keeping" << m_temperatureUnit;
        // Don't use Kelvin - use locale-based default instead
        m_temperatureUnit = m_temperatureUnit; // Keep the locale-detected value
    } else {
        qDebug() << "loadSettings: Accepting saved unit" << savedUnit;
        m_temperatureUnit = savedUnit;
    }

    m_timeFormat = settings.value("timeFormat", "12").toString();
    m_language = settings.value("language", "en").toString();
}

void WeatherService::saveSettings()
{
    QSettings settings("ElegantWeather", "ElegantWeather");
    settings.setValue("apiKey", m_apiKey);
    settings.setValue("unsplashAccessKey", m_unsplashAccessKey);
    settings.setValue("city", m_city);
    settings.setValue("temperatureUnit", m_temperatureUnit);
    settings.setValue("timeFormat", m_timeFormat);
    settings.setValue("language", m_language);
}

void WeatherService::initializeCityMappings()
{
    // Map modern/proper city names to the names the API recognizes
    // Format: m_cityMappings["Display Name"] = "API Name"

    // Alaska - Utqiagvik (formerly Barrow)
    m_cityMappings["Utqiagvik"] = "Barrow";
    m_cityMappings["Utqiagvik, US"] = "Barrow, US";
    m_cityMappings["Utqiagvik, Alaska"] = "Barrow, Alaska";

    // Can add more renamed cities here as needed
    // Examples:
    // m_cityMappings["Mumbai"] = "Bombay";
    // m_cityMappings["Kolkata"] = "Calcutta";
}

QString WeatherService::getApiCityName(const QString &displayName)
{
    // Check if there's a mapping for this city name
    // If not found, return the original name
    return m_cityMappings.value(displayName, displayName);
}

QString WeatherService::getTimeOfDay() const
{
    // Get current UTC time
    QDateTime utcTime = QDateTime::currentDateTimeUtc();

    // Convert to city's local time using timezone offset
    QDateTime localTime = utcTime.addSecs(m_timezoneOffset);
    int hour = localTime.time().hour();

    // Determine time of day based on hour
    if (hour >= 5 && hour < 8) {
        return "sunrise dawn morning";
    } else if (hour >= 8 && hour < 12) {
        return "morning";
    } else if (hour >= 12 && hour < 17) {
        return "afternoon";
    } else if (hour >= 17 && hour < 19) {
        return "sunset golden hour";
    } else if (hour >= 19 && hour < 22) {
        return "evening dusk";
    } else {
        return "night";
    }
}

void WeatherService::searchCities(const QString &query)
{
    // Clear suggestions if query is too short
    if (query.length() < 2) {
        m_citySuggestions.clear();
        emit citySuggestionsChanged();
        return;
    }

    // Store the query and restart the timer (debouncing)
    m_pendingSearchQuery = query;
    m_searchTimer->start();
}

void WeatherService::performCitySearch()
{
    if (m_apiKey.isEmpty() || m_pendingSearchQuery.length() < 2) {
        return;
    }

    // Use OpenWeatherMap Geocoding API
    QUrl url("http://api.openweathermap.org/geo/1.0/direct");
    QUrlQuery query;
    query.addQueryItem("q", m_pendingSearchQuery);
    query.addQueryItem("limit", "5");
    query.addQueryItem("appid", m_apiKey);
    url.setQuery(query);

    QNetworkRequest request(url);
    QNetworkReply *reply = m_networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, &WeatherService::onGeocodingReplyFinished);
}

void WeatherService::onGeocodingReplyFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    m_citySuggestions.clear();

    if (reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(data);

        if (doc.isArray()) {
            QJsonArray results = doc.array();
            for (const QJsonValue &value : results) {
                QJsonObject obj = value.toObject();
                QString name = obj["name"].toString();
                QString state = obj["state"].toString();
                QString country = obj["country"].toString();

                // Format: "City, State, Country" or "City, Country" if no state
                QString displayName = name;
                if (!state.isEmpty()) {
                    displayName += ", " + state;
                }
                displayName += ", " + country;

                m_citySuggestions.append(displayName);
            }
        }
    }

    emit citySuggestionsChanged();
    reply->deleteLater();
}

void WeatherService::fetchCityBackground(const QString &cityName)
{
    if (m_unsplashAccessKey.isEmpty()) {
        return;
    }

    // Extract just the city name (before first comma)
    QString searchQuery = cityName.split(",").first().trimmed();
    searchQuery += " cityscape skyline ";

    // Add time of day to the search query
    searchQuery += getTimeOfDay();

    QUrl url("https://api.unsplash.com/search/photos");
    QUrlQuery query;
    query.addQueryItem("query", searchQuery);
    query.addQueryItem("per_page", "1");
    query.addQueryItem("orientation", "portrait");
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setRawHeader("Authorization", QString("Client-ID %1").arg(m_unsplashAccessKey).toUtf8());

    QNetworkReply *reply = m_networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, &WeatherService::onUnsplashReplyFinished);
}

void WeatherService::onUnsplashReplyFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    if (reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(data);

        if (doc.isObject()) {
            QJsonObject obj = doc.object();
            QJsonArray results = obj["results"].toArray();

            if (!results.isEmpty()) {
                QJsonObject photo = results[0].toObject();
                QJsonObject urls = photo["urls"].toObject();
                // Use "regular" size for good quality without being too large
                QString imageUrl = urls["regular"].toString();

                if (!imageUrl.isEmpty()) {
                    m_backgroundImageUrl = imageUrl;
                    emit backgroundImageUrlChanged();
                }
            }
        }
    }

    reply->deleteLater();
}

void WeatherService::setCurrentPlanet(const QString &planet)
{
    if (m_currentPlanet != planet) {
        // Set loading to hide old data immediately
        setLoading(true);

        m_currentPlanet = planet;
        emit currentPlanetChanged();
        emit showingPlanetChanged();

        // Clear ALL weather data when switching planets
        m_temperatureKelvin = 0;
        m_highTempKelvin = 0;
        m_lowTempKelvin = 0;
        m_humidity = 0;
        m_windSpeed = 0;
        m_feelsLikeKelvin = 0;
        m_uvIndex = 0;
        m_description = "";
        m_weatherIcon = "";

        if (planet == "Mars") {
            m_city = "Mars";
            emit cityChanged();
            emit weatherDataChanged();
            fetchMarsWeather();
            // fetchMarsWeather will set loading to false when done
        } else if (planet == "Earth") {
            // Return to default Earth city
            m_city = "San Francisco";
            emit cityChanged();
            emit weatherDataChanged();
            setLoading(false);
        }
    }
}

void WeatherService::setTemperatureUnit(const QString &unit)
{
    // Block Kelvin - only allow Celsius or Fahrenheit
    if (unit == "Kelvin") {
        return; // Silently ignore Kelvin
    }

    if (m_temperatureUnit != unit) {
        m_temperatureUnit = unit;
        saveSettings();
        emit temperatureUnitChanged();
        emit weatherDataChanged(); // Trigger UI update with new units
    }
}

QString WeatherService::temperatureUnitSymbol() const
{
    if (m_temperatureUnit == "Celsius") return "°C";
    if (m_temperatureUnit == "Fahrenheit") return "°F";
    // Default to Fahrenheit (Kelvin is not supported)
    return "°F";
}

void WeatherService::setTimeFormat(const QString &format)
{
    if (m_timeFormat != format) {
        m_timeFormat = format;
        saveSettings();
        emit timeFormatChanged();
    }
}

void WeatherService::setLanguage(const QString &lang)
{
    if (m_language != lang) {
        m_language = lang;
        saveSettings();
        emit languageChanged();
        // Re-fetch weather to get localized descriptions
        if (m_currentPlanet == "Earth" && !m_city.isEmpty()) {
            fetchWeather();
        }
    }
}

double WeatherService::convertTemperature(double kelvin) const
{
    if (m_temperatureUnit == "Celsius") {
        return kelvin - 273.15;
    } else if (m_temperatureUnit == "Fahrenheit") {
        return (kelvin - 273.15) * 9.0/5.0 + 32.0;
    }
    // Default to Fahrenheit (Kelvin is not supported)
    return (kelvin - 273.15) * 9.0/5.0 + 32.0;
}

void WeatherService::fetchMarsWeather()
{
    setLoading(true);
    setError("");

    // NASA InSight Mars Weather API
    // Note: InSight mission ended, but using demo for now
    // Alternative: https://mars.nasa.gov/rss/api/?feed=weather&category=msl&feedtype=json
    QUrl url("https://api.nasa.gov/insight_weather/?api_key=DEMO_KEY&feedtype=json&ver=1.0");

    QNetworkRequest request(url);
    QNetworkReply *reply = m_networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, &WeatherService::onMarsWeatherReplyFinished);
}

void WeatherService::onMarsWeatherReplyFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    if (reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(data);

        if (doc.isObject()) {
            QJsonObject obj = doc.object();
            QJsonArray solKeys = obj["sol_keys"].toArray();

            if (!solKeys.isEmpty()) {
                // Get the most recent sol (Martian day)
                QString latestSol = solKeys.last().toString();
                QJsonObject solData = obj[latestSol].toObject();

                // Parse Mars atmospheric temperature (API returns Celsius, store as Kelvin)
                QJsonObject at = solData["AT"].toObject();
                if (!at.isEmpty()) {
                    double avgTemp = at["av"].toDouble();
                    double maxTemp = at["mx"].toDouble();
                    double minTemp = at["mn"].toDouble();
                    // Convert from Celsius to Kelvin for internal storage
                    m_temperatureKelvin = avgTemp + 273.15;
                    m_highTempKelvin = maxTemp + 273.15;
                    m_lowTempKelvin = minTemp + 273.15;
                }

                // Parse wind speed
                QJsonObject hws = solData["HWS"].toObject();
                if (!hws.isEmpty()) {
                    m_windSpeed = hws["av"].toDouble() * 2.237; // Convert m/s to mph
                }

                // Parse pressure
                QJsonObject pre = solData["PRE"].toObject();
                if (!pre.isEmpty()) {
                    // Store pressure in humidity field for now (Mars doesn't have humidity)
                    m_humidity = qRound(pre["av"].toDouble());
                }

                m_description = "Martian atmospheric conditions";
                m_weatherIcon = "🔴"; // Mars emoji
                m_city = "Mars (Sol " + latestSol + ")";

                emit weatherDataChanged();
            }
        }
    } else {
        // If API fails, use known Mars atmospheric data (store in Kelvin)
        m_temperatureKelvin = -63 + 273.15; // Average temp
        m_highTempKelvin = -21 + 273.15;
        m_lowTempKelvin = -87 + 273.15;
        m_windSpeed = 20; // Average wind speed
        m_humidity = 0; // No humidity on Mars (showing pressure instead)
        m_description = "Typical Martian conditions (simulated)";
        m_weatherIcon = "🔴";
        m_city = "Mars";
        emit weatherDataChanged();
    }

    setLoading(false);
    reply->deleteLater();
}
