import ollama
from typing import Final, Dict
import os
from dotenv import load_dotenv
import json

load_dotenv()
MODEL: Final[str] = os.getenv("MODEL") or "llama3.2"

SYSTEM_PROMPT = """You are an AI agent for a weather API. Provide short, friendly, and to-the-point responses.
Avoid unnecessary words. Do not use Markdown or any formatting—plain text only.
Always keep replies as brief and clear as possible.
Follow this style strictly."""

def analyze(api: Dict, prompt: str) -> str:
    """Analyze weather data and respond to user prompt"""
    try:
        weather_data = json.dumps(api, indent=2)

        full_prompt = f"""Weather data:
{weather_data}

User question: {prompt}

Provide a brief, friendly answer based on the weather data."""

        response = ollama.chat(
            model=MODEL,
            messages=[
                {'role': 'system', 'content': SYSTEM_PROMPT},
                {'role': 'user', 'content': full_prompt}
            ]
        )

        return response['message']['content']
    except Exception as e:
        return f"Sorry, I encountered an error: {str(e)}"

def bye(text: str) -> str:
    """Check if text is a goodbye message"""
    try:
        response = ollama.chat(
            model=MODEL,
            messages=[
                {'role': 'system', 'content': 'Reply with only "1" if the message is a goodbye/farewell, otherwise reply with only "0". No other text.'},
                {'role': 'user', 'content': text}
            ]
        )

        return response['message']['content'].strip()
    except Exception as e:
        return "0"

def isBye(text: str) -> bool:
    """Check if message is a goodbye"""
    response: str = bye(text)
    try:
        return bool(int(response))
    except:
        return False