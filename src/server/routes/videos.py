"""Routes for retrieving and creating video entities"""

import pafy
import http
import database
import json
from flask import Blueprint, Response
from sqlite3 import IntegrityError

blueprint = Blueprint("videos", __name__)


@blueprint.route("/<video_id>", methods=["GET"])
def get_video_by_id(video_id):
    """Retrieves a video resource via it's identifier"""

    cursor = database.execute(
        """
        SELECT video_id, video_vid, video_title FROM Videos
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


@blueprint.route("/vid/<vid>", methods=["GET"])
def get_video_by_vid(vid):
    """Retrieves a video resource location given a YouTube video identifier"""

    cursor = database.execute(
        """
        SELECT video_id, video_vid, video_title FROM Videos
        WHERE video_vid = ?
        """,
        vid,
    )

    row = cursor.fetchone()

    if not row:
        return Response(status=http.HTTPStatus.NOT_FOUND)
    else:
        video_id = row["video_id"]
        return Response(headers={
                            "Location": f"/videos/{video_id}",
                        },
                        status=http.HTTPStatus.OK)


@blueprint.route("/vid/<vid>", methods=["POST"])
def create_video_by_vid(vid):
    """Creates a video resource using a YouTube video identifier"""

    try:
        video = pafy.new(vid)

        cursor = database.execute(
            """
            INSERT INTO Videos (video_vid, video_title)
            VALUES (?, ?);
            """,
            video.videoid,
            video.title,
            commit=True,
        )
        new_id = cursor.lastrowid

        return Response(
            headers={
                "Location": f"/videos/{new_id}",
            },
            status=http.HTTPStatus.CREATED,
        )

    except (ValueError, IntegrityError, OSError) as e:
        print(e)
        return Response(status=http.HTTPStatus.BAD_REQUEST)
