import cv2
import numpy as np
from cv2 import VideoWriter, VideoWriter_fourcc

width = 1280
height = 720
FPS = 24
seconds = 10
radius = 150
paint_h = int(height / 2)

fourcc = VideoWriter_fourcc(*'MP42')
filename = './data/green-red-seizure-trigger.avi'
video = VideoWriter(filename, fourcc, float(FPS), (width, height))

red = (0, 0, 255)
blue = (255, 0, 0)
green = (0, 255, 0)
black = (0, 0, 0)
white = (255, 255, 255)

for _ in range(FPS * seconds):
    frame = np.zeros((height, width, 3), np.uint8)

    if _ % 2 == 0:
        frame[:, 0:width] = green
    else:
        frame[:, 0:width] = red

    video.write(frame)

video.release()
