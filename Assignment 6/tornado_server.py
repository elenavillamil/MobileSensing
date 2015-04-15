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
   # Function that async handles Post request 
   @tornado.web.asynchronous 
   def post(self): 
      arg1 = self.get_argument( "arg1");

      # Converting the data received to bytes
      try:
         response = bytes(arg1);

      except ValueError:
         e = "%s could not be read as bytes" % value
         raise HTTPJSONError(1, e)

      # Displays image for testing pruporses
      root = tk.Tk()
      root.title("Testing Post Imaged Received")
      
      # imageFile = "IMG_0036.PNG"

      image1 = ImageTk.PhotoImage(Image.open(response))

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
    
      # Sending response
      self.set_header("Content-Type", "application/json")
      self.write(json_str({'arg1':response}))
      
      # Finish the task
      self.finish()

application = tornado.web.Application([(r"/", MainHandler),])

if __name__ == "__main__":
   application.listen(8888)
   tornado.ioloop.IOLoop.instance().start()
