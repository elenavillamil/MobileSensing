from pymongo import MongoClient

client = MongoClient() # localhost, default port
db = client.DroneRecognizer.ClassifierData

# find all documents
results = db.find()

#file to write to
file = open('database_contents', 'w')

#iterate through items
for item in results:


     