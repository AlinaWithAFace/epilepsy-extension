"""Simple server. Right now just has a single url for screening videos"""

import pafy
import cv2
from flask import Flask, request
from http import HTTPStatus

app = Flask(__name__)


# TODO: right now this basically does nothing, it just checks if the link is a
# link to YouTube video and then reads it into an OpenCV video object
@app.route("/screen-video", methods=["POST"])
def show_user_profile():
    """Screen video for potential PSE triggeres

    Expects a request with a body element `url`, returns a `ScreenResults`
    value and an HTTP status code
    """
    body = request.get_json()

    if "url" not in body:
        return {"error": "Missing url"}, HTTPStatus.BAD_REQUEST

    watch_url = request.get_json()["url"]

    try:
        vid = pafy.new(watch_url)
        vid_url = vid.getbestvideo(preftype="mp4").url
        capture = cv2.VideoCapture(vid_url)
    except ValueError:
        return {"error": "Url must be a YouTube video"}, HTTPStatus.BAD_REQUEST

    return {
        "message": ("Classifier has not been implemented"),
        "risk_segements": []
    }, HTTPStatus.CREATED
