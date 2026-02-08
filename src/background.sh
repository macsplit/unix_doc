#!/bin/sh
mogrify -background "white" -alpha remove -alpha off -level 0%,90% -level 0%,120% *.png
