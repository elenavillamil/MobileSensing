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
            //Console.WriteLine ("Connection to Mongo DB?");
            const string connectionString = "mongodb://localhost";
            var client = new MongoClient(connectionString);
            server = client.GetServer();
            database = server.GetDatabase("StockApp");
         }
      }

      public static void SetupAccount(string username, string password)
      {
         if (db_management == null) {
            db_management = new DatabaseManagment ();
         }

         BsonDocument account = new BsonDocument ();

         account.Add ("username", username);
         account.Add ("password", password);

         MongoCollection<BsonDocument> accounts = database.GetCollection<BsonDocument>("users");

         try
         {
            accounts.Insert (account);
         }
         catch 
         {

         }


      }

      public static bool SignIn(string username, string password)
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
                  return true;
               }

               else
               {
                  return false;
               }
            }

            catch
            {
            }

         }

         return false;

      }

   }
}

