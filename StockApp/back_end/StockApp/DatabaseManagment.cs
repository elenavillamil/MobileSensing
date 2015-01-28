using MongoDB.Bson;
using MongoDB.Driver;
using MongoDB.Driver.Builders;
using MongoDB.Driver.GridFS;
using MongoDB.Driver.Linq;
using System.Collections.Generic;
using System;

namespace StockApp
{

   public class DatabaseManagment
   {
      private static DatabaseManagment db_management = null;

      private static MongoServer server;
      private static MongoDatabase database;

      private DatabaseManagment ()
      {
         Object lock_object = new ObjectId();

         lock(lock_object)
         {
            if (server != null) return;

            const string connectionString = "mongodb://localhost";
            var client = new MongoClient(connectionString);
            server = client.GetServer();
            database = server.GetDatabase("StockApp");
         }
      }

      public static int SetupAccount(string username, string password)
      {
         if (db_management == null) {
            db_management = new DatabaseManagment();
         }

         MongoCollection<BsonDocument> users_collection = database.GetCollection<BsonDocument>("users");

         var query = Query.EQ("username", username);
         var cursor = users_collection.Find(query);

         if (cursor.Count () > 0) 
         {
            return 0;
         }

         BsonDocument account = new BsonDocument();

         account.Add("username", username);
         account.Add("password", password);
         account.Add("money", 10000); // 10,000

         MongoCollection<BsonDocument> history_collection = database.GetCollection<BsonDocument>("history");

         try
         {
            BsonDocument history_document = new BsonDocument();

            history_collection.Insert(history_document);
            
            BsonElement element;
            history_document.TryGetElement("_id", out element);

            ObjectId object_id = element.Value.AsObjectId;
            account.Add("history_id", object_id.ToString());

            users_collection.Insert(account);

            return 1;
         }
         catch
         {
            return 2;
         }
      }

      public static string SignIn(string username, string password)
      {
         if (db_management == null) {
            db_management = new DatabaseManagment ();
         }

         MongoCollection<BsonDocument> accounts = database.GetCollection<BsonDocument>("users");
         var query = Query.EQ ("username", username);
         var cursor = accounts.Find(query);

         foreach (BsonDocument c in cursor) 
         {
            try
            {
               BsonElement element;
               c.TryGetElement("password", out element);

               if (element.Value == password)
               {
                  c.TryGetElement("_id", out element);
                  ObjectId object_id = element.Value.AsObjectId;
              
                  return object_id.ToString();
               }
            }
            catch
            {

            }
         }

         return "";
      }

      public static bool DeleteAccount(string username)
      {
         MongoCollection<BsonDocument> accounts_collection = database.GetCollection<BsonDocument> ("users");
         var query = Query.EQ ("username", username);

         try
         {
            accounts_collection.Remove(query);
            return true;
         }
         catch
         {
            return false;
         }
      }
   }
}

