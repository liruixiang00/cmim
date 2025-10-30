CMIM Image Matching Tool performs robust feature-based matching between two images using a CMIM approach with Steerable Hermite Filters. It supports a configurable number of feature points and outputs matched keypoints to a .pts file.

The program detects keypoints using the FAST detector on the principal moment map, computes descriptors using orientation index maps derived from first-order steerable Hermite filters, matches features using brute-force L2 descriptor matching, and filters matches using FSC (Feature Similarity Consistency) to remove outliers. Users can control the number of features via command line.

Requirements:
- C++17 or later
- OpenCV 4.x (with core, imgproc, features2d modules)
- Standard C++ libraries
- Before running, extract opencv_world455.zip to generate opencv_world455.dll

Usage:
./MatchCMIM <image1> <image2> <output_pts> [num_features]

Arguments:
image1       - Path to the first image
image2       - Path to the second image
output_pts   - Path to save matched points (.pts format)
num_features - Optional: number of features to detect (default: 5000)

Examples:
- Default 5000 features:
  ./MatchCMIM image1.tif image2.tif matches.pts

- Custom number of features (e.g., 1000):
  ./MatchCMIM image1.tif image2.tif matches.pts 1000

Output:
The .pts file contains matched keypoints in the format:
x1 y1 x2 y2
