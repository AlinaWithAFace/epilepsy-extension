CREATE TABLE IF NOT EXISTS Videos (
    video_id INTEGER PRIMARY KEY AUTOINCREMENT,
    video_vid TEXT NOT NULL UNIQUE,
    video_duration INTEGER NOT NULL,
    video_title TEXT NOT NULL,
    video_data_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    video_screening_status CHECK( video_screening_status IN ("STARTED",
            "NOT STARTED", "COMPLETED") ) NOT NULL DEFAULT "NOT STARTED"
);

CREATE TABLE IF NOT EXISTS Warnings (
    warning_id INTEGER PRIMARY KEY AUTOINCREMENT,
    warning_video_id INTEGER NOT NULL,
    warning_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    warning_start INTEGER CHECK ((warning_start >= 0) AND (warning_start <= warning_end)) NOT NULL,
    warning_end INTEGER NOT NULL,
    warning_description TEXT NOT NULL,
    warning_source CHECK( warning_source IN ('AUTO','USER') ) NOT NULL,
    FOREIGN KEY (warning_video_id) REFERENCES Videos(video_id)
);

CREATE TRIGGER trigger_validate_warning_end BEFORE INSERT ON Warnings
WHEN new.warning_end>(SELECT video_duration FROM Videos where video_id = new.warning_video_id)
BEGIN
    SELECT RAISE(ABORT,'Warning start time must not be greater than the video duration');
END;
