"""Routes for retrieving and creating video warnings"""

import database
import http
import json
from flask import Blueprint, Response, request
from sqlite3 import IntegrityError


blueprint = Blueprint("warnings", __name__)


@blueprint.route("/<video_id>/warnings/<warning_id>", methods=["GET"])
def get_warning(video_id, warning_id):
    """Gets a warning for a video based on the video id and the warning id"""

    cursor = database.execute(
        """
        SELECT warning_id, warning_created, warning_start, warning_end,
               warning_description, warning_source
        FROM Warnings
        WHERE warning_video_id = ?
        AND
        warning_id = ?
        """,
        video_id,
        warning_id,
    )

    row = cursor.fetchone()

    if row is None:
        return Response(status=http.HTTPStatus.NOT_FOUND)
    else:
        return Response(response=json.dumps(dict(row)),
                        headers={"Content-Type": "text/json"},
                        status=http.HTTPStatus.OK)


@blueprint.route("/<video_id>/warnings", methods=["GET"])
def get_warnings(video_id):
    """Gets all warnings for a video. Can pass a query parameter `source` to
    specify computer or user generated warnings.
    """

    warning_source = request.args.get("source", default=None)

    if not warning_source:
        cursor = database.execute(
            """
            SELECT warning_id, warning_created, warning_start, warning_end,
                   warning_description, warning_source
            FROM Warnings
            WHERE warning_video_id = ?
            """,
            video_id,
        )
    elif warning_source not in ("AUTO", "USER"):
        return Response(status=http.HTTPStatus.BAD_REQUEST)
    else:
        cursor = database.execute(
            """
            SELECT warning_id, warning_created, warning_start, warning_end,
                   warning_description, warning_source
            FROM Warnings
            WHERE warning_video_id = ?
                  AND
                  warning_source = ?
            """,
            video_id,
            warning_source,
        )

    rows = cursor.fetchall()

    if rows is None:
        return Response(status=http.HTTPStatus.NOT_FOUND)
    else:
        return Response(
            response=json.dumps(list(map(dict, rows))),
            headers={"Content-Type": "text/json"},
            status=http.HTTPStatus.OK
        )


@blueprint.route("/<video_id>/warnings", methods=["POST"])
def create_warning(video_id):
    """Create user generated warning for the video"""

    try:
        request_data = request.get_json()

        if not request_data or any(
            x not in request_data for x in ("start", "stop", "description")
        ):
            print("missing field", request_data)
            return Response(status=http.HTTPStatus.BAD_REQUEST)
        start = request_data["start"]
        stop = request_data["stop"]
        description = request_data["description"]

        cursor = database.execute(
            """
            INSERT INTO Warnings (warning_video_id, warning_start, warning_end,
            warning_description, warning_source)
            VALUES (?, ?, ?, ?, "USER")
            """,
            video_id,
            start,
            stop,
            description,
            commit=True,
        )

        new_id = cursor.lastrowid

        return Response(
            headers={
                "Location": f"/api/videos/{video_id}/warnings/{new_id}",
            },
            status=http.HTTPStatus.CREATED,
        )

    except (IntegrityError) as e:
        print(e)
        return Response(status=http.HTTPStatus.BAD_REQUEST)


@blueprint.route("/<video_id>/warnings/generate", methods=["POST"])
def generate_warnings(video_id):
    """Generate warnings for video"""

    return Response(status=http.HTTPStatus.NOT_IMPLEMENTED)
