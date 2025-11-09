# ElegantWeather

A modern, minimalist weather application built with Qt Quick/QML, featuring AI-powered weather insights and support for both Earth and Mars weather data.

![ElegantWeather Screenshot](screenshot.png)

## Features

- **Clean, Minimal UI**: Black glassmorphic design with smooth animations
- **Real-time Weather Data**: Current conditions, temperature, humidity, wind speed, and UV index
- **AI Weather Assistant**: Chat with an AI about weather conditions and get personalized insights
- **Mars Weather**: View current weather conditions on Mars from NASA's InSight mission
- **Dynamic Backgrounds**: Beautiful location-based images from Unsplash
- **Multi-language Support**: Available in English, Spanish, French, German, Italian, Portuguese, Russian, Chinese, Japanese, and Korean
- **Temperature Units**: Switch between Celsius and Fahrenheit
- **City Search**: Autocomplete-enabled city search for worldwide locations
- **Expandable Details**: Toggle detailed weather information on demand
- **Time Format Options**: 12-hour or 24-hour time display

## Requirements

- **Qt 6.10.0** or later
- **Python 3.x** (for AI service)
- **Ollama** with **llama3.2** model installed
- **API Keys**:
  - [OpenWeatherMap API](https://openweathermap.org/api) (required)
  - [Unsplash API](https://unsplash.com/developers) (optional, for backgrounds)

## Installation

### 1. Install Qt 6.10.0

Download and install Qt from the [official website](https://www.qt.io/download).

### 2. Install Python Dependencies

```bash
pip3 install requests
```

### 3. Install Ollama and llama3.2

```bash
# Install Ollama (visit https://ollama.ai for installation instructions)
ollama pull llama3.2
```

### 4. Get API Keys

- **OpenWeatherMap**: Sign up at [openweathermap.org](https://openweathermap.org/api) and get a free API key
- **Unsplash** (optional): Create an app at [unsplash.com/developers](https://unsplash.com/developers) and get an access key

## Building

### Using qmake

```bash
cd ElegantWeather
qmake ElegantWeather.pro
make
```

Or use the full Qt path:

```bash
/path/to/Qt/6.10.0/gcc_64/bin/qmake ElegantWeather.pro
make
```

### Using Qt Creator

1. Open `ElegantWeather.pro` in Qt Creator
2. Configure the project with Qt 6.10.0
3. Build and run

## Configuration

### First Run

On first launch, the settings dialog will open. Enter your API keys:

1. **OpenWeatherMap API Key** (required for weather data)
2. **Unsplash Access Key** (optional for background images)

### Settings

Access settings anytime by clicking the gear icon (⚙) in the top-right corner:

- **Planet**: Switch between Earth and Mars weather
- **Temperature Unit**: Choose Celsius or Fahrenheit
- **Time Format**: Select 12-hour or 24-hour format
- **Language**: Choose from 10 supported languages
- **API Keys**: Update your OpenWeatherMap and Unsplash keys

### Configuration File

Settings are stored in:
- **Linux**: `~/.config/ElegantWeather/ElegantWeather.conf`
- **Windows**: `%APPDATA%/ElegantWeather/ElegantWeather.conf`
- **macOS**: `~/Library/Preferences/com.elegantweather.ElegantWeather.plist`

## Usage

### Weather Display

- **City Search**: Click the city name to search for a different location
- **Details Toggle**: Click the + button to expand/collapse detailed weather information
- **Refresh**: Weather data updates automatically, or change the city to refresh

### AI Chat

1. Click the chat icon (🗪) to open the AI assistant
2. Ask questions about the weather, forecasts, or recommendations
3. The AI uses the current weather data to provide contextual responses

### Mars Weather

1. Open Settings (⚙)
2. Select "Mars" under Planet
3. View current Mars weather data from NASA's InSight mission

## Project Structure

```
ElegantWeather/
├── main.cpp                 # Application entry point
├── main.qml                 # Main UI
├── ChatDialog.qml          # AI chat interface
├── SettingsDialog.qml      # Settings dialog
├── weatherservice.h/.cpp   # Weather service implementation
├── weather-ai-agent/       # Python AI service
│   └── service.py         # AI chat backend
├── ElegantWeather.pro      # Qt project file
└── README.md              # This file
```

## Architecture

### C++ Backend
- **WeatherService**: Handles API calls to OpenWeatherMap, NASA, and Unsplash
- **Qt Networking**: QNetworkAccessManager for HTTP requests
- **Settings Management**: QSettings for persistent configuration

### QML Frontend
- **main.qml**: Main weather display with expandable details
- **ChatDialog.qml**: AI chat interface with conversation history
- **SettingsDialog.qml**: Configuration UI with live preview

### Python AI Service
- **service.py**: Flask-based service that interfaces with Ollama
- Provides contextual weather insights using llama3.2

## API Endpoints

### OpenWeatherMap
- Current weather: `https://api.openweathermap.org/data/2.5/weather`
- Geocoding: `https://api.openweathermap.org/geo/1.0/direct`
- UV Index: `https://api.openweathermap.org/data/2.5/uvi`

### NASA InSight
- Mars weather: `https://api.nasa.gov/insight_weather/`

### Unsplash
- Search photos: `https://api.unsplash.com/search/photos`

## Troubleshooting

### Settings Dialog Opens at Startup
This happens when no OpenWeatherMap API key is configured. Enter your API key in the settings dialog.

### No Background Images
Ensure your Unsplash API key is correct, or the app will use a default gradient background.

### AI Chat Not Working
1. Verify Ollama is running: `ollama list`
2. Ensure llama3.2 is installed: `ollama pull llama3.2`
3. Check that Python service is running on port 5001

### Build Errors
Ensure you're using Qt 6.10.0 or later. Earlier versions may not support all QML features used in this project.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[MIT License](LICENSE)

## Acknowledgments

- Weather data provided by [OpenWeatherMap](https://openweathermap.org/)
- Background images from [Unsplash](https://unsplash.com/)
- Mars weather data from [NASA InSight Mission](https://mars.nasa.gov/insight/)
- AI powered by [Ollama](https://ollama.ai/) and Meta's Llama 3.2

## Support

For issues, questions, or suggestions, please open an issue on GitHub.
