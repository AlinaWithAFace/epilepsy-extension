"""Simple server. Right now just has a single route for screening videos."""

from flask import Flask
from routes import videos, warnings

app = Flask(__name__)


app.register_blueprint(videos.blueprint, url_prefix="/videos")
app.register_blueprint(warnings.blueprint, url_prefix="/videos")
