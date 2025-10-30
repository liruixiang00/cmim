# -*- coding: utf-8 -*-
"""
Batch matching with LightGlue and SuperPoint
Saves ENVI GCP files with matching time
"""

import time
import torch
from pathlib import Path
from lightglue import LightGlue, SuperPoint
from lightglue.utils import load_image, rbd
from lightglue import viz2d
import matplotlib.pyplot as plt

images_dir = Path(r"D:\Code\MatchPro\CMIMv1.0\Data\O-S")
save_dir = images_dir / "LG"
save_dir.mkdir(exist_ok=True)

device = torch.device(
    "cuda" if torch.cuda.is_available() else
    "mps" if torch.backends.mps.is_available() else
    "cpu"
)
print(f"Using device: {device}")

extractor = SuperPoint(max_num_keypoints=5000).eval().to(device)
matcher = LightGlue(features="superpoint").eval().to(device)

def match_viz_save(image_path0, image_path1, keypoint_size=6, save_dir=save_dir):


    image0 = load_image(image_path0)
    image1 = load_image(image_path1)
    
    start_time = time.time() 
    feats0 = extractor.extract(image0.to(device))
    feats1 = extractor.extract(image1.to(device))

    matches01 = matcher({"image0": feats0, "image1": feats1})

    feats0, feats1, matches01 = [rbd(x) for x in [feats0, feats1, matches01]]
    kpts0, kpts1, matches = feats0["keypoints"], feats1["keypoints"], matches01["matches"]
    m_kpts0, m_kpts1 = kpts0[matches[..., 0]], kpts1[matches[..., 1]]

    elapsed_time = time.time() - start_time
    print(f"Matched keypoints: {matches.shape[0]} between {image_path0.name} and {image_path1.name}")
    print(f"Matching time: {elapsed_time:.3f} seconds")

    
    existing_files = list(save_dir.glob("LG-*.pts"))
    if not existing_files:
        next_index = 1
    else:
        indices = [int(f.stem.split("-")[1]) for f in existing_files if f.stem.split("-")[1].isdigit()]
        next_index = max(indices) + 1 if indices else 1
    
    save_path = save_dir / f"LG-{next_index}.pts"
    
    with open(save_path, "w") as f:
        f.write("; ENVI Image to Image GCP File\n")
        f.write(f"; base file: {image_path0.name}\n")
        f.write(f"; warp file: {image_path1.name}\n")
        f.write(f"; matching time (s): {elapsed_time:.3f}\n")
        f.write("; Base Image (x,y), Warp Image (x,y)\n")
        for (x0, y0), (x1, y1) in zip(m_kpts0.cpu().numpy(), m_kpts1.cpu().numpy()):
            f.write(f"{x0:.2f}    {y0:.2f}     {x1:.2f}    {y1:.2f}\n")
    print(f"Saved matches to {save_path}")



max_index = 10
for i in range(1, max_index + 1):
    img0 = images_dir / f"{i}_1.tif"
    img1 = images_dir / f"{i}_2.tif"
    if img0.exists() and img1.exists():
        match_viz_save(img0, img1)
    else:
        print(f"Warning: {img0} or {img1} not found, skipping.")
