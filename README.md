明白，你希望把整个 README 内容放到一个 **单独的代码块**，方便直接复制到文件或编辑器里。下面是完整的 README 内容，已经放在一个 Markdown 代码块里：

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

## Workflow

The CMIM matching pipeline consists of the following steps:

```
Input Images
   │
   ▼
Convert to Grayscale (if needed)
   │
   ▼
Compute G1 Steerable Hermite Filter Responses
   │
   ▼
Compute NISM (Normalized Index of Steerable Modulations) Maps
   │
   ▼
Detect FAST Keypoints on NISM / Principal Moment Map
   │
   ▼
Compute Descriptors for Keypoints
   │
   ▼
Brute-force Descriptor Matching (L2 distance)
   │
   ▼
FSC Filtering (remove inconsistent matches)
   │
   ▼
Output Matched Keypoints (.pts)
```

### Modules

| Module                          | Description                                                                       |
| ------------------------------- | --------------------------------------------------------------------------------- |
| `G1SteerableFiltersConvolution` | Computes first-order Hermite filter responses at multiple scales and orientations |
| `NISM`                          | Generates robust feature modulation maps from filter responses                    |
| `DetecteFASTFeatures`           | Detects salient keypoints on NISM maps                                            |
| `GetDescriptor`                 | Extracts patch-based descriptors from NISM maps for each keypoint                 |
| `BFMatcher + FSC_similarity`    | Matches descriptors and filters out outliers                                      |

---

## Output

* `.pts` file containing matched keypoints in the format:

```
x1 y1 x2 y2
```

Each line represents a matched keypoint pair: coordinates in the first image followed by coordinates in the second image.

---

## Notes

* If either input image is grayscale, it is automatically converted to BGR internally.
* The program prints:

  * Number of initial matches
  * Number of correct matches after FSC filtering
  * Elapsed time in seconds
* Default **patch size** for descriptors is 84.
* Default **number of features** is 5000 unless overridden.

---

## License

MIT License — free to use for academic and commercial purposes.

```

你可以直接 **复制这个整个块** 到 `README.md` 文件里即可使用。  

如果你需要，我可以再帮你 **加一张可视化流程图** 的 Markdown 链接版本，让 README 更直观。  

你希望我加吗？
```
