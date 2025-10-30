# CMIM Image Matching Tool

This program performs **robust feature-based matching between two images** using a CMIM approach with Steerable Hermite Filters. It supports **configurable number of feature points** and outputs matched keypoints to a `.pts` file.

---

## Features

* Detects keypoints using **FAST detector** on principal moment map.
* Computes descriptors using **OIM** from **first-order steerable Hermite filters**.
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
