CREATE TABLE IF NOT EXISTS Videos (
    video_id INTEGER PRIMARY KEY AUTOINCREMENT,
    video_vid TEXT NOT NULL UNIQUE,
    video_title TEXT NOT NULL,
    videos_data_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Warnings (
    warning_id INTEGER PRIMARY KEY AUTOINCREMENT,
    warning_video_id INTEGER NOT NULL,
    warning_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    warning_start INTEGER NOT NULL,
    warning_end INTEGER NOT NULL,
    warning_description TEXT NOT NULL,
    warning_source CHECK( warning_source IN ('AUTO','USER') ) NOT NULL,
    FOREIGN KEY (warning_video_id) REFERENCES Videos(video_id)
);
