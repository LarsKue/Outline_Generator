
IF OUTLINE_GENERATOR_UTILS_PXD == 0:
    DEF OUTLINE_GENERATOR_UTILS_PXD = 1

    import os

    cimport numpy as np
    import numpy as np


    cdef str filename_no_ext(str filename):
        return str(os.path.splitext(filename)[0])

    cdef int numframes(str filename):
        cdef str fne = filename_no_ext(filename)
        return int(fne[fne.rfind(".") + 1:])

    cdef np.ndarray pad_image(np.ndarray image, int weight):
        return np.pad(image, [[weight, weight], [weight, weight], [0, 0]])

    def split_frames(np.ndarray image, int frames):
        cdef int height = image.shape[0]
        if height % frames != 0:
            raise ValueError("Invalid Frames!")
        frameheight = height // frames

        cdef int i
        for i in range(frames):
            yield image[i * frameheight: (i + 1) * frameheight]

    cdef np.ndarray pad_frames(np.ndarray image, int frames, int weight):
        cdef np.ndarray result = None
        cdef np.ndarray frame

        # split the image into its frames
        for frame in split_frames(image, frames):
            # pad each frame with transparent pixels in all directions
            frame = pad_image(frame, weight)

            # put the image back together
            if result is None:
                result = frame
            else:
                result = np.concatenate([result, frame], axis=0)

        return result

    cdef int sq_dist(int x1, int y1, int x2, int y2):
        return (x1 - x2) ** 2 + (y1 - y2) ** 2

    cdef double get_alpha_factor(int distance, int weight):
        # we use quadratic interpolation
        # the maximum distance is fully diagonal
        cdef int max_dist = 2 * weight ** 2

        return 1 - distance / max_dist


