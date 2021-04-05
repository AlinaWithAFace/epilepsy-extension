"""
So, the goal here is to build a dataset of trigger seizure videos
They're generally flashy lights of contrasting colors
We'll start with solid for now, then maybe move on to stripes
We'll vary the colors themselves and the amount of time for each color
"""
import random

import cv2
import numpy as np

# from cv2 import VideoWriter, VideoWriter_fourcc

# random.seed(10)
# manually set the seed, for now, for uh testing

number_of_videos = 1

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

# Not quite sure how to dynamically make it stripes or solids yet but here's some stubs

solid = "solid"
vertical_stripes = "vertical_stripes"
horizontal_stripes = "horizontal_stripes"

patterns = [solid, vertical_stripes, horizontal_stripes]
pattern = 0  # the index of the pattern to use from the set in patterns


def draw_stripes(frame, color1, color2):
    # print(color1)
    # print(color2)

    # for i in range(0, 9):
    #     if _ % 2 == 0:
    #         cv2.rectangle(frame,
    #                       (0, int(i * .1 * height)),
    #                       (width, int(i + 1 * .1 * height)),
    #                       color1,
    #                       -1,
    #                       8,
    #                       0)
    #     else:
    #         cv2.rectangle(frame,
    #                       (0, int(i * height)),
    #                       (width, int(i + 1 * height)),
    #                       color2,
    #                       -1,
    #                       8,
    #                       0)

    cv2.rectangle(frame,
                  (0, int(0 * height)),
                  (width, int(.1 * height)),
                  colors[0][0],
                  -1,
                  8,
                  0)
    cv2.rectangle(frame,
                  (0, int(.1 * height)),
                  (width, int(.2 * height)),
                  colors[1][0],
                  -1,
                  8,
                  0)
    cv2.rectangle(frame,
                  (0, int(.2 * height)),
                  (width, int(.3 * height)),
                  colors[0][0],
                  -1,
                  8,
                  0)
    cv2.rectangle(frame,
                  (0, int(.2 * height)),
                  (width, int(.3 * height)),
                  colors[1][0],
                  -1,
                  8,
                  0)
    cv2.rectangle(frame,
                  (0, int(.3 * height)),
                  (width, int(.4 * height)),
                  colors[0][0],
                  -1,
                  8,
                  0)
    cv2.rectangle(frame,
                  (0, int(.4 * height)),
                  (width, int(.5 * height)),
                  colors[1][0],
                  -1,
                  8,
                  0)
    cv2.rectangle(frame,
                  (0, int(.5 * height)),
                  (width, int(.6 * height)),
                  colors[0][0],
                  -1,
                  8,
                  0)
    cv2.rectangle(frame,
                  (0, int(.6 * height)),
                  (width, int(.7 * height)),
                  colors[1][0],
                  -1,
                  8,
                  0)
    cv2.rectangle(frame,
                  (0, int(.7 * height)),
                  (width, int(.8 * height)),
                  colors[0][0],
                  -1,
                  8,
                  0)
    cv2.rectangle(frame,
                  (0, int(.8 * height)),
                  (width, int(.9 * height)),
                  colors[1][0],
                  -1,
                  8,
                  0)

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

    # filename = './synthetic_data/{}-{}-{}.avi'.format(colors[1][1], colors[0][1], seconds)
    filename = "./data/test-video.avi"
    print(filename)
    video = cv2.VideoWriter(filename, fourcc, float(FPS), (width, height))

    # if pattern == 1:
    for _ in range(FPS * seconds):
        frame = np.zeros((height, width, 3), np.uint8)

        video.write(frame)

        # frame = draw_stripes(frame, colors[0][0], colors[1][0])
        frame = draw_stripes(frame, red[0], green[0])

        video.write(frame)
    #
    # else:
    # for _ in range(FPS * seconds):
    #     frame = np.zeros((height, width, 3), np.uint8)
    #
    #     if _ % 2 == 0:
    #         frame[:, 0:width] = colors[0][0]
    #     else:
    #         frame[:, 0:width] = colors[1][0]
    #
    #     video.write(frame)

    video.release()


for _ in range(0, number_of_videos):
    generate_video()
