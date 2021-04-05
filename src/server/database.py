import sqlite3

def connection():
   connection = sqlite3.connect("episense.db")
   connection.row_factory = sqlite3.Row
   return connection
