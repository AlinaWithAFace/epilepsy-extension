from typing import TypedDict, Tuple, List
import pafy
import cv2
from flask import Flask, request

app = Flask(__name__)


class ScreenResults(TypedDict):
    message: str
    risk_segements: List[Tuple[int, int]]


@app.route('/screen-video', methods=['POST'])
def show_user_profile() -> ScreenResults:
    body = request.get_json()
    if 'url' not in body:
        return {"error": "Missing url"}, 400
    watch_url = request.get_json()['url']
    try:
        vid = pafy.new(watch_url)
        vid_url = vid.getbestvideo(preftype="mp4").url
        capture = cv2.VideoCapture(vid_url)
    except ValueError:
        return {"error": "Url must be a YouTube video"}, 400

    print(capture)

    return {
        "message": ("Classifier has not been implemented"),
        "risk_segements": [(1, 2), (5, 6)]
    }, 201
