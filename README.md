
````markdown
# CMIM Image Matching Tool

This program performs **robust feature-based matching between two images** using a CMIM approach with **Steerable Hermite Filters**. It supports **configurable number of feature points** and outputs matched keypoints to a `.pts` file.

---

## Features

* Detects keypoints using **FAST detector** on principal moment map.
* Computes descriptors using **NISM maps** from **first-order steerable Hermite filters**.
* Matches features using **brute-force L2 descriptor matching**.
* Filters matches using **FSC (Feature Similarity Consistency)** to remove outliers.
* Allows user to **control number of features** via command line.

---

## Requirements

* **C++17 or later**
* **OpenCV 4.x** (with `core`, `imgproc`, `features2d` modules)
* Standard C++ libraries

---

## Build

1. Clone the repository or copy the source code.
2. Create a build directory and compile with CMake or directly with g++:

```bash
g++ -std=c++17 main.cpp RunningCMIM.cpp -o MatchCMIM `pkg-config --cflags --libs opencv4`
````

---

## Usage

```
./MatchCMIM <image1> <image2> <output_pts> [num_features]
```

### Arguments

| Argument       | Description                                            |
| -------------- | ------------------------------------------------------ |
| `image1`       | Path to the first image                                |
| `image2`       | Path to the second image                               |
| `output_pts`   | Path to save matched points (.pts format)              |
| `num_features` | Optional: number of features to detect (default: 5000) |

### Examples

```bash
# Default 5000 features
./MatchCMIM image1.tif image2.tif matches.pts

# Custom number of features (e.g., 1000)
./MatchCMIM image1.tif image2.tif matches.pts 1000
```

---

## Output

* `.pts` file containing matched keypoints in the format:

```
x1 y1 x2 y2
```

---
