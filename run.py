
from os import system

if system("python3 setup.py build_ext --inplace") is 0:
    import Outline_Generator
    Outline_Generator.generate(b"input/", b"output/")
