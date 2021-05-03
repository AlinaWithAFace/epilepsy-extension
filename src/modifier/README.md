# Video modifier

> **Note:** This is the same documentation contained the
> `src/modifier/video-modifier.py` file


This can be used to add flashing patterns to real videos, which we can then add
to our dataset as examples of harmful videos.

To run you can say:

``` sh
python3 video-modifier.py -s <Source Directory> -o <Target Directory>
```

Or:

``` sh
./video-modifier.py -s <Source Directory> -o <Target Directory>
```

You can also specify the probability (in the range 0-1) that a given frame will
be inverted with the flag:

``` sh
--prob=<Probability of Inversion>
```

