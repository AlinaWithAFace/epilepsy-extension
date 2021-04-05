"""
Simple server. Right now just has a single route for screening videos.
"""

import pafy
import cv2
from flask import Flask, request
from http import HTTPStatus
import sqlite3

app = Flask(__name__)


# TODO: right now this basically does nothing, it just checks if the link is a
# link to YouTube video and then reads it into an OpenCV video object. Also
# adds link and any warnings to the database
@app.route("/screen-video", methods=["POST"])
def show_user_profile():
    """Screen video for potential PSE triggeres

    Expects a request with a body element `url`, returns a `ScreenResults`
    value and an HTTP status code
    """
    body = request.get_json()

    if "url" not in body:
        return {"error": "Missing URL"}, HTTPStatus.BAD_REQUEST

    watch_url = request.get_json()["url"]

    try:
        vid = pafy.new(watch_url)
        vid_url = vid.getbestvideo(preftype="mp4").url
        capture = cv2.VideoCapture(vid_url)

        # Do analysis here
        warnings = []

        try:
            with sqlite3.connect("episense.db") as con:
                cur = con.cursor()
                cur.execute(
                    """
                    INSERT or IGNORE INTO Videos (url)
                    VALUES (?)
                    """, (watch_url, ))
                con.commit()

                for warning in warnings:
                    cur.execute(
                        """
                        INSERT INTO Warnings (video, start, end)
                        VALUES (?, ?, ?);
                        """, (watch_url, warning.start, warning.end))
                    con.commit()
        except:
            print("DB Error")
            return {"Internal Error", HTTPStatus.INTERNAL_SERVER_ERROR}

    except ValueError:
        return {"error": "URL must be a YouTube video"}, HTTPStatus.BAD_REQUEST
    return {
        "message": "Classifier has not been implemented",
        "risk_segements": [],
    }, HTTPStatus.CREATED
