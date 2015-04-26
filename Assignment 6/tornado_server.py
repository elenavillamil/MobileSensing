#!/usr/bin/env python

################################################################################
#                                                                              #
#  04/13/2015                                                                  #
#  Mobile Sensing Assignment 6                                                 #
#  Tornado server to handle post request that acepts a .png picture            #
#                                                                              #
################################################################################
   
import base64
import json
import socket
import tornado.ioloop
import tornado.web

from bson.binary import Binary
from pymongo import MongoClient
from tornado.escape import recursive_unicode

address = "127.0.0.1"
port = 8000
base_path = "/home/ubuntu/msd/"
base_image_path = "/home/ubuntu/msd/pictures/"
#base_path = "/Users/elena/"

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

      print ("Inside POST")

      ###################
      # Getting post data
      ###################
      data = json.loads(self.request.body)   

      file_name = ""
      try:
         image = str(data['image'])
         name = str(data['name'])
         count = int(data['count'])
         order = str(data['last'])
         
         file_name = base_image_path + name + str(count) + ".png"
         fo = open(file_name, "wb")
         png_image = bytes(base64.b64decode(image))
         fo.write(png_image)
         fo.close()
   
      except ValueError, e:
         print ("Problem Parsing Post " + str(e))
        
      ####################
      # Insert picture path in DB
      ####################
      print ("Inserting into Mongo")
      client = MongoClient() # localhost, default port
      collect = client.DroneRecognizer.ClassifierData
      collect.update({"name":name},
                     { "$push": {"images":file_name} }, 
                     upsert=True)      
    
      #####################
      # Sending response
      ####################
      self.set_header("Content-Type", "application/json")
      self.write(json_str({'arg1':"OK"}))
      
      ####################
      # Openning socket to let open cv the images are ready
      ####################
      if order == "true":
         print ("Making txt file")
         db_to_file()
         collect.remove({})

         try:
            sock = socket.socket()
            sock.connect((address, port))
            sock.send(base_path + 'database_contents.txt')
            sock.close()
            
         except socket.error, (value,message):
            print ("Problem Opening the socket or seding the data.")
            print (" ERROR " + str(message)) 

      ###################
      # Finish the task asynch task
      ###################
      self.finish()

application = tornado.web.Application([(r"/", MainHandler),])

def db_to_file():
   client = MongoClient() # localhost, default port
   db = client.DroneRecognizer.ClassifierData

   # find all documents
   results = db.find()

   #file to write to
   fo = open(base_path + 'database_contents.txt', 'w')

   #iterate through items
   for item in results:
      for path in item['images']:
         fo.write(path + "\n")

   fo.close()   

def remove_old_pictures():

   for current_file in os.listdir(base_image_path):

      file_path = os.path.join(base_image_path, current_file)

      try:

         if (os.path.isfile(file_path)):
            os.unlink(file_path)

      except Exception, e:
         print e

if __name__ == "__main__":
   application.listen(8888)
   tornado.ioloop.IOLoop.instance().start()
