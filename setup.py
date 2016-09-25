#!/usr/bin/env python

from setuptools import setup
import os

def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

setup(
    name = "larawed",
    version = "1.0.0",
    author = "Josef Kuchař",
    author_email = "email@josefkuchar.cz",
    description = "Larawed is tool that modify existing/new laravel project to run on shared hostings",
    license = "GPLv3",
    keywords = "patcher tool laravel larawed php python",
    url = "https://github.com/JosefKuchar/Larawed",
    long_description = read("readme.md"),
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Topic :: Utilities",
        "License :: GNUv3 License"
    ],
    install_requires = [
        "colorama"
    ]
)
