import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Dialog {
    id: settingsDialog
    title: "Settings"
    modal: true
    anchors.centerIn: parent

    width: Math.min(480, parent.width * 0.85)
    height: Math.min(680, parent.height * 0.9)

    background: Rectangle {
        radius: 24
        color: "#1a1a1a"

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#000000"
            shadowBlur: 1.0
            shadowVerticalOffset: 20
        }
    }

    padding: 0

    onOpened: {
        // Load existing API keys when dialog opens
        apiKeyField.text = weatherService.apiKey()
        unsplashKeyField.text = weatherService.unsplashAccessKey()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Minimal Header
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 80

            Text {
                anchors.centerIn: parent
                text: "Settings"
                font.pixelSize: 28
                font.weight: Font.Light
                font.letterSpacing: 2
                color: "white"
                opacity: 0.95

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "#60000000"
                    shadowBlur: 0.3
                    shadowVerticalOffset: 2
                }
            }

            Button {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 20
                text: "×"
                onClicked: settingsDialog.close()

                background: Rectangle {
                    implicitWidth: 36
                    implicitHeight: 36
                    color: parent.pressed ? "#30FFFFFF" : (parent.hovered ? "#20FFFFFF" : "transparent")
                    radius: 18
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
                }
            }
        }

        // Content Area
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: settingsDialog.availableWidth
                spacing: 32

                Item { height: 8 }

                // Planet Selection - Compact
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 40
                    Layout.rightMargin: 40
                    spacing: 12

                    Text {
                        text: "PLANET"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.5
                        color: "white"
                        opacity: 0.7
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Repeater {
                            model: ["Earth", "Mars"]

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 44
                                text: modelData

                                background: Rectangle {
                                    color: weatherService.currentPlanet === modelData ? "#30FFFFFF" : "transparent"
                                    border.color: "#40FFFFFF"
                                    border.width: 1
                                    radius: 22

                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }

                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    font.letterSpacing: 0.5
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: weatherService.currentPlanet = modelData

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onPressed: mouse.accepted = false
                                }
                            }
                        }
                    }
                }

                // Temperature Unit - Compact
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 40
                    Layout.rightMargin: 40
                    spacing: 12

                    Text {
                        text: "TEMPERATURE"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.5
                        color: "white"
                        opacity: 0.7
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Repeater {
                            model: ["Celsius", "Fahrenheit"]

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 44
                                text: modelData === "Celsius" ? "°C" : "°F"

                                background: Rectangle {
                                    color: weatherService.temperatureUnit === modelData ? "#30FFFFFF" : "transparent"
                                    border.color: "#40FFFFFF"
                                    border.width: 1
                                    radius: 22

                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }

                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 16
                                    font.weight: Font.Medium
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: weatherService.temperatureUnit = modelData

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onPressed: mouse.accepted = false
                                }
                            }
                        }
                    }
                }

                // Time Format - Compact
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 40
                    Layout.rightMargin: 40
                    spacing: 12

                    Text {
                        text: "TIME FORMAT"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.5
                        color: "white"
                        opacity: 0.7
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Repeater {
                            model: [{"value": "12", "label": "12h"}, {"value": "24", "label": "24h"}]

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 44
                                text: modelData.label

                                background: Rectangle {
                                    color: weatherService.timeFormat === modelData.value ? "#30FFFFFF" : "transparent"
                                    border.color: "#40FFFFFF"
                                    border.width: 1
                                    radius: 22

                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }

                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: weatherService.timeFormat = modelData.value

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onPressed: mouse.accepted = false
                                }
                            }
                        }
                    }
                }

                // Language - Refined
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 40
                    Layout.rightMargin: 40
                    spacing: 12

                    Text {
                        text: "LANGUAGE"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.5
                        color: "white"
                        opacity: 0.7
                    }

                    ComboBox {
                        id: languageComboBox
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        currentIndex: {
                            var langs = ["en", "es", "fr", "de", "it", "pt", "ru", "zh", "ja", "ko"]
                            return langs.indexOf(weatherService.language)
                        }

                        model: ["English", "Español", "Français", "Deutsch", "Italiano", "Português", "Русский", "中文", "日本語", "한국어"]

                        background: Rectangle {
                            color: "transparent"
                            border.color: "#40FFFFFF"
                            border.width: 1
                            radius: 24
                        }

                        contentItem: Text {
                            text: languageComboBox.displayText
                            font.pixelSize: 14
                            font.letterSpacing: 0.3
                            color: "white"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 20
                        }

                        delegate: ItemDelegate {
                            width: languageComboBox.width
                            height: 44

                            background: Rectangle {
                                color: parent.hovered ? "#20FFFFFF" : "transparent"
                            }

                            contentItem: Text {
                                text: modelData
                                font.pixelSize: 14
                                color: "white"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 20
                            }
                        }

                        popup: Popup {
                            y: languageComboBox.height + 4
                            width: languageComboBox.width
                            padding: 8

                            background: Rectangle {
                                color: "#2a2a2a"
                                radius: 16
                                border.color: "#40FFFFFF"
                                border.width: 1

                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowColor: "#000000"
                                    shadowBlur: 0.6
                                    shadowVerticalOffset: 8
                                }
                            }

                            contentItem: ListView {
                                clip: true
                                model: languageComboBox.popup.visible ? languageComboBox.delegateModel : null
                                currentIndex: languageComboBox.highlightedIndex
                                ScrollIndicator.vertical: ScrollIndicator { }
                            }
                        }

                        onActivated: {
                            var langs = ["en", "es", "fr", "de", "it", "pt", "ru", "zh", "ja", "ko"]
                            weatherService.language = langs[currentIndex]
                        }
                    }
                }

                // API Keys - Minimal
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 40
                    Layout.rightMargin: 40
                    spacing: 20

                    Text {
                        text: "API KEYS"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.5
                        color: "white"
                        opacity: 0.7
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "OpenWeatherMap"
                            font.pixelSize: 12
                            font.letterSpacing: 0.3
                            color: "white"
                            opacity: 0.8
                        }

                        TextField {
                            id: apiKeyField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            placeholderText: "Enter API key..."
                            echoMode: TextInput.Password
                            font.pixelSize: 13
                            color: "white"
                            placeholderTextColor: "#60FFFFFF"

                            background: Rectangle {
                                color: "transparent"
                                border.color: parent.activeFocus ? "#60FFFFFF" : "#40FFFFFF"
                                border.width: 1
                                radius: 22

                                Behavior on border.color { ColorAnimation { duration: 200 } }
                            }

                            leftPadding: 20
                            rightPadding: 20
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Unsplash (Optional)"
                            font.pixelSize: 12
                            font.letterSpacing: 0.3
                            color: "white"
                            opacity: 0.8
                        }

                        TextField {
                            id: unsplashKeyField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            placeholderText: "Enter access key..."
                            echoMode: TextInput.Password
                            font.pixelSize: 13
                            color: "white"
                            placeholderTextColor: "#60FFFFFF"

                            background: Rectangle {
                                color: "transparent"
                                border.color: parent.activeFocus ? "#60FFFFFF" : "#40FFFFFF"
                                border.width: 1
                                radius: 22

                                Behavior on border.color { ColorAnimation { duration: 200 } }
                            }

                            leftPadding: 20
                            rightPadding: 20
                        }
                    }
                }

                Item { height: 20 }
            }
        }

        // Footer with Save Button
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 80

            Button {
                anchors.centerIn: parent
                width: 200
                height: 48
                text: "Save"

                onClicked: {
                    // Always save settings - setters will handle empty values
                    weatherService.setApiKey(apiKeyField.text)
                    weatherService.setUnsplashAccessKey(unsplashKeyField.text)
                    settingsDialog.accept()
                }

                background: Rectangle {
                    color: parent.pressed ? "#FFFFFF" : (parent.hovered ? "#F5F5F5" : "#E8E8E8")
                    radius: 24

                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1
                    color: "#1a1a1a"
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
}
