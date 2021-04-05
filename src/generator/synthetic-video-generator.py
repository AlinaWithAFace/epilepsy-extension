"""
So, the goal here is to build a dataset of trigger seizure videos
They're generally flashy lights of contrasting colors
We'll start with solid for now, then maybe move on to stripes
We'll vary the colors themselves and the amount of time for each color
"""
import random

import cv2
import numpy as np

random.seed(10)
# manually set the RNG seed to avoid too much redundant generation

number_of_videos = 100

width = 1280
height = 720
FPS = 24
radius = 150
paint_h = int(height / 2)

# seconds = 0 # randomly initialized between min_length and max_length in generate_video
min_length = 5
max_length = 10

length_of_flash = 1
# frame length of flash, unused but could be a variable
# apparently there's something like a 3 second window if it's too slow? unsure

number_of_colors = 2
# unused, could use multi-color flashes beyond 2

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


def draw_frame(frame, pattern, color1, color2):
    """
    :param frame:
    :param pattern: solid, vertical_stripes, horizontal_stripes
    :param color1:
    :param color2:
    :return:
    """
    if pattern == 1:
        for i in range(0, 10):
            h1 = (i * .1)
            h2 = ((i + 1) * .1)
            if i % 2 == 0:
                cv2.rectangle(frame,
                              (0, int(height * h1)),
                              (width, int(height * h2)),
                              color1,
                              -1,
                              8,
                              0)
            else:
                cv2.rectangle(frame,
                              (0, int(height * h1)),
                              (width, int(height * h2)),
                              color2,
                              -1,
                              8,
                              0)
    elif pattern == 2:
        for i in range(0, 10):
            w1 = (i * .1)
            w2 = ((i + 1) * .1)
            if i % 2 == 0:
                cv2.rectangle(frame,
                              (int(width * w1), 0),
                              (int(width * w2), height),
                              color1,
                              -1,
                              8,
                              0)
            else:
                cv2.rectangle(frame,
                              (int(width * w1), 0),
                              (int(width * w2), height),
                              color2,
                              -1,
                              8,
                              0)
    else:
        frame[:, 0:width] = color1

    return frame


def generate_video():
    seconds = random.randint(min_length, max_length)

    random.shuffle(colors)
    # initial shuffle so we have random colors in the front to work with

    colors[0:1] = sorted(colors[0:1])
    # sort the first two, so we avoid having things like green-white and also white-green
    # TODO it doesn't actually work and idk why, we still get green-white and white-green, not a huge deal tho
    # might be how the sort works with tuples?

    fourcc = cv2.VideoWriter_fourcc(*'MP42')

    pattern = random.randint(0, 2)

    filename = './data/synthetic_data/{}-{}-{}-{}.avi'.format(pattern, colors[1][1], colors[0][1], seconds)
    # filename = "./data/test-video.avi"
    print(filename)
    video = cv2.VideoWriter(filename, fourcc, float(FPS), (width, height))

    for _ in range(FPS * seconds):
        frame = np.zeros((height, width, 3), np.uint8)

        if _ % 2 == 0:
            frame = draw_frame(frame, pattern, colors[0][0], colors[1][0])
        else:
            frame = draw_frame(frame, pattern, colors[1][0], colors[0][0])

        video.write(frame)

    video.release()


for _ in range(0, number_of_videos):
    generate_video()
