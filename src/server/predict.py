# from https://github.com/kenshohara/3D-ResNets-PyTorch/issues/221

import torch
import av
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
    video = av.open(fname).streams.video[0]
    video_iter = (frame for packet in video.container.demux()
                  for frame in packet.decode())
    fps = video.guessed_rate
    frames = np.array(list(np.asarray(frame.to_image()) for frame in video_iter))
    nframes = len(frames)
    cur_frame = 0
    predictions = []
    while cur_frame < nframes:
        step = min(step_size, nframes - cur_frame)
        fs = frames[cur_frame:cur_frame+step]
        prob, is_dangerous = predict(fs)
        print(prob, is_dangerous)
        if is_dangerous:
            predictions.append(
                (int(cur_frame / fps), int((cur_frame + step) / fps)))
        cur_frame += step
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
