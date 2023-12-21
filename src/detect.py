#!env/bin/python3


# detect.py
from opensoundscape.ml.cnn import load_model
from opensoundscape import Audio
from opensoundscape.metrics import predict_multi_target_labels
import opensoundscape
import torch
from pathlib import Path
import numpy as np
import pandas as pd
from glob import glob
import subprocess
import sys
import csv

arg1 = sys.argv[1]
print(arg1)

model = torch.hub.load('kitzeslab/bioacoustics-model-zoo', 'BirdNET')
audio_files = glob(arg1)

scores = model.predict(
    audio_files,
    activation_layer='softmax',
)

classified = predict_multi_target_labels(scores, threshold = 0.25)
classified = classified.loc[:, (classified != 0).any(axis=0)]

classified.to_csv(sys.argv[2] + 'detections.csv')
