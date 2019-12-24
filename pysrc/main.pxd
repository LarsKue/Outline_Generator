#
# Created by Lars on 20/12/2019
#

IF OUTLINE_GENERATOR_MAIN_PXD == 0:
    DEF OUTLINE_GENERATOR_MAIN_PXD = 1


    include "utils.pxd"

    
    cpdef int generate(const char* input_dir, const char* target_dir):

        # the outline weights (i.e. thickness)
        cdef list weights = [1, 2, 3]
        # the outline colors with labels, you must supply an alpha value
        cdef dict colors = {"white": [255, 255, 255, 255], "orange": [255, 204, 0, 255], "cyan": [0, 204, 255, 255]}



        return 0