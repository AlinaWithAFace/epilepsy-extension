import numpy as np
from cv2 import VideoWriter, VideoWriter_fourcc

width = 1280
height = 720
FPS = 24
seconds = 10
radius = 150
paint_h = int(height / 2)

fourcc = VideoWriter_fourcc(*'MP42')
filename = './data/red-black-seizure-trigger.avi'
video = VideoWriter(filename, fourcc, float(FPS), (width, height))

red = (0, 0, 255)
black = (0, 0, 0)

for _ in range(FPS * seconds):
    frame = np.zeros((height, width, 3), np.uint8)

    if _ % 2 == 0:
        frame[:, 0:width] = red
    else:
        frame[:, 0:width] = black

    video.write(frame)

video.release()
