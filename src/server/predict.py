# from https://github.com/kenshohara/3D-ResNets-PyTorch/issues/221

import torch
import cv2
import numpy as np
import torch.nn.functional as F
import resnet
from PIL import Image
from spatial_transforms import (Compose, Normalize, Resize, CenterCrop,
                                CornerCrop, MultiScaleCornerCrop,
                                RandomResizedCrop, RandomHorizontalFlip,
                                ToTensor, ScaleValue, ColorJitter,
                                PickFirstChannels)
from collections import namedtuple


model = resnet.generate_model(model_depth=50,
                              n_classes=2,
                              n_input_channels=3,
                              shortcut_type="B",
                              conv1_t_size=7,
                              conv1_t_stride=1,
                              no_max_pool=False,
                              widen_factor=1.0)


state_dict = torch.load(
    "r3d50_KMS_200ep-photosensitivity-200.pth", map_location='cpu')['state_dict']
model.load_state_dict(state_dict)


def get_frames(v_cap, n_frames=1):
    frames = []
    v_len = n_frames
    frame_list = np.linspace(0, v_len - 1, n_frames + 1, dtype=np.int16)
    for fn in range(v_len):
        success, frame = v_cap.read()
        if success is False:
            continue
        if fn in frame_list:
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frames.append(frame)
    return frames, v_len


def get_normalize_method(mean, std, no_mean_norm, no_std_norm):
    if no_mean_norm:
        if no_std_norm:
            return Normalize([0, 0, 0], [1, 1, 1])
        else:
            return Normalize([0, 0, 0], std)
    else:
        if no_std_norm:
            return Normalize(mean, [1, 1, 1])
        else:
            return Normalize(mean, std)


def get_spatial_transform():
    normalize = get_normalize_method([0.4345, 0.4051, 0.3775], [
                                     0.2768, 0.2713, 0.2737], False, False)
    spatial_transform = [Resize(112)]
    spatial_transform.append(CenterCrop(112))
    spatial_transform.append(ToTensor())
    spatial_transform.extend([ScaleValue(1), normalize])
    spatial_transform = Compose(spatial_transform)
    return spatial_transform


def preprocessing(clip, spatial_transform):
    # Applying spatial transformations
    if spatial_transform is not None:
        spatial_transform.randomize_parameters()
        # Before applying spatial transformation you need to convert your frame into PIL Image format (its not the best way, but works)
        clip = [spatial_transform(Image.fromarray(
            np.uint8(img)).convert('RGB')) for img in clip]
    # Rearange shapes to fit model input
    clip = torch.stack(clip, 0).permute(1, 0, 2, 3)
    clip = torch.stack((clip,), 0)
    return clip


def get_all_predictions(fname, step_size=128):
    v_cap = cv2.VideoCapture(fname)
    fps = v_cap.get(cv2.CAP_PROP_FPS)
    nframes = v_cap.get(cv2.CAP_PROP_FRAME_COUNT)
    cur_frame = 0
    predictions = []
    while cur_frame < nframes:
        cur_frame += step_size
        frames = get_frames(v_cap, step_size)[0]
        if predict(frames):
            predictions.append(
                (int((cur_frame - step_size) / fps), int(cur_frame / fps)))
    v_cap.release()
    return predictions


def predict(clip, model=model, spatial_transform=get_spatial_transform(), classes=[True, False]):
    # Set mode eval mode
    model.eval()
    # do some preprocessing steps
    clip = preprocessing(clip, spatial_transform)
    # don't calculate grads
    with torch.no_grad():
        # apply model to input
        outputs = model(clip)
        # apply softmax and move from gpu to cpu
        outputs = F.softmax(outputs, dim=1).cpu()
        # get best class
        score, class_prediction = torch.max(outputs, 1)
    # As model outputs a index class, if you have the real class list you can get the output class name
    # something like this: classes = ['jump', 'talk', 'walk', ...]
    if classes != None:
        return score[0], classes[class_prediction[0]]
    return score[0], class_prediction[0]
