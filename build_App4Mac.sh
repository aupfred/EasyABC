/usr/bin/python3 ./setup.py py2app

#FAU: Py2app does not seems to handle properly the library needed for Pygame so patch the tree
#cp -r /Library/Python/3.8/site-packages/pygame/.dylibs dist/EasyABC.app/Contents/Resources/lib/python3.8/lib-dynload/pygame
#mkdir dist/EasyABC.app/Contents/Resources/lib/python3.8/lib-dynload/pygame/.dylibs
ln -s ../../../../../Frameworks dist/EasyABC.app/Contents/Resources/lib/python3.8/lib-dynload/pygame/.dylibs
#libSDL2-2.0.dylib    libSDL2_ttf.dylib    libsdl2_mixer.dylib
#libSDL2_image.dylib    libportmidi.dylib
