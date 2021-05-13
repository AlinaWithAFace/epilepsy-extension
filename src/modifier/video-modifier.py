#!/usr/bin/env python3

"""
This can be used to add flashing patterns to real videos, which we can then add
to our dataset as examples of harmful videos.

To run you can say:

    python3 video-modifier.py -s <Source Directory> -o <Target Directory>

or

    ./video-modifier.py -s <Source Directory> -o <Target Directory>

You can also specify the probability (in the range 0-1) that a given frame will
be inverted with the flag:

    --prob=<Probability of Inversion>

"""

import random
import cv2
import numpy as np
import argparse
from pathlib import Path
import sys
import os


def modify_video(source_path, output_path, probability):
    """Modifies a video to contain flashing patterns by randomly inverting frames

    :source_path: location of the video that will be modified
    :output_path: the location that the modified video will be written to
    :probability: the probability that a given frame will be inverted

    """
    try:

        assert 0 <= probability <= 1

        vid = cv2.VideoCapture(str(source_path))
        fps = vid.get(cv2.CAP_PROP_FPS)
        width = int(vid.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(vid.get(cv2.CAP_PROP_FRAME_HEIGHT))

        fourcc = cv2.VideoWriter_fourcc(*"MP42")
        out = cv2.VideoWriter(str(output_path), fourcc,
                              float(fps), (width, height))

        while(vid.isOpened()):
            ret, frame = vid.read()
            if ret == True:
                if random.random() < probability:
                    out.write(255 - frame)
                else:
                    out.write(frame)
            else:
                break

        vid.release()
        out.release()

    except cv2.error as e:
        print(e, file=sys.stderr)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Program to make videos flickery")
    parser.add_argument("-s", dest="source", type=Path, required=True,
                        help="Directory containing videos to be modified")
    parser.add_argument("-o", dest="output", type=Path, required=True,
                        help="Name of directory to output modified videos to")
    parser.add_argument("--prob", dest="prob", type=float, required=False,
                        default=0.1,
                        help=("The probability that a given frame will be "
                              "inverted in the range 0-1"))

    args = parser.parse_args()

    assert os.path.isdir(args.source)

    if not os.path.exists(args.output):
        os.makedirs(args.output)

    for fname in os.listdir(args.source):
        modify_video(args.source / fname, (args.output / fname).with_suffix(".avi"),
                     probability=args.prob)
