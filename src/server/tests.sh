#!/usr/bin/env/ bash

# Create a video
curl -i --request POST "http://127.0.0.1:5000/videos/vid/dQw4w9WgXcQ"

# Get a video by vid:
curl -i "http://127.0.0.1:5000/videos/vid/4jXEuIHY9ic"

# Get a video:
curl -i "http://127.0.0.1:5000/videos/10"

# Get a warning:
curl -i "http://127.0.0.1:5000/videos/10/warnings/4"

# Create a warning:
curl -i --header "Content-Type: application/json" --request POST \
    --data '{ "start": 0, "stop": 2, "message": "bad section" }' \
    "http://127.0.0.1:5000/videos/10/warnings"
