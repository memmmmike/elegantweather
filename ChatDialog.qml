import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Dialog {
    id: chatDialog
    title: "Weather AI Chat"
    modal: true
    anchors.centerIn: parent

    // Responsive sizing - adapt to parent window
    width: Math.min(580, parent.width * 0.92)
    height: Math.min(760, parent.height * 0.96)

    background: Rectangle {
        radius: 28
        color: "#1a1a1a"

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#000000"
            shadowBlur: 1.0
            shadowVerticalOffset: 20
        }
    }

    // No padding - custom layout inside
    padding: 0

    Component.onCompleted: {
        aiAgent.startService()
    }

    // Helper function to update AI with current weather data
    function updateWeatherData() {
        if (aiAgent.isReady && weatherService.city && weatherService.temperature !== 0) {
            var weatherData = {
                "city": weatherService.city,
                "temperature": weatherService.temperature,
                "description": weatherService.description,
                "high_temp": weatherService.highTemp,
                "low_temp": weatherService.lowTemp,
                "humidity": weatherService.humidity,
                "wind_speed": weatherService.windSpeed,
                "feels_like": weatherService.feelsLike,
                "uv_index": weatherService.uvIndex,
                "weather_icon": weatherService.weatherIcon
            }
            aiAgent.setWeatherData(weatherService.city, weatherData)
        }
    }

    // Auto-set weather data when service becomes ready
    Connections {
        target: aiAgent
        function onIsReadyChanged() {
            if (aiAgent.isReady) {
                updateWeatherData()
            }
        }
    }

    // Update AI when weather data changes (new city searched)
    Connections {
        target: weatherService
        function onWeatherDataChanged() {
            updateWeatherData()
        }
    }

    Component.onDestruction: {
        aiAgent.stopService()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Minimal Black Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 88
            radius: 28

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#2a2a2a" }
                GradientStop { position: 1.0; color: "#1a1a1a" }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height / 2
                color: "#1a1a1a"
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 18

                Rectangle {
                    Layout.preferredWidth: 52
                    Layout.preferredHeight: 52
                    color: "#40FFFFFF"
                    border.color: "#60FFFFFF"
                    border.width: 1.5
                    radius: 26

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "#40000000"
                        shadowBlur: 0.3
                        shadowVerticalOffset: 4
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "AI"
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        font.letterSpacing: 1
                        color: "white"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: "Weather AI Assistant"
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.5
                        color: "white"

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: "#60000000"
                            shadowBlur: 0.3
                            shadowVerticalOffset: 2
                        }
                    }

                    Text {
                        text: {
                            if (!aiAgent.isReady) return "Initializing..."
                            if (aiAgent.currentLocation) return aiAgent.currentLocation
                            return "Ready to chat"
                        }
                        font.pixelSize: 14
                        font.letterSpacing: 0.2
                        color: "white"
                        opacity: 0.9
                    }
                }

                Button {
                    text: "×"
                    onClicked: chatDialog.close()

                    background: Rectangle {
                        implicitWidth: 42
                        implicitHeight: 42
                        color: parent.pressed ? "#40FFFFFF" : (parent.hovered ? "#30FFFFFF" : "transparent")
                        radius: 21

                        Behavior on color {
                            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 28
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: mouse.accepted = false
                    }
                }
            }
        }

        // Elegant Status/Error Message
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            Layout.margins: 16
            visible: aiAgent.error !== "" || !aiAgent.isReady
            color: aiAgent.error !== "" ? "#402a1a1a" : "#403a3a3a"
            border.color: aiAgent.error !== "" ? "#60EF4444" : "#60505050"
            border.width: 1.5
            radius: 14

            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 0.3
                blurMax: 12
                shadowEnabled: true
                shadowColor: aiAgent.error !== "" ? "#30EF4444" : "#30000000"
                shadowBlur: 0.3
                shadowVerticalOffset: 3
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                Rectangle {
                    Layout.preferredWidth: 8
                    Layout.preferredHeight: 8
                    radius: 4
                    color: aiAgent.error !== "" ? "#EF4444" : "#808080"

                    SequentialAnimation on opacity {
                        running: !aiAgent.error
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.3; duration: 800 }
                        NumberAnimation { from: 0.3; to: 1.0; duration: 800 }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: aiAgent.error !== "" ? aiAgent.error : "Initializing AI service..."
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
                        shadowBlur: 0.2
                        shadowVerticalOffset: 1
                    }
                }
            }
        }

        // Premium Chat Messages Area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"

            ListView {
                id: chatListView
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                clip: true

                model: aiAgent.chatHistory

                delegate: Item {
                    width: chatListView.width
                    height: messageBubble.height + 12

                    property var parts: modelData.split("|")
                    property bool isUser: parts[0] === "user"
                    property string message: parts[1] || ""

                    Rectangle {
                        id: messageBubble
                        anchors.left: isUser ? undefined : parent.left
                        anchors.right: isUser ? parent.right : undefined
                        width: Math.min(parent.width * 0.78, messageText.implicitWidth + 32)
                        height: messageText.implicitHeight + 28
                        color: isUser ? "#2a2a2a" : "#3a3a3a"
                        border.color: isUser ? "#404040" : "#404040"
                        border.width: 1
                        radius: 18

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: "#000000"
                            shadowBlur: 0.4
                            shadowVerticalOffset: 4
                        }

                        Text {
                            id: messageText
                            anchors.fill: parent
                            anchors.margins: 16
                            text: message
                            font.pixelSize: 15
                            font.letterSpacing: 0.2
                            font.weight: Font.Normal
                            color: "white"
                            wrapMode: Text.Wrap
                            lineHeight: 1.4
                        }
                    }
                }

                onCountChanged: {
                    Qt.callLater(positionViewAtEnd)
                }
            }

            // Elegant Empty State
            ColumnLayout {
                anchors.centerIn: parent
                visible: chatListView.count === 0
                spacing: 22
                width: parent.width * 0.75

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 96
                    Layout.preferredHeight: 96
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#3a3a3a" }
                        GradientStop { position: 1.0; color: "#2a2a2a" }
                    }
                    radius: 48

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "#60000000"
                        shadowBlur: 0.8
                        shadowVerticalOffset: 8
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "AI"
                        font.pixelSize: 36
                        font.weight: Font.Bold
                        font.letterSpacing: 2
                        color: "white"

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: "#80000000"
                            shadowBlur: 0.4
                            shadowVerticalOffset: 2
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "Ask me anything about the weather!"
                    font.pixelSize: 22
                    font.weight: Font.Medium
                    font.letterSpacing: 0.3
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "#80000000"
                        shadowBlur: 0.3
                        shadowVerticalOffset: 2
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "I can help you with temperature, forecasts, UV index, and more."
                    font.pixelSize: 15
                    font.letterSpacing: 0.2
                    color: "white"
                    opacity: 0.85
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    lineHeight: 1.5

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "#60000000"
                        shadowBlur: 0.2
                        shadowVerticalOffset: 1
                    }
                }
            }
        }

        // Elegant Loading Indicator
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            visible: aiAgent.isProcessing

            Rectangle {
                anchors.centerIn: parent
                width: 80
                height: 40
                color: "#303a3a3a"
                border.color: "#50505050"
                border.width: 1
                radius: 20

                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 0.2
                    blurMax: 8
                    shadowEnabled: true
                    shadowColor: "#30000000"
                    shadowBlur: 0.3
                    shadowVerticalOffset: 3
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Repeater {
                        model: 3
                        Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: "#808080"

                            layer.enabled: true
                            layer.effect: MultiEffect {
                                shadowEnabled: true
                                shadowColor: "#60000000"
                                shadowBlur: 0.4
                                shadowVerticalOffset: 2
                            }

                            SequentialAnimation on opacity {
                                running: aiAgent.isProcessing
                                loops: Animation.Infinite
                                PauseAnimation {
                                    duration: 200 * index
                                }
                                NumberAnimation {
                                    from: 0.3
                                    to: 1.0
                                    duration: 500
                                    easing.type: Easing.InOutCubic
                                }
                                NumberAnimation {
                                    from: 1.0
                                    to: 0.3
                                    duration: 500
                                    easing.type: Easing.InOutCubic
                                }
                            }
                        }
                    }
                }
            }
        }

        // Premium Glassmorphic Input Area
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 92
            color: "#FFFFFF"
            border.color: "#E2E8F0"
            border.width: 1.5

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#30000000"
                shadowBlur: 0.4
                shadowVerticalOffset: -4
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                TextField {
                    id: chatInput
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    placeholderText: "Ask about the weather..."
                    font.pixelSize: 16
                    font.letterSpacing: 0.2
                    color: "#1a202c"
                    enabled: aiAgent.isReady && !aiAgent.isProcessing
                    wrapMode: Text.Wrap
                    verticalAlignment: Text.AlignVCenter

                    placeholderTextColor: "#94a3b8"

                    background: Rectangle {
                        color: "#F8FAFC"
                        radius: 16
                        border.color: chatInput.activeFocus ? "#667eea" : "#E2E8F0"
                        border.width: 2

                        layer.enabled: chatInput.activeFocus
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: "#40667eea"
                            shadowBlur: 0.4
                            shadowVerticalOffset: 2
                        }

                        Behavior on border.color {
                            ColorAnimation { duration: 250; easing.type: Easing.OutCubic }
                        }
                    }

                    onAccepted: {
                        if (chatInput.text.trim() !== "") {
                            aiAgent.sendQuery(chatInput.text)
                            chatInput.text = ""
                        }
                    }

                    Keys.onReturnPressed: {
                        if (chatInput.text.trim() !== "") {
                            aiAgent.sendQuery(chatInput.text)
                            chatInput.text = ""
                        }
                    }
                }

                Button {
                    Layout.preferredWidth: 56
                    Layout.preferredHeight: 56
                    text: "→"
                    enabled: aiAgent.isReady && !aiAgent.isProcessing && chatInput.text.trim() !== ""

                    onClicked: {
                        if (chatInput.text.trim() !== "") {
                            aiAgent.sendQuery(chatInput.text)
                            chatInput.text = ""
                        }
                    }

                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? "#5a67d8" : "#667eea") : "#E2E8F0"
                        radius: 28

                        layer.enabled: parent.enabled
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: parent.enabled ? "#60667eea" : "#20000000"
                            shadowBlur: 0.6
                            shadowVerticalOffset: 6
                        }

                        Behavior on color {
                            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 28
                        font.weight: Font.Bold
                        color: parent.enabled ? "white" : "#94a3b8"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onPressed: mouse.accepted = false
                    }
                }
            }
        }
    }
}
