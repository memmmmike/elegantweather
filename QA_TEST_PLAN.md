# Elegant Weather - QA Test Plan

## Test Environment
- Platform: Linux Fedora 43
- Qt Version: 6.10.0
- Python: 3.14.0
- Ollama: 0.12.10
- Model: llama3.2

## 1. Earth Weather Functionality ☐

### 1.1 City Search
- [ ] Search for "New York" - verify weather displays
- [ ] Search for "London" - verify weather updates
- [ ] Search for "Tokyo" - verify international city works
- [ ] Test autocomplete suggestions appear
- [ ] Test selecting from autocomplete dropdown
- [ ] Test renamed cities (e.g., "Utqiagvik" maps to "Barrow")

### 1.2 Weather Display
- [ ] Current temperature displays
- [ ] High/Low temperatures display
- [ ] Weather description shows (e.g., "Clear", "Cloudy")
- [ ] Weather icon animates in
- [ ] Humidity percentage shows
- [ ] Wind speed in mph shows
- [ ] Feels like temperature shows
- [ ] UV index displays

### 1.3 Background Images
- [ ] City background loads from Unsplash
- [ ] Background changes when city changes
- [ ] Fallback gradient shows while loading
- [ ] Time-of-day is reflected (morning/sunset/night)
- [ ] Dark overlay applies for text readability

## 2. Mars Weather Functionality ☐

### 2.1 Planet Switching
- [ ] Switch to Mars in settings
- [ ] Mars gradient background displays
- [ ] Search card disappears (Earth only)
- [ ] Weather data shows "Mars" as location
- [ ] Temperature shows (can be negative)
- [ ] Pressure shows in Pa instead of humidity
- [ ] Wind speed displays

### 2.2 Data Persistence
- [ ] Switching to Mars clears Earth data immediately
- [ ] No Earth city name shows when on Mars
- [ ] Switching back to Earth restores last city
- [ ] No Mars data persists when switching to Earth

## 3. Settings Dialog ☐

### 3.1 Opening/Closing
- [ ] Settings button (⚙) opens dialog
- [ ] Background blurs when settings open
- [ ] Dialog is centered and modal
- [ ] Close button (✕) works
- [ ] Cancel button closes without saving

### 3.2 API Key Management
- [ ] OpenWeatherMap key field accepts input
- [ ] Unsplash key field accepts input
- [ ] Keys are masked (password field)
- [ ] Save Settings button persists keys
- [ ] Keys are remembered on app restart
- [ ] Dialog opens on first run if no API key

### 3.3 Planet Selector
- [ ] Earth button selects Earth
- [ ] Mars button selects Mars
- [ ] Selected planet is highlighted
- [ ] Planet change is saved
- [ ] Animation on selection works

## 4. AI Chat Functionality ☐

### 4.1 Service Startup
- [ ] Chat button (💬) opens dialog
- [ ] "Initializing AI service..." shows briefly
- [ ] Service becomes ready (status changes)
- [ ] Current city/location displays in header
- [ ] No errors in startup

### 4.2 Weather Context
- [ ] AI knows current city
- [ ] AI knows current temperature
- [ ] AI knows high/low temps
- [ ] AI knows UV index
- [ ] AI knows humidity
- [ ] AI knows wind speed
- [ ] AI knows feels like temp
- [ ] Weather context updates when city changes

### 4.3 Conversation
- [ ] "What's the temperature?" - returns current temp
- [ ] "What's the high gonna be?" - returns high temp
- [ ] "Should I wear sunscreen?" - considers UV index
- [ ] "How does it feel outside?" - mentions feels like
- [ ] "Is it humid?" - discusses humidity
- [ ] "Is it windy?" - mentions wind speed
- [ ] Chat history persists during session
- [ ] User messages appear on left (blue)
- [ ] AI messages appear on right (white)
- [ ] Messages auto-scroll to bottom

### 4.4 Input/Output
- [ ] Text input field works
- [ ] Enter key sends message
- [ ] Send button (📤) works
- [ ] Input disabled while processing
- [ ] Loading animation shows during AI response
- [ ] Can't send empty messages

## 5. Edge Cases & Error Handling ☐

### 5.1 Network Errors
- [ ] Invalid city name shows error
- [ ] Network timeout handled gracefully
- [ ] API rate limiting handled
- [ ] Missing API key shows appropriate message

### 5.2 AI Service Errors
- [ ] AI service crash recovers
- [ ] Ollama not running shows error
- [ ] Python not found shows error
- [ ] Service restart works

### 5.3 UI Edge Cases
- [ ] Very long city names don't break layout
- [ ] Very long AI responses wrap properly
- [ ] Rapid city changes don't crash
- [ ] Opening/closing dialogs repeatedly works
- [ ] Resize window - layout adapts

### 5.4 Data Validation
- [ ] Temperature of 0 is valid (not treated as "no data")
- [ ] Negative temperatures display correctly (Mars, winter)
- [ ] Special characters in city names work
- [ ] Empty/null responses handled

## 6. Performance ☐

### 6.1 Load Times
- [ ] App starts in < 3 seconds
- [ ] City search responds in < 2 seconds
- [ ] AI chat responds in < 10 seconds
- [ ] Background images load asynchronously
- [ ] No UI freezing during operations

### 6.2 Memory
- [ ] No memory leaks after multiple city changes
- [ ] Background images are cached
- [ ] AI service doesn't consume excessive RAM

## 7. Cross-Feature Integration ☐

- [ ] Change city in main app → AI chat updates
- [ ] Switch planet → AI context changes
- [ ] Set API key → weather immediately fetches
- [ ] Close chat dialog → AI service stops gracefully
- [ ] Blur effect applies to both Earth and Mars backgrounds

## Test Results Summary

**Pass Rate:** __/__
**Critical Issues:**
**Minor Issues:**
**Notes:**
