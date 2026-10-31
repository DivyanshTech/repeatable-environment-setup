from http.server import HTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
import os

SERVICE_DIR = Path(__file__).resolve().parent
os.chdir(SERVICE_DIR)

HOST = os.environ.get("APP_HOST", "127.0.0.1")
PORT = int(os.environ.get("APP_PORT", "8000"))

server = HTTPServer((HOST, PORT), SimpleHTTPRequestHandler)

print(f"Sample service running at http://{HOST}:{PORT}")
try:
    server.serve_forever()
except KeyboardInterrupt:
    print("\nSample service stopped.")
    server.server_close()
