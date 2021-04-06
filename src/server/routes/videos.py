import pafy
import http
import database
import json
from flask import Blueprint, Response
from sqlite3 import IntegrityError

blueprint = Blueprint("videos", __name__)


@blueprint.route("/<id>", methods=["GET"])
def get_video_by_id(id):
    """Retrieves a video resource via it's id

    Input:

    -   `id`: integer video identifier

    Returns:

    Dictionary data of the retrieved resource and a http status code
    """

    response = Response()

    with database.connection() as connection:
        cursor = connection.cursor()

        cursor.execute(
            """
            SELECT video_id, video_vid, video_title FROM Videos
            WHERE video_id = ?
            """,
            (id,),
        )

        row = cursor.fetchone()

        if not row:
            response.status_code = http.HTTPStatus.NOT_FOUND
        else:
            response.data = json.dumps(dict(row))
            response.status_code = http.HTTPStatus.OK

        return response


@blueprint.route("/vid/<vid>", methods=["GET"])
def get_video_by_vid(vid):
    """Retrieves a video resource via a YouTube video identifier

    Input:

    -   `vid`: unique YouTube video identifier Returns:

    Dictionary data of the retrieved resource and a http status code
    """

    response = Response()

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
            response.status_code = http.HTTPStatus.NOT_FOUND
        else:
            response.data = json.dumps(dict(row))
            response.status_code = http.HTTPStatus.OK

        return response


@blueprint.route("/vid/<vid>", methods=["POST"])
def create_video_by_vid(vid):
    """Creates a video resource

    Input:

    -   `vid`: unique YouTube video identifier

    Returns:

    Dictionary data of the created resource and a http status code
    """

    response = Response()

    try:
        video = pafy.new(vid)

        with database.connection() as connection:
            cursor = connection.cursor()

            cursor.execute(
                """
                INSERT INTO Videos (video_vid, video_title)
                VALUES (?, ?);
                """,
                (video.videoid, video.title),
            )
            new_id = cursor.lastrowid
            connection.commit()

        response.headers["Content-Location"] = f"/videos/{new_id}"
        response.headers["Location"] = f"/videos/{new_id}"
        response.status_code = http.HTTPStatus.CREATED
        return response

    except ValueError:
        response.status_code = http.HTTPStatus.BAD_REQUEST
        return response
    except IntegrityError:
        response.status_code = http.HTTPStatus.BAD_REQUEST
        return response
