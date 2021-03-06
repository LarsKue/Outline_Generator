#
# Created by Lars on 20/12/2019
#

IF OUTLINE_GENERATOR_MAIN_PXD == 0:
    DEF OUTLINE_GENERATOR_MAIN_PXD = 1


    from PIL import Image
    import pathlib
    from reprint import output

    from libcpp cimport bool

    include "utils.pxd"


    cdef int reprint_key(x):
        return 1


    def get_outline_pixels(np.ndarray image, int weight, bool fill):
        cdef int i
        cdef int j

        cdef (int, int, int, int) bounds
        cdef list distances
        cdef int k1
        cdef int k2


        for i in range(len(image)):
            for j in range(len(image[0])):
                if image[i][j][3]:
                    if fill:
                        yield (i, j, 0)
                    continue
                bounds = (
                    max(0, i - weight), min(len(image), i + weight + 1), max(0, j - weight),
                    min(len(image[0]), j + weight + 1))
                distances = []
                for k1 in range(bounds[0], bounds[1]):
                    for k2 in range(bounds[2], bounds[3]):
                        if image[k1][k2][3]:
                            distances.append(sq_dist(i, j, k1, k2))
                if distances:
                    yield (i, j, min(distances))


    def get_outlines(np.ndarray image, int weight, tuple colors, bool fill):
        cdef np.ndarray result = np.zeros_like(image)
        cdef np.ndarray faderesult = np.zeros_like(image)
        cdef tuple pixels = tuple(get_outline_pixels(image, weight, fill))
        cdef list color
        cdef int i
        cdef int j
        cdef int sqd


        for color in colors:
            for (i, j, sqd) in pixels:
                result[i][j] = color
                faderesult[i][j] = np.array(color[0:3] + [round(color[3] * get_alpha_factor(sqd, weight))])
            yield result, faderesult


    
    cpdef int generate() except? -1:

        # no trailing slash
        cdef str input_dir = "input"
        cdef str output_dir = "output"

        # the outline weights (i.e. thickness)
        cdef list weights = [1, 2, 3]
        # the outline colors with labels, you must supply an alpha value
        cdef dict colors = {"white": [255, 255, 255, 255], "orange": [255, 204, 0, 255], "cyan": [0, 204, 255, 255]}

        cdef bool fill = False

        cdef np.ndarray orig_image
        cdef int weight
        cdef np.ndarray outline_image
        cdef np.ndarray fade_image
        cdef str colorname
        cdef str fne

        cdef tuple files = tuple(pathlib.Path(input_dir).rglob("*.png"))

        cdef int numfiles = len(files)
        cdef int i


        with output(output_type="dict", sort_key=reprint_key) as output_lines:



            for i, filepath in enumerate(files):
                output_lines["Processing File"] = f"{i + 1} out of {numfiles}."
                output_lines["Progress"] = "[" + "#" * round(50 * i / numfiles) + " " * round(50 * (1 - i / numfiles)) + "]"
                output_lines["Current File"] = str(filepath)

                # we want to mirror the directory structure of input
                target_path = pathlib.Path(str(filepath.parent).replace(input_dir, output_dir))
                if not target_path.exists():
                    target_path.mkdir(parents=True, exist_ok=True)

                orig_image = np.asarray(Image.open(filepath).convert("RGBA"))

                if "animations" in str(filepath):
                    frames = numframes(str(filepath))
                else:
                    frames = 1

                for weight in weights:

                    image = pad_frames(orig_image, frames, weight)

                    for (outline_image, fade_image), colorname in zip(get_outlines(image, weight, tuple(colors.values()), fill), colors.keys()):
                        Image.fromarray(outline_image).save(str(target_path) + f"/{filepath.stem}.{weight}.{colorname}.png")
                        Image.fromarray(fade_image).save(str(target_path) + f"/{filepath.stem}.{weight}.{colorname}.fade.png")


            output_lines["Progress"] = "[" + "#" * 50 + "]"

        print("Done.")



        return 0