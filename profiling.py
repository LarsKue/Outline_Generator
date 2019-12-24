import pstats
import cProfile

import Outline_Generator

cProfile.runctx("Outline_Generator.generate()", globals(), locals(), "Profile.prof")

s = pstats.Stats("Profile.prof")
s.strip_dirs().sort_stats("cumtime").print_stats()
