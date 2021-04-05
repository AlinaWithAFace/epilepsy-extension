import pafy
import http
import sqlite3
import database
from flask import Blueprint

blueprint = Blueprint("videos", __name__)


@blueprint.route("/vid/<vid>", methods=["GET"])
def get_video_by_vid(vid):
    """Retrieves a video resource via a YouTube video identifier

    Input:

    -   `vid`: unique YouTube video identifier

    Returns:

    Dictionary data of the retrieved resource and a http status code
    """

    with database.connection() as connection:
        cursor = connection.cursor()

        cursor.execute(
            """
            SELECT video_id, video_vid, video_title FROM Videos
            WHERE video_vid = ?
            """,
            (vid,),
        )

        row = cursor.fetchone()

        if not row:
            return {}, http.HTTPStatus.NOT_FOUND

        return dict(row), http.HTTPStatus.OK


@blueprint.route("/vid/<vid>", methods=["POST"])
def create_video_by_vid(vid):
    """Creates a video resource

    Input:

    -   `vid`: unique YouTube video identifier

    Returns:

    Dictionary data of the created resource and a http status code
    """

    try:
        video = pafy.new(vid)
    except:
        return {}, http.HTTPStatus.BAD_REQUEST

    with database.connection() as connection:
        cursor = connection.cursor()

        cursor.execute(
            """
            INSERT INTO Videos (video_vid, video_title)
            VALUES (?, ?)
            """,
            (video.videoid, video.title),
        )
