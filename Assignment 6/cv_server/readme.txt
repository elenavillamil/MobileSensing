
squirrel.png is the original image I used as a test image.

I converted it to the binary file squirrel_png.bin using the png2bin.py I made so that I could have a test image.  

------

openCVprocesses.cpp
server.hpp
socket.hpp

These are the main files of the cvServer activities.

------

C++ image extraction progress...

I downloaded lodepng for the decoding of the png file.  There are four files in the directory...

lodepng.cpp
lodepng.h
lodepng_util.cpp
lodepng_util.h

I downloaded SDL 1.2 from www.libsdl.org.  I could not find a more recent one for linux, but this is the lib that is causing me trouble.  This is the reason that much of the code in openCVprocesss.cpp is commented out, but in reality, I do not need to display the pic, I just wanted to be able to verify it that way.  
