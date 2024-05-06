import os

import cv2
import numpy as np

def splitPano(pano: np.ndarray, *, axis=1, n=3):
    print(pano.ndim)
    assert axis < pano.ndim
    d_split = pano.shape[axis] // n
    result = []

    for i in range(n):
        dims = [slice(i*d_split, (i+1)*d_split) if j == axis else slice(None) for j in range(pano.ndim)]
        result.append(pano[tuple(dims)])

    return result

pano = cv2.imread(os.path.join(os.path.dirname(__file__), "assets", "sb_pano.jpg"))
split = splitPano(pano, n=3, axis=1)

print([s.shape for s in split])

stitcher = cv2.Stitcher.create(cv2.STITCHER_PANORAMA)
stitcher.setPanoConfidenceThresh(0)
ret, img = stitcher.stitch(split)
print(ret)

img = cv2.resize(img, (1800, 400))

cv2.imshow("img", img)
cv2.waitKey()
cv2.destroyAllWindows()
