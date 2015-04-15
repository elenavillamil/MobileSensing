################################################################################
#                                                                              #
#  04/13/2015                                                                  #
#  Mobile Sensing Assignment 6                                                 #
#  Tornado server to handle post request that acepts a .png picture            #
#                                                                              #
################################################################################
   

import tornado.ioloop
import tornado.web
from tornado.escape import recursive_unicode
import Tkinter as tk

import json
from PIL import Image, ImageTk

#from basehandler import BaseHandler

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
   @tornado.web.asynchronous 
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
         png_image = bytes(arg1);
         name = str(arg2);
      except ValueError:
         e = "%s Problem parsing POST data" % value
         raise HTTPJSONError(1, e)

      
      print (arg2)
      ##################
      # Displays image for testing pruporses
      ##################
      root = tk.Tk()
      root.title("Testing Post Imaged Received")
      
      #imageFile = "IMG_0036.PNG"
      #image1 = ImageTk.PhotoImage(Image.open(imageFile))
      image1 = ImageTk.PhotoImage(Image.open(png_image))

      # get the image size
      w = image1.width()
      h = image1.height()
   
      # position coordinates of root 'upper left corner'
      x = 0
      y = 0

      # make the root window the size of the image
      root.geometry("%dx%d+%d+%d" % (w, h, x, y))

      # root has no image argument, so use a label as a panel
      panel1 = tk.Label(root, image=image1)
      panel1.pack(side='top', fill='both', expand='yes')

      # save the panel's image from 'garbage collection'
      panel1.image = image1

      # start the event loop
      root.mainloop()


      ####################
      # Insert Picture in DB
      ####################
      #client = MongoClient() # localhost, default port
      #collect = client.DroneRecognizer.ClassifierData

      #collect.update({"name":name},
      #               { "$push": {"images":png_image} }, 
      #               upsert=True)      

    
      ####################
      # Sending response
      ####################
      self.set_header("Content-Type", "application/json")
      self.write(json_str({'arg1':response}))
      
      # Finish the task
      self.finish()

application = tornado.web.Application([(r"/", MainHandler),])

if __name__ == "__main__":
   application.listen(8888)
   tornado.ioloop.IOLoop.instance().start()
