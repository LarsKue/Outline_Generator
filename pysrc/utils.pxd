
IF OUTLINE_GENERATOR_UTILS_PXD == 0:
    DEF OUTLINE_GENERATOR_UTILS_PXD = 1

    import pathlib
    import os
    from shutil import rmtree

    cimport numpy as np
    import numpy as np


    cdef const char* filename_no_ext(const char* filename):
        return os.path.splitext(os.path.basename(filename))[0]

    cdef int numframes(const char* filename):
        cdef const char* fne = filename_no_ext(filename)
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