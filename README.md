# ElegantWeather

A modern, minimalist weather application built with Qt Quick/QML, featuring AI-powered weather insights and support for both Earth and Mars weather data.

![ElegantWeather Screenshot](screenshot.png)

## Download

**Pre-built packages are available for download from the [Releases](../../releases) page.**

- **Windows**: Download `ElegantWeather-Windows-vX.X.X.zip`, extract, and run
- **macOS**: Download `ElegantWeather-macOS-vX.X.X.dmg` and install
- **Linux**: Download `ElegantWeather-Linux-vX.X.X.AppImage`, make executable, and run

All packages include Qt libraries - no need to install Qt separately.

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

- **Qt 6.7** or later (6.7.2 recommended)
- **Python 3.x** (for AI service)
- **Ollama** with **llama3.2** model installed
- **API Keys**:
  - [OpenWeatherMap API](https://openweathermap.org/api) (required)
  - [Unsplash API](https://unsplash.com/developers) (optional, for backgrounds)

## Installation

### 1. Install Qt 6.7+

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
/path/to/Qt/6.7.2/gcc_64/bin/qmake ElegantWeather.pro
make
```

### Using Qt Creator

1. Open `ElegantWeather.pro` in Qt Creator
2. Configure the project with Qt 6.7+
3. Build and run

## Creating a Release (For Maintainers)

Releases are built automatically by GitHub Actions. To create a new release:

1. **Tag a version** (triggers automatic builds):
```bash
git tag v1.0.0
git push origin v1.0.0
```

2. **GitHub Actions will automatically**:
   - Build packages for Windows, macOS, and Linux
   - Bundle all Qt libraries with each package
   - Create a GitHub Release
   - Upload all packages to the release

3. **Users can then download** pre-built packages from the Releases page

### Manual Deployment (Optional)

If you need to build packages locally instead of using GitHub Actions:

### Windows

1. Build your application in **Release** mode
2. Create a deployment folder and copy your executable:
```cmd
mkdir deploy
copy release\ElegantWeather.exe deploy\
```

3. Run `windeployqt` to bundle Qt libraries:
```cmd
cd deploy
C:\Qt\6.7.2\msvc2019_64\bin\windeployqt.exe ElegantWeather.exe --qmldir ..\
```

4. Copy Python AI service:
```cmd
xcopy /E /I ..\weather-ai-agent weather-ai-agent
```

5. Your `deploy` folder now contains a complete, redistributable application. Zip it and distribute.

**Result**: ~40-60MB package that runs on any Windows 10+ system without Qt installed.

### macOS

1. Build your application in **Release** mode
2. Run `macdeployqt` to create an app bundle:
```bash
/path/to/Qt/6.7.2/macos/bin/macdeployqt ElegantWeather.app -qmldir=. -dmg
```

3. Copy Python AI service into the app bundle:
```bash
cp -r weather-ai-agent ElegantWeather.app/Contents/MacOS/
```

4. This creates `ElegantWeather.dmg` - a distributable disk image.

**Optional**: Sign and notarize for distribution outside the App Store:
```bash
codesign --deep --force --verify --verbose --sign "Developer ID Application: Your Name" ElegantWeather.app
xcrun notarytool submit ElegantWeather.dmg --keychain-profile "notary-profile" --wait
```

**Result**: A `.dmg` file that runs on macOS 10.15+ without Qt installed.

### Linux

#### Option 1: AppImage (Recommended - Single File)

1. Build your application in **Release** mode
2. Install `linuxdeploy` and Qt plugin:
```bash
wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
wget https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
chmod +x linuxdeploy*.AppImage
```

3. Create AppImage:
```bash
export QMAKE=/path/to/Qt/6.7.2/gcc_64/bin/qmake
./linuxdeploy-x86_64.AppImage --executable=./ElegantWeather \
  --appdir=AppDir \
  --plugin qt \
  --output appimage \
  --desktop-file=ElegantWeather.desktop \
  --icon-file=icon.png
```

4. Copy Python AI service:
```bash
cp -r weather-ai-agent AppDir/usr/bin/
```

**Result**: Single `ElegantWeather-x86_64.AppImage` file (~50-70MB) that runs on most Linux distros.

#### Option 2: Tarball with Bundled Libraries

1. Build in **Release** mode
2. Create deployment folder:
```bash
mkdir -p deploy/ElegantWeather
cp ElegantWeather deploy/ElegantWeather/
```

3. Copy Qt libraries:
```bash
cd deploy/ElegantWeather
/path/to/Qt/6.7.2/gcc_64/bin/linuxdeployqt-continuous-x86_64.AppImage \
  ./ElegantWeather -qmldir=../../ -bundle-non-qt-libs
```

4. Copy Python AI service:
```bash
cp -r ../../weather-ai-agent .
```

5. Create launcher script `run.sh`:
```bash
#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LD_LIBRARY_PATH="$DIR/lib:$LD_LIBRARY_PATH"
cd "$DIR"
./ElegantWeather "$@"
```

6. Package:
```bash
cd ..
tar czf ElegantWeather-linux-x86_64.tar.gz ElegantWeather/
```

**Result**: Tarball that extracts and runs on most Linux distributions.

### Distribution Checklist

Before distributing, ensure you've included:
- [ ] All required Qt libraries (auto-handled by deployment tools)
- [ ] QML imports and plugins
- [ ] Python AI service (`weather-ai-agent/`)
- [ ] Python dependencies (users still need Python 3 and Ollama)
- [ ] README with setup instructions for API keys
- [ ] License file

### Package Sizes
- **Windows**: ~40-60 MB
- **macOS**: ~45-65 MB
- **Linux AppImage**: ~50-70 MB
- **Linux tarball**: ~35-55 MB

These sizes include all Qt libraries needed to run on systems without Qt installed.

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
Ensure you're using Qt 6.7.2 or later. Earlier versions may not support all QML features used in this project.

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
