"""Simple server. Right now just has a single route for screening videos."""

from flask import Flask
from routes import videos

app = Flask(__name__)


app.register_blueprint(videos.blueprint, url_prefix="/videos")
