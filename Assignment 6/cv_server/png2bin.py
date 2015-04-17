# convert to binary
import base64
from bson.binary import Binary

with open("squirrel.png", "rb") as imageFile:
    str = base64.b64encode(imageFile.read())
    binary_image = Binary(str)

with open('squirrel_png.bin', 'wb') as f:
    f.write(binary_image)