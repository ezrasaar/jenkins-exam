from flask import Flask
from app.main import app_info

app = Flask(__name__)


@app.get("/")
def index():
    return app_info()

@app.get("/health")
def health():
    return {"status": "ok"}, 200
