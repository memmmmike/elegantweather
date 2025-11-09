# AI Weather Agent Setup Guide

## Overview
The AI Weather Agent integration adds a conversational AI chatbot to Elegant Weather using Ollama and local language models.

## Prerequisites Completed ✅
- [x] Python service wrapper created
- [x] Qt/C++ integration layer implemented
- [x] Chat UI interface added to application
- [x] Build successful

## Remaining Setup Steps

### 1. Install Ollama

**On Linux (Fedora/RHEL):**
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

**Verify installation:**
```bash
ollama --version
```

### 2. Pull an AI Model

Download the Llama 3.2 model (recommended, ~2GB):
```bash
ollama pull llama3.2
```

**Alternative models you can use:**
```bash
ollama pull gemma2:2b    # Smaller, faster (~1.6GB)
ollama pull mistral      # More capable (~4GB)
```

**Verify model installation:**
```bash
ollama list
```

### 3. Install Python Dependencies

Navigate to the weather-ai-agent directory and install dependencies:

```bash
cd /home/mlayug/ElegantWeather/weather-ai-agent
python3 -m pip install --user -r requirements.txt
```

**Or using a virtual environment (recommended):**
```bash
cd /home/mlayug/ElegantWeather/weather-ai-agent
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 4. Start Ollama Service

The Ollama service needs to be running for the AI agent to work:

```bash
# Check if Ollama is running
systemctl status ollama

# If not running, start it
ollama serve
```

Or run it in the background:
```bash
ollama serve &
```

### 5. Test the Integration

1. Launch Elegant Weather from Qt Creator or run `./ElegantWeather`
2. Click the 💬 chat button in the header
3. The AI service will start (you'll see "Initializing AI service..." message)
4. Once ready, you can ask questions like:
   - "What's the weather like?"
   - "Will it rain tomorrow?"
   - "Should I bring an umbrella?"
   - "How does it feel outside?"

## Troubleshooting

### AI Service Won't Start
**Error:** "Failed to start AI service"
- Make sure Python 3 is installed: `python3 --version`
- Check if dependencies are installed: `cd weather-ai-agent && python3 -c "import ollama; import smartfunc"`
- Install missing dependencies: `pip install --user ollama smartfunc python-weather`

### "Ollama not running" Error
- Start the Ollama service: `ollama serve`
- Or install Ollama if not present: `curl -fsSL https://ollama.com/install.sh | sh`

### Model Not Found
- Pull the model: `ollama pull llama3.2`
- Check installed models: `ollama list`
- Update .env file if using a different model:
  ```bash
  echo 'MODEL="gemma2:2b"' > weather-ai-agent/.env
  ```

### Slow Responses
- Use a smaller model: `ollama pull gemma2:2b` and update .env
- Close other applications to free up RAM
- Check CPU/RAM usage: `htop`

## Architecture

```
┌─────────────┐
│  QML UI     │ (ChatDialog.qml)
│  (Chat)     │
└──────┬──────┘
       │
       │ Q_INVOKABLE calls
       │
┌──────▼──────┐
│  C++ Layer  │ (AIAgent class)
│  (QProcess) │
└──────┬──────┘
       │
       │ JSON over stdin/stdout
       │
┌──────▼──────┐
│  Python     │ (service.py wrapper)
│  Service    │
└──────┬──────┘
       │
       │ imports
       │
┌──────▼──────┐
│  Weather    │ (weather-ai-agent)
│  AI Agent   │
└──────┬──────┘
       │
       ├─► Ollama (Local LLM)
       └─► python-weather (Weather API)
```

## Features

- **Natural Language Queries**: Ask questions in plain English
- **Context-Aware**: Knows your current location from the main app
- **Real-time Weather Data**: Uses python-weather library for current conditions
- **Local Processing**: All AI processing happens on your machine
- **Beautiful UI**: Modern chat interface with message bubbles

## Configuration

Edit `/home/mlayug/ElegantWeather/weather-ai-agent/.env` to change settings:

```env
MODEL="llama3.2"          # Change to gemma2:2b or mistral
```

## Next Steps

Once setup is complete, you can enhance the integration by:
1. Adding weather alerts to chat
2. Implementing multi-turn conversations
3. Adding voice input/output
4. Integrating with calendar for weather-based suggestions
