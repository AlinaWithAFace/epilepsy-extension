"""
So, the goal here is to build a dataset of trigger seizure videos
They're generally flashy lights of contrasting colors
We'll start with solid for now, then maybe move on to stripes
We'll vary the colors themselves and the amount of time for each color
"""
import random

import cv2
import numpy as np
from cv2 import VideoWriter, VideoWriter_fourcc

# random.seed(10)
# manually set the seed, for now, for uh testing

number_of_videos = 10

width = 1280
height = 720
FPS = 24
radius = 150
paint_h = int(height / 2)

min_length = 5
max_length = 10

"""
We're storing colors in tuples of (colorcode, string), so we can easily make filenames with the strings dynamically
friendly reminder that opencv is wonky and uses (BGR) color codes as opposed to (RGB) because...reasons...
that were good once...
"""

red = ((0, 0, 255), "red")
blue = ((255, 0, 0), "blue")
green = ((0, 255, 0), "green")
black = ((0, 0, 0), "black")
white = ((255, 255, 255), "white")

colors = [
    red, blue, green, black, white
]


def generate_video():
    seconds = random.randint(min_length, max_length)

    random.shuffle(colors)
    # initial shuffle so we have random colors in the front to work with

    colors[0:1] = sorted(colors[0:1])
    # sort the first two, so we avoid having things like green-white and also white-green
    # TODO it doesn't actually work and idk why, we still get green-white and white-green, not a huge deal tho
    # might be how the sort works with tuples?

    fourcc = VideoWriter_fourcc(*'MP42')

    filename = './data/{}-{}-{}.avi'.format(colors[1][1], colors[0][1], seconds)
    print(filename)
    video = VideoWriter(filename, fourcc, float(FPS), (width, height))

    for _ in range(FPS * seconds):
        frame = np.zeros((height, width, 3), np.uint8)

        if _ % 2 == 0:
            frame[:, 0:width] = colors[0][0]
        else:
            frame[:, 0:width] = colors[1][0]

        video.write(frame)

    video.release()


for _ in range(0, number_of_videos):
    generate_video()
