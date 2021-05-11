"""Server to create warnings for videos"""

from flask import Flask
from routes import videos, warnings
from flask_cors import CORS


app = Flask(__name__)
CORS(app)



app.register_blueprint(videos.blueprint, url_prefix="/api/videos")
app.register_blueprint(warnings.blueprint, url_prefix="/api/videos")
