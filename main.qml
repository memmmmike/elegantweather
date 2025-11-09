import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

ApplicationWindow {
    id: root
    visible: true
    width: 480
    height: 920
    minimumWidth: 420
    minimumHeight: 780
    title: qsTr("Elegant Weather")

    // Toggle for detailed weather view
    property bool showDetailedWeather: false

    // Main background container with rounded corners
    Rectangle {
        anchors.fill: parent
        anchors.margins: 0
        radius: 0
        color: "transparent"

        // Background layer with image/gradient
        Item {
            id: backgroundContent
            anchors.fill: parent
            clip: true

            // City background image (Earth only)
            Image {
                id: backgroundImage
                anchors.fill: parent
                source: weatherService.backgroundImageUrl
                fillMode: Image.PreserveAspectCrop
                opacity: 0
                asynchronous: true
                cache: true
                visible: weatherService.currentPlanet === "Earth"

                onStatusChanged: {
                    if (status === Image.Ready) {
                        opacity = 1
                    }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 1200; easing.type: Easing.InOutCubic }
                }
            }

            // Mars sophisticated gradient background
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#C1440E" }
                    GradientStop { position: 0.4; color: "#D2691E" }
                    GradientStop { position: 0.7; color: "#CD853F" }
                    GradientStop { position: 1.0; color: "#8B4513" }
                }
                visible: weatherService.currentPlanet === "Mars"
            }

            // Minimal black gradient fallback
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#0a0a0a" }
                    GradientStop { position: 1.0; color: "#1a1a1a" }
                }
                opacity: backgroundImage.status === Image.Ready ? 0 : 1
                visible: weatherService.currentPlanet === "Earth"

                Behavior on opacity {
                    NumberAnimation { duration: 1200; easing.type: Easing.InOutCubic }
                }
            }

            // Refined overlay for depth and readability
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#60000000" }
                    GradientStop { position: 0.5; color: "#30000000" }
                    GradientStop { position: 1.0; color: "#70000000" }
                }
                visible: (backgroundImage.status === Image.Ready && weatherService.currentPlanet === "Earth") ||
                         weatherService.currentPlanet === "Mars"
            }

            layer.enabled: settingsDialog.visible || chatDialog.visible
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1.0
                blurMax: 48
                blurMultiplier: 1.5
            }
        }
    }

    // Settings Dialog
    SettingsDialog {
        id: settingsDialog
    }

    // Chat Dialog
    ChatDialog {
        id: chatDialog
    }

    // Show settings on first run or if API key not set
    Component.onCompleted: {
        if (!weatherService.apiKeySet) {
            settingsDialog.open()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 20

        // Elegant Header with glassmorphic buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Item {
                Layout.fillWidth: true
            }

            // Glassmorphic AI Button
            Button {
                text: "🗪"
                onClicked: chatDialog.open()

                background: Rectangle {
                    implicitWidth: 48
                    implicitHeight: 48
                    color: "#40FFFFFF"
                    border.color: "#60FFFFFF"
                    border.width: 1
                    radius: 24

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 0.4
                        blurMax: 16
                        shadowEnabled: true
                        shadowColor: "#40000000"
                        shadowBlur: 0.3
                        shadowVerticalOffset: 4
                    }

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 24
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: mouse.accepted = false
                    onEntered: parent.background.color = "#60FFFFFF"
                    onExited: parent.background.color = "#40FFFFFF"
                }
            }

            // Glassmorphic Settings Button
            Button {
                text: "⚙"
                onClicked: settingsDialog.open()

                background: Rectangle {
                    implicitWidth: 48
                    implicitHeight: 48
                    color: "#40FFFFFF"
                    border.color: "#60FFFFFF"
                    border.width: 1
                    radius: 24

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 0.4
                        blurMax: 16
                        shadowEnabled: true
                        shadowColor: "#40000000"
                        shadowBlur: 0.3
                        shadowVerticalOffset: 4
                    }

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 24
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: mouse.accepted = false
                    onEntered: parent.background.color = "#60FFFFFF"
                    onExited: parent.background.color = "#40FFFFFF"
                }
            }

            // Glassmorphic Details Toggle Button
            Button {
                text: root.showDetailedWeather ? "−" : "+"
                onClicked: root.showDetailedWeather = !root.showDetailedWeather

                background: Rectangle {
                    implicitWidth: 48
                    implicitHeight: 48
                    color: "#40FFFFFF"
                    border.color: "#60FFFFFF"
                    border.width: 1
                    radius: 24

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 0.4
                        blurMax: 16
                        shadowEnabled: true
                        shadowColor: "#40000000"
                        shadowBlur: 0.3
                        shadowVerticalOffset: 4
                    }

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 28
                    font.weight: Font.Light
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: mouse.accepted = false
                    onEntered: parent.background.color = "#60FFFFFF"
                    onExited: parent.background.color = "#40FFFFFF"
                }
            }
        }

        // Glassmorphic Search Card with Autocomplete (only for Earth)
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: searchCard.height + (suggestionsPopup.visible ? suggestionsPopup.height + 8 : 0)
            visible: weatherService.currentPlanet === "Earth"

            Rectangle {
                id: searchCard
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 68
                color: "#35FFFFFF"
                border.color: "#50FFFFFF"
                border.width: 1.5
                radius: 20

                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 0.5
                    blurMax: 20
                    shadowEnabled: true
                    shadowColor: "#60000000"
                    shadowBlur: 0.6
                    shadowVerticalOffset: 8
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    TextField {
                        id: cityInput
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: weatherService.city
                        placeholderText: "Search for a city..."
                        font.pixelSize: 17
                        font.weight: Font.Normal
                        font.letterSpacing: 0.3
                        color: "white"
                        verticalAlignment: Text.AlignVCenter

                        placeholderTextColor: "#AAFFFFFF"

                        background: Rectangle {
                            color: "transparent"
                        }

                        onTextChanged: {
                            weatherService.searchCities(cityInput.text)
                        }

                        onAccepted: {
                            weatherService.city = cityInput.text
                            weatherService.fetchWeather()
                            cityInput.focus = false
                        }

                        Keys.onReturnPressed: {
                            weatherService.city = cityInput.text
                            weatherService.fetchWeather()
                            cityInput.focus = false
                        }

                        Keys.onEscapePressed: {
                            cityInput.focus = false
                        }
                    }

                    Button {
                        Layout.preferredWidth: 110
                        Layout.fillHeight: true
                        text: "Search"
                        enabled: !weatherService.loading

                        onClicked: {
                            weatherService.city = cityInput.text
                            weatherService.fetchWeather()
                            cityInput.focus = false
                        }

                        background: Rectangle {
                            implicitWidth: 110
                            color: parent.enabled ? "#50FFFFFF" : "#30FFFFFF"
                            border.color: parent.enabled ? "#70FFFFFF" : "#40FFFFFF"
                            border.width: 1
                            radius: 14

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            font.letterSpacing: 0.5
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onPressed: mouse.accepted = false
                            onEntered: if(parent.enabled) parent.background.color = "#70FFFFFF"
                            onExited: if(parent.enabled) parent.background.color = "#50FFFFFF"
                        }
                    }
                }
            }

            // Elegant Glassmorphic Suggestions
            Rectangle {
                id: suggestionsPopup
                anchors.top: searchCard.bottom
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.min(suggestionsList.contentHeight + 16, 240)
                visible: weatherService.citySuggestions.length > 0 && cityInput.focus
                color: "#35FFFFFF"
                border.color: "#50FFFFFF"
                border.width: 1.5
                radius: 18

                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 0.5
                    blurMax: 20
                    shadowEnabled: true
                    shadowColor: "#60000000"
                    shadowBlur: 0.6
                    shadowVerticalOffset: 8
                }

                ListView {
                    id: suggestionsList
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true
                    spacing: 4
                    model: weatherService.citySuggestions

                    delegate: ItemDelegate {
                        width: suggestionsList.width
                        height: 50

                        background: Rectangle {
                            color: parent.hovered ? "#40FFFFFF" : "transparent"
                            radius: 10

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }

                        contentItem: Text {
                            text: modelData
                            font.pixelSize: 16
                            font.weight: Font.Normal
                            font.letterSpacing: 0.3
                            color: "white"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 16

                            layer.enabled: true
                            layer.effect: MultiEffect {
                                shadowEnabled: true
                                shadowColor: "#60000000"
                                shadowBlur: 0.2
                                shadowVerticalOffset: 1
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                cityInput.text = modelData
                                weatherService.city = modelData
                                weatherService.fetchWeather()
                                cityInput.focus = false
                            }
                        }
                    }
                }
            }
        }

        // Elegant Error Message
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            visible: weatherService.error !== ""
            color: "#40FF6B6B"
            border.color: "#60FF8585"
            border.width: 1.5
            radius: 16

            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 0.4
                blurMax: 16
                shadowEnabled: true
                shadowColor: "#40000000"
                shadowBlur: 0.4
                shadowVerticalOffset: 4
            }

            Text {
                anchors.fill: parent
                anchors.margins: 16
                text: weatherService.error
                color: "white"
                font.pixelSize: 14
                font.weight: Font.Medium
                font.letterSpacing: 0.2
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "#80000000"
                    shadowBlur: 0.3
                    shadowVerticalOffset: 1
                }
            }
        }

        // Elegant Loading Indicator
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            visible: weatherService.loading

            Rectangle {
                anchors.centerIn: parent
                width: 64
                height: 64
                radius: 32
                color: "#35FFFFFF"
                border.color: "#50FFFFFF"
                border.width: 2

                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 0.4
                    blurMax: 16
                    shadowEnabled: true
                    shadowColor: "#40000000"
                    shadowBlur: 0.5
                    shadowVerticalOffset: 6
                }

                // Spinning arc
                Rectangle {
                    id: loadingSpinner
                    width: 48
                    height: 48
                    radius: 24
                    anchors.centerIn: parent
                    color: "transparent"
                    border.color: "white"
                    border.width: 3

                    Rectangle {
                        width: 12
                        height: 3
                        radius: 1.5
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 3
                    }

                    RotationAnimation {
                        target: loadingSpinner
                        from: 0
                        to: 360
                        duration: 1200
                        loops: Animation.Infinite
                        running: weatherService.loading
                        easing.type: Easing.InOutCubic
                    }
                }
            }
        }

        Item { Layout.preferredHeight: 12 }

        // Premium Weather Display
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: weatherService.temperature !== 0 && !weatherService.loading

            ColumnLayout {
                anchors.fill: parent
                spacing: 24

                // City Name with elegant shadow
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: weatherService.city
                    font.pixelSize: 28
                    font.weight: Font.Normal
                    font.letterSpacing: 1.0
                    color: "white"

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "#A0000000"
                        shadowBlur: 0.5
                        shadowVerticalOffset: 2
                    }

                    opacity: 0
                    Component.onCompleted: {
                        opacity = 1
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 800; easing.type: Easing.OutCubic }
                    }
                }

                // Large Weather Icon with smooth fade
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: weatherService.weatherIcon
                    font.pixelSize: 120

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "#80000000"
                        shadowBlur: 0.6
                        shadowVerticalOffset: 8
                    }

                    opacity: 0
                    scale: 0.8
                    Component.onCompleted: {
                        opacity = 1
                        scale = 1
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 1000; easing.type: Easing.OutCubic }
                    }

                    Behavior on scale {
                        NumberAnimation { duration: 1000; easing.type: Easing.OutBack }
                    }
                }

                // Premium Temperature Display
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Math.round(weatherService.temperature) + weatherService.temperatureUnitSymbol
                    font.pixelSize: 96
                    font.weight: Font.Thin
                    font.letterSpacing: -2
                    color: "white"

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "#A0000000"
                        shadowBlur: 0.8
                        shadowVerticalOffset: 4
                    }

                    opacity: 0
                    y: -20
                    Component.onCompleted: {
                        opacity = 1
                        y = 0
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 1000; easing.type: Easing.OutCubic }
                    }

                    Behavior on y {
                        NumberAnimation { duration: 1000; easing.type: Easing.OutCubic }
                    }
                }

                // Description with refined style
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: weatherService.description
                    font.pixelSize: 22
                    font.weight: Font.Normal
                    font.letterSpacing: 0.8
                    color: "white"

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "#80000000"
                        shadowBlur: 0.4
                        shadowVerticalOffset: 2
                    }
                }

                // Refined High/Low Display
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: highLowLayout.implicitWidth + 32
                    Layout.preferredHeight: 52
                    color: "#25FFFFFF"
                    border.color: "#40FFFFFF"
                    border.width: 1
                    radius: 26

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 0.3
                        blurMax: 12
                        shadowEnabled: true
                        shadowColor: "#40000000"
                        shadowBlur: 0.4
                        shadowVerticalOffset: 4
                    }

                    RowLayout {
                        id: highLowLayout
                        anchors.centerIn: parent
                        spacing: 20

                        Text {
                            text: "H " + Math.round(weatherService.highTemp) + weatherService.temperatureUnitSymbol
                            font.pixelSize: 20
                            font.weight: Font.Medium
                            font.letterSpacing: 0.5
                            color: "white"
                        }

                        Rectangle {
                            width: 1.5
                            height: 24
                            color: "white"
                            opacity: 0.4
                        }

                        Text {
                            text: "L " + Math.round(weatherService.lowTemp) + weatherService.temperatureUnitSymbol
                            font.pixelSize: 20
                            font.weight: Font.Medium
                            font.letterSpacing: 0.5
                            color: "white"
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Premium Glassmorphic Details Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.showDetailedWeather ? 340 : 160
                    color: "#35FFFFFF"
                    border.color: "#50FFFFFF"
                    border.width: 1.5
                    radius: 28

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 0.6
                        blurMax: 24
                        shadowEnabled: true
                        shadowColor: "#70000000"
                        shadowBlur: 0.8
                        shadowVerticalOffset: 12
                    }

                    Behavior on Layout.preferredHeight {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }

                    GridLayout {
                        anchors.fill: parent
                        anchors.margins: 28
                        columns: 2
                        rowSpacing: 24
                        columnSpacing: 24

                        WeatherDetailItem {
                            Layout.fillWidth: true
                            icon: weatherService.currentPlanet === "Mars" ? "🔘" : "💧"
                            label: weatherService.currentPlanet === "Mars" ? "Pressure" : "Humidity"
                            value: weatherService.currentPlanet === "Mars" ?
                                   weatherService.humidity + " Pa" :
                                   weatherService.humidity + "%"
                        }

                        WeatherDetailItem {
                            Layout.fillWidth: true
                            icon: "💨"
                            label: "Wind"
                            value: Math.round(weatherService.windSpeed) + " mph"
                        }

                        WeatherDetailItem {
                            Layout.fillWidth: true
                            icon: "🌡️"
                            label: "Feels Like"
                            value: Math.round(weatherService.feelsLike) + weatherService.temperatureUnitSymbol
                        }

                        WeatherDetailItem {
                            Layout.fillWidth: true
                            icon: "☀️"
                            label: "UV Index"
                            value: weatherService.uvIndex.toString()
                        }

                        // Additional details shown when expanded
                        WeatherDetailItem {
                            Layout.fillWidth: true
                            visible: root.showDetailedWeather
                            opacity: root.showDetailedWeather ? 1 : 0
                            icon: "🔺"
                            label: "High"
                            value: Math.round(weatherService.highTemp) + weatherService.temperatureUnitSymbol

                            Behavior on opacity {
                                NumberAnimation { duration: 300 }
                            }
                        }

                        WeatherDetailItem {
                            Layout.fillWidth: true
                            visible: root.showDetailedWeather
                            opacity: root.showDetailedWeather ? 1 : 0
                            icon: "🔻"
                            label: "Low"
                            value: Math.round(weatherService.lowTemp) + weatherService.temperatureUnitSymbol

                            Behavior on opacity {
                                NumberAnimation { duration: 300 }
                            }
                        }

                        WeatherDetailItem {
                            Layout.fillWidth: true
                            Layout.columnSpan: 2
                            visible: root.showDetailedWeather
                            opacity: root.showDetailedWeather ? 1 : 0
                            icon: weatherService.weatherIcon
                            label: "Condition"
                            value: weatherService.description

                            Behavior on opacity {
                                NumberAnimation { duration: 300 }
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.preferredHeight: 12 }
    }

    // Refined Weather Detail Component
    component WeatherDetailItem: RowLayout {
        property string icon: ""
        property string label: ""
        property string value: ""

        spacing: 14

        Text {
            text: icon
            font.pixelSize: 32

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#60000000"
                shadowBlur: 0.4
                shadowVerticalOffset: 2
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: label
                font.pixelSize: 13
                font.weight: Font.Medium
                font.letterSpacing: 0.5
                color: "white"
                opacity: 0.75

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "#80000000"
                    shadowBlur: 0.2
                    shadowVerticalOffset: 1
                }
            }

            Text {
                text: value
                font.pixelSize: 24
                font.weight: Font.DemiBold
                font.letterSpacing: 0.3
                color: "white"

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "#80000000"
                    shadowBlur: 0.3
                    shadowVerticalOffset: 2
                }
            }
        }
    }
}
