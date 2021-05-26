# epilepsy-extension

Welcome to Episense! This is a google chrome extension and deep learning model aimed at screening videos for photosensitive epilepsy triggers.
This repository is all of the code. The related photosensitivity dataset, models, reults, and options used can be downloaded [here](https://drive.google.com/drive/u/1/folders/1OBRKlNH0R3NRdQWEjyly-PiuNnIEBVwp).

The model portion of the project is based on [3D-ResNets-PyTorch](https://github.com/kenshohara/3D-ResNets-PyTorch) with some modifications.

The project requires anaconda, python 3, pytorch, openCV, ffmpeg, pandas and numpy.

To train the model, use these optinos:
```
--root_path
Epilepsy-Project/data/photosensitivity-data
--video_path
jpg
--result_path
results
--dataset
photosensitivity
--annotation_path
photosensitivity_0.json
--n_classes
2
--ft_begin_module
fc
--model
resnet
--model_depth
50
--pretrain_path
models/r3d50_KMS_200ep.pth
--n_pretrain_classes
1139
--batch_size
8
--n_threads
1
--checkpoint
5
```

To generate annotations, use these options:
```
Epilepsy-Project//data//photosensitivity-data//annotations
Epilepsy-Project//data//photosensitivity-data//jpg
Epilepsy-Project//data//photosensitivity-data
```