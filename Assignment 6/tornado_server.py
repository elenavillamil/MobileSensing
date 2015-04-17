################################################################################
#                                                                              #
#  04/13/2015                                                                  #
#  Mobile Sensing Assignment 6                                                 #
#  Tornado server to handle post request that acepts a .png picture            #
#                                                                              #
################################################################################
   
import base64
import json
import tornado.ioloop
import tornado.web

from bson.binary import Binary
from pymongo import MongoClient
from tornado.escape import recursive_unicode

####################
# Just needed for debuggin
####################
import Tkinter as tk
from PIL import Image, ImageTk
import numpy as np
import png
from matplotlib import pyplot as plt
import itertools
import pdb

# Code taken from Eric's example
class CustomJSONEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime.datetime):
            return obj.isoformat()
        elif isinstance(obj, datetime.date):
            return obj.isoformat()
        elif isinstance(obj, decimal.Decimal):
            return str(obj)
        else:
            return super(CustomJSONEncoder, self).default(obj)

# Code taken from Eric's example
def json_str(value):
    return str(json.dumps(recursive_unicode(value), cls=CustomJSONEncoder).replace("</", "<\\/"))


class MainHandler(tornado.web.RequestHandler):
   def get(self):
      print("Hola")

   # Function that async handles Post request 
   #@tornado.web.asynchronous 
   def post(self): 
      print ("Post Received")

      ##################
      # Retriving Post Request Data
      ##################
      
      data = json.loads(self.request.body)   

      arg1 = data['arg1']
      arg2 = data['arg2']

      # Converting the data received to bytes
      try:
         #pdb.set_trace()
         fo = open("test.png", "wb")
         png_image = bytes(base64.b64decode(str(arg1)))
         fo.write(png_image)
         fo.close()
         #png_image = png.Reader(bytes=png_image).asDirect()
         #writer = png.Writer(width=png_image[0], height=png_image[1], size=(png_image[0], png_image[1]), greyscale=False, alpha=False, bitdepth=8, palette=None, transparent=None, background=None, gamma=None, compression=None, interlace=False, bytes_per_sample=None, planes=None, colormap=None, maxval=None, chunk_limit=1048576)
         #writer.write(fo, png_image[2])
         name = str(arg2)
         #print(name)
         ##################
         # Displays image for testing pruporses
         ##################
         #image_2d = np.vstack(itertools.imap(np.uint16, png_image[2]))
         #image_3d = np.reshape(image_2d, (png_image[1], png_image[0], 3))
         #plt.imshow(image_3d, plt.cm.gray)
         #dplt.show()
   
      except ValueError, e:
         print ("Problem Parsing Post" + str(e))
         #raise HTTPJSONError(1, e)

      ####################
      # Insert Picture in DB
      ####################
      client = MongoClient() # localhost, default port
      collect = client.DroneRecognizer.ClassifierData

      #bson_image = BSON.encode({"image":png_image})
      #binary_image = Binary(png_image)
      collect.update({"name":name},
                     { "$push": {"images":"test.png"} }, 
                     upsert=True)      

    
      #####################
      # Sending response
      ####################
      self.set_header("Content-Type", "application/json")
      self.write(json_str({'arg1':"OK"}))
      
      # Finish the task
      self.finish()

application = tornado.web.Application([(r"/", MainHandler),])

if __name__ == "__main__":
   application.listen(8888)
   tornado.ioloop.IOLoop.instance().start()
