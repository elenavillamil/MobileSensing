using MongoDB.Bson;
using MongoDB.Bson.Serialization;
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

      private object db_lock = new Object();
      private static object account_lock = new Object();

      private DatabaseManagment ()
      {
         lock(db_lock)
         {
            if (server != null) return;

            const string connectionString = "mongodb://localhost";
            var client = new MongoClient(connectionString);
            server = client.GetServer();
            database = server.GetDatabase("StockApp");
         }
      }

      public static string SetupAccount(string username, string password)
      {
         if (db_management == null) {
            db_management = new DatabaseManagment();
         }

         lock(account_lock)
         {
            MongoCollection<BsonDocument> users_collection = database.GetCollection<BsonDocument>("users");

            var query = Query.EQ("username", username);
            var cursor = users_collection.Find(query);

            if (cursor.Count () > 0) 
            {
               return "Username already exists";
            }

            BsonDocument account = new BsonDocument();

            account.Add("username", username);
            account.Add("password", password);
            account.Add("money", 10000.0); // 10,000

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

               return object_id.ToString();
            }
            catch
            {
               return "DB problem";
            }
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
         MongoCollection<BsonDocument> history_collection = database.GetCollection<BsonDocument> ("history");

         var query_username = Query.EQ ("username", username);

         lock (account_lock)
         {

            try
            {
               BsonDocument account_document;
               account_document = accounts_collection.FindOne(query_username).AsBsonDocument;

               BsonElement account_id;
               account_document.TryGetElement("history_id", out account_id);

               string string_id = account_id.Value.AsString;
               ObjectId object_id = new ObjectId(string_id);
               var query_remove_history_by_id = Query.EQ("_id", object_id);

               accounts_collection.Remove(query_username);
               history_collection.Remove(query_remove_history_by_id);

               return true;
            }
            catch
            {
               return false;
            }
         }
      }

      public static double BuyOrder(string username, string name, double amount, double value)
      {
         if (db_management == null)
         {
            db_management = new DatabaseManagment();
         }

         MongoCollection<BsonDocument> accounts = database.GetCollection<BsonDocument>("users");
         MongoCollection<BsonDocument> history_collection = database.GetCollection<BsonDocument>("history");
         var query = Query.EQ("username", username);
         var cursor = accounts.Find(query);

         foreach (BsonDocument c in cursor)
         {
            try
            {
               double current_money = c.GetValue("money").AsDouble;

               BsonElement account_id;
               c.TryGetElement("history_id", out account_id);

               string string_id = account_id.Value.AsString;
               ObjectId object_id = new ObjectId(string_id);
               var query_history_collection = Query.EQ("_id", object_id);

               current_money = current_money - value;

               var update_document = new UpdateDocument {
                  { "$set", new BsonDocument("money", current_money) }
               };

               accounts.Update(query, update_document);

               Dictionary<string, object> elements = new Dictionary<string,object>();
               
               elements.Add("type", "buy");
               elements.Add("sell_amount", amount);
               elements.Add("sell_value", value);
               elements.Add("current_money", current_money);

               BsonDocument to_be_inserted = new BsonDocument(elements);

               var history_update_document = new UpdateDocument {
                  { "$push", new BsonDocument("history_list", to_be_inserted) }
               };

               history_collection.Update(query_history_collection, history_update_document);

               return current_money;

            }
            catch (Exception e)
            {
               Console.WriteLine(e.ToString());
            }
         }

         return -1;
      }

      public static double SellOrder(string username, string name, double amount, double value)
      {
         if (db_management == null)
         {
            db_management = new DatabaseManagment();
         }

         MongoCollection<BsonDocument> accounts = database.GetCollection<BsonDocument>("users");
         MongoCollection<BsonDocument> history_collection = database.GetCollection<BsonDocument>("history");
         var query = Query.EQ("username", username);
         var cursor = accounts.Find(query);

         foreach (BsonDocument c in cursor)
         {
            try
            {
               double current_money = c.GetValue("money").AsDouble;

               BsonElement account_id;
               c.TryGetElement("history_id", out account_id);

               string string_id = account_id.Value.AsString;
               ObjectId object_id = new ObjectId(string_id);
               var query_history_collection = Query.EQ("_id", object_id);

               current_money = current_money + value;

               var update_document = new UpdateDocument {
                  { "$set", new BsonDocument("money", current_money) }
               };

               accounts.Update(query, update_document);

               Dictionary<string, object> elements = new Dictionary<string, object>();

               elements.Add("type", "sell");
               elements.Add("sell_amount", amount);
               elements.Add("sell_value", value);
               elements.Add("current_money", current_money);

               BsonDocument to_be_inserted = new BsonDocument(elements);

               var history_update_document = new UpdateDocument {
                  { "$push", new BsonDocument("history_list", to_be_inserted) }
               };

               history_collection.Update(query_history_collection, history_update_document);

               return current_money;

            }
            catch
            {

            }
         }

         return -1;
      }

      public static double GetMoney(string username)
      {
         if (db_management == null)
         {
            db_management = new DatabaseManagment();
         }

         MongoCollection<BsonDocument> accounts = database.GetCollection<BsonDocument>("users");
         var query = Query.EQ("username", username);
         var cursor = accounts.Find(query);

         foreach (BsonDocument c in cursor)
         {
            try
            {
               double current_money = c.GetValue("money").AsDouble;

               return current_money;

            }
            catch
            {

            }
         }

         return -1;
      }

      public static double ResetOrder(string username, double amount)
      {
         if (db_management == null)
         {
            db_management = new DatabaseManagment();
         }

         MongoCollection<BsonDocument> accounts = database.GetCollection<BsonDocument>("users");
         MongoCollection<BsonDocument> history_collection = database.GetCollection<BsonDocument>("history");
         var query = Query.EQ("username", username);
         var cursor = accounts.Find(query);

         foreach (BsonDocument c in cursor)
         {
            try
            {
               var update_document = new UpdateDocument {
                  { "$set", new BsonDocument("money", amount) }
               };

               BsonElement account_id;
               c.TryGetElement("history_id", out account_id);

               string string_id = account_id.Value.AsString;
               ObjectId object_id = new ObjectId(string_id);
               var query_history_collection = Query.EQ("_id", object_id);

               accounts.Update(query, update_document);

               var history_update_document = new UpdateDocument {
                  { "$unset", new BsonDocument("history_list", "") }
               };

               history_collection.Update(query_history_collection, history_update_document);

               return amount;

            }
            catch
            {

            }
         }

         return 0;
      }

      public static List<Tuple<string, string, double, double>> GetHistory(string username)
      {
         if (db_management == null)
         {
            db_management = new DatabaseManagment();
         }

         MongoCollection<BsonDocument> accounts = database.GetCollection<BsonDocument>("users");
         MongoCollection<BsonDocument> history_collection = database.GetCollection<BsonDocument>("history");
         var query = Query.EQ("username", username);
         var cursor = accounts.Find(query);

         foreach (BsonDocument c in cursor)
         {
            try
            {
               BsonElement account_id;
               c.TryGetElement("history_id", out account_id);

               string string_id = account_id.Value.AsString;
               ObjectId object_id = new ObjectId(string_id);
               var query_history_collection = Query.EQ("_id", object_id);

               var returned_document = history_collection.FindOne(query_history_collection);

               BsonValue value;
               returned_document.TryGetValue("history_list", out value);

               BsonArray bson_arr = value.AsBsonArray;
               var element_arr = bson_arr.ToArray();

               foreach (BsonValue val in element_arr)
               {
                  

               }
            }
            catch
            {

            }
         }

         return null;
      }

   }
}

