"""Routes for retrieving and creating video entities"""

import pafy
import http
import database
import json
from flask import Blueprint, Response, request
from sqlite3 import IntegrityError

blueprint = Blueprint("videos", __name__)


@blueprint.route("/<video_id>", methods=["GET"])
def get_video_by_id(video_id):
    """Retrieves a video resource via it's identifier"""

    cursor = database.execute(
        """
        SELECT video_id, video_vid, video_title, video_screening_status FROM Videos
        WHERE video_id = ?
        """,
        video_id,
    )

    row = cursor.fetchone()

    if not row:
        return Response(status=http.HTTPStatus.NOT_FOUND)
    else:
        return Response(response=json.dumps(dict(row)),
                        headers={"Content-Type": "text/json"},
                        status=http.HTTPStatus.OK)


@blueprint.route("", methods=["GET"])
def get_videos():
    """
    Retrieves a list of available video resources, potentially filtered by
    it's YouTube video id
    """

    data = request.args
    if 'vid' in data:
        cursor = database.execute(
            """
            SELECT video_id, video_vid, video_title, video_screening_status FROM Videos
            WHERE video_vid = ?
            """,
            data['vid'],
        )
    else:
        cursor = database.execute(
            """
            SELECT video_id, video_vid, video_title, video_screening_status FROM Videos
            """
        )

    row = cursor.fetchall()

    if not row:
        return Response(status=http.HTTPStatus.NOT_FOUND)
    else:
        return Response(response=json.dumps(list(map(dict, row))),
                        headers={"Content-Type": "text/json"},
                        status=http.HTTPStatus.OK)


@blueprint.route("", methods=["POST"])
def create_video():
    """Creates a video resource using a YouTube video identifier"""

    try:
        request_data = request.get_json()
        if not request_data or 'vid' not in request_data:
            print("missing field \"vid\" in :", request_data)
            return Response(status=http.HTTPStatus.BAD_REQUEST)

        vid = request_data['vid']

        video = pafy.new(vid)

        cursor = database.execute(
            """
            INSERT INTO Videos (video_vid, video_title, video_duration)
            VALUES (?, ?, ?);
            """,
            video.videoid,
            video.title,
            video.length,
            commit=True,
        )

        new_id = cursor.lastrowid

        return Response(
            headers={
                "Access-Control-Expose-Headers": "Location",
                "Location": f"/api/videos/{new_id}",
            },
            status=http.HTTPStatus.CREATED,
        )

    except (ValueError, IntegrityError, OSError) as e:
        print(e)
        return Response(status=http.HTTPStatus.BAD_REQUEST)
