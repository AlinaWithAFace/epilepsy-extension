#!/usr/bin/env/ bash


# Create a video
curl -i --header "Content-Type: application/json" --request POST \
    --data '{ "vid": "dQw4w9WgXcQ" }' \
    "http://127.0.0.1:5000/api/videos"


# Get a video by vid:
curl -i "http://127.0.0.1:5000/api/videos?vid=4jXEuIHY9ic"

# Get all videos:
curl -i "http://127.0.0.1:5000/api/videos"

# Get a video:
curl -i "http://127.0.0.1:5000/api/videos/1"

# Get all warning:
curl -i "http://127.0.0.1:5000/api/videos/1/warnings"

# Get a warning:
curl -i "http://127.0.0.1:5000/api/videos/1/warnings/1"

# Create a warning:
curl -i --header "Content-Type: application/json" --request POST \
    --data '{ "start": 3, "stop": 11, "description": "This section might be bad" }' \
    "http://127.0.0.1:5000/api/videos/2/warnings"
