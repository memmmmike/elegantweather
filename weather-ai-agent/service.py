#!/usr/bin/env python3
"""
Weather AI Agent Service Wrapper for Qt Integration
Communicates via JSON over stdin/stdout
"""

import sys
import json
from typing import Dict
from lib import analyze, format, isBye

class WeatherAIService:
    def __init__(self):
        self.weather_data: Dict = None
        self.location: str = None

    def handle_request(self, request: Dict) -> Dict:
        """Handle incoming requests from Qt"""
        try:
            command = request.get("command")

            if command == "set_weather":
                # Accept weather data directly from Qt
                location = request.get("location", "")
                weather_data = request.get("weather_data", {})

                self.location = location
                self.weather_data = weather_data

                return {
                    "status": "success",
                    "command": "set_weather",
                    "location": location
                }

            elif command == "query":
                if not self.weather_data:
                    return {
                        "status": "error",
                        "command": "query",
                        "message": "No location set. Please set location first."
                    }

                prompt = request.get("prompt", "")
                if not prompt:
                    return {
                        "status": "error",
                        "command": "query",
                        "message": "No prompt provided"
                    }

                # Check if it's a goodbye message
                if isBye(prompt) or "bye" in prompt.lower():
                    return {
                        "status": "success",
                        "command": "query",
                        "response": "Bye. Have a nice day.",
                        "is_bye": True
                    }

                # Analyze and respond
                response = format(analyze(self.weather_data, prompt))
                return {
                    "status": "success",
                    "command": "query",
                    "response": response,
                    "is_bye": False
                }

            elif command == "ping":
                return {
                    "status": "success",
                    "command": "ping",
                    "message": "pong"
                }

            else:
                return {
                    "status": "error",
                    "message": f"Unknown command: {command}"
                }

        except Exception as e:
            return {
                "status": "error",
                "message": str(e)
            }

    def run(self):
        """Main service loop"""
        # Send ready signal
        sys.stdout.write(json.dumps({"status": "ready"}) + "\n")
        sys.stdout.flush()

        while True:
            try:
                line = sys.stdin.readline()
                if not line:
                    break

                request = json.loads(line.strip())
                response = self.handle_request(request)

                sys.stdout.write(json.dumps(response) + "\n")
                sys.stdout.flush()

            except json.JSONDecodeError as e:
                error_response = {
                    "status": "error",
                    "message": f"Invalid JSON: {str(e)}"
                }
                sys.stdout.write(json.dumps(error_response) + "\n")
                sys.stdout.flush()

            except Exception as e:
                error_response = {
                    "status": "error",
                    "message": f"Service error: {str(e)}"
                }
                sys.stdout.write(json.dumps(error_response) + "\n")
                sys.stdout.flush()

def main():
    service = WeatherAIService()
    service.run()

if __name__ == "__main__":
    main()
