"""Functions to connect to database and execute SQL"""
import sqlite3


def _connection():
    connection = sqlite3.connect("episense.db")
    connection.row_factory = sqlite3.Row
    return connection


def execute(statement, *args, commit=False):
    """Executes sql command with given arguments"""
    assert type(commit) == bool
    with _connection() as connection:
        cursor = connection.cursor()
        cursor.execute(statement, args)

        if commit:
            connection.commit()

    return cursor
