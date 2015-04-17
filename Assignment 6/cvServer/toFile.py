from pymongo import MongoClient

client = MongoClient() # localhost, default port
collect = client.DroneRecognizer.ClassifierData

# find all documents
results = db.find()

#file to write to
file = open('database_contents', 'w')

#number of items
for item in results:
     