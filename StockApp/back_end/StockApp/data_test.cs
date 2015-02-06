////////////////////////////////////////////////////////////////////////////////
// Module: data_tester.cs
//
// Author: Jarret Shook
//
// Versions:
//
// 14-Nov-14: Version 1.0: Created
//
////////////////////////////////////////////////////////////////////////////////

using System;
using System.IO;
using System.Collections.Generic;
using ev9;
using JS;
using StockApp;
using System.Threading;
using System.Net.Sockets;
using System.Net;
using System.Text;

////////////////////////////////////////////////////////////////////////////////

namespace StockApp
{
   public class DataTest : Tester
   {

      private void TestProperLogin()
      {
         string username = "jashook";
         string password = "ev9";

         DatabaseManagment.SetupAccount (username, password);

         // Test that the SignIn is successful. 
         // An empty string is returned when login fails
         if (DatabaseManagment.SignIn (username, password) == "")
         {
            throw new Exception("FAILED TEST: Unable to sign in with correct username and password");
         }
      }

      private void TestFailedLogin()
      {
         string username = "jashook";
         string password = "mmm";

         // Test that the SignIn is not successful.
         // A string with the user id is return when the login is successful.
         if ("" != DatabaseManagment.SignIn (username, password)) 
         {
            throw new Exception("FAILED TEST: granted access when username and password are incorrect");
         }
      }

      private void TestSuccessfulSignUp()
      {
         string username = "elena";
         string password = "villamil";

         string signup_result = DatabaseManagment.SetupAccount (username, password);
         // Test that the account could be created with this unique credentials.
         // A 1 is returned when the sing up is successful.
         if (signup_result == "Username already exists" || signup_result == "DB problem")
         {
            throw new Exception("FAILED TEST: cannot add a valid account");
         }
         else
         {
            // this line of code has its own unittes aswell.
            DatabaseManagment.DeleteAccount (username);
         }
      }

      private void TestUnsuccessfulSignUp()
      {
         string username = "jashook";
         string password = "ev9";

         // The username is not unique, so sign up should not be successful.
         // 0 is returned when the sing up is unsuccessful due to not unique username.
         if (DatabaseManagment.SetupAccount (username, password) != "Username already exists") 
         {
            throw new Exception("FAILED TEST: sign up allows duplicated accounts");
         }
      }

      private void TestRemoveAccount()
      {
         string username = "ele";
         string password = "villa";

         // This line of code has its own test as well.
         string signup_result = DatabaseManagment.SetupAccount (username, password);

         // Ensuring that account was actually created before trying to remove it.
         if (signup_result == "Username already exists" || signup_result == "DB problem") {
            throw new Exception ("FAILED TEST: failed to add account in TestRemoveAccount");
         }
         // Ensurign successful removal of the account.
         else if (!DatabaseManagment.DeleteAccount (username)) {
            throw new Exception ("FAILED TEST: failed to removed account");
         } 
         // Ensuring the account was acctually removed and we cannot login back into it.
         else if (DatabaseManagment.SignIn (username, password) != "") 
         {
            throw new Exception ("FAILED TEST: account persists after removal");
         }
         // Check that it also remove the user's history
      }

      private void TestBuyOrder()
      {
         string username = "jashook";
         double amount = 10500; // 10,500

         double amount_result = DatabaseManagment.ResetOrder(username, amount);

         amount = 500;

         amount_result = DatabaseManagment.BuyOrder (username, "", 10, amount);

         // Test that the BuyOrder is successful. 
         // Zero if failed
         if (amount_result != 10000.0)
         {
            throw new Exception("FAILED TEST: Incorrect amount expected");
         }
      }

      // Test is not complited
      private void TestGetHistory()
      {
         string username = "jashook";

         List<Tuple<string, double, double, double, string>> amount_result = DatabaseManagment.GetHistory(username);

         foreach (var t in amount_result)
         {
            Console.WriteLine(t.Item1);
            Console.WriteLine(t.Item2);
            Console.WriteLine(t.Item3);
            Console.WriteLine(t.Item4);

         }
      }

      private void TestAddFavoriteAndGetFavorites()
      {
         string username = "elena";
         string password = "passowrd";

         string signup_result = DatabaseManagment.SetupAccount (username, password);

         if (signup_result != "Username already exists" && signup_result != "DB problem") 
         {
            DatabaseManagment.AddFavorite ("elena", "microsoft");
            DatabaseManagment.AddFavorite ("elena", "amazon");
         }

         var result = DatabaseManagment.GetFavorites (username);
         Console.WriteLine ("Printing Results");
         if (result.Count > 1)
         {
            if (result[0] != "microsoft")
            {
               throw new Exception("FAILED TEST: first favorite is not correct");
            }

            if (result[1] != "amazon")
            {
               throw new Exception("FAILED TEST: second favorite is not correct");
            }

         }
         else
         {
            throw new Exception("FAILED TEST: Either add favorite or get favorite does not work");
         }
      }

      private void TestRemoveFavorite()
      {
         string username = "jashook";
         string stock = "amzn";

         DatabaseManagment.AddFavorite(username, stock);
         DatabaseManagment.RemoveFavorite(username, stock);
      }
         
      private void TestSellOrder()
      {
         string username = "jashook";
         double amount = 9500; // 10,000

         double amount_result = DatabaseManagment.ResetOrder(username, amount);

         amount = 500;

         amount_result = DatabaseManagment.SellOrder(username, "", 10, amount);

         // Test that the SellOrder is successful. 
         // Zero if failed
         if (amount_result != 10000.0)
         {
            throw new Exception("FAILED TEST: Incorrect amount expected");
         }
      }

      private void TestResetOrder()
      {
         string username = "jashook";
         double amount = 9500; // 10,000

         double amount_result = DatabaseManagment.ResetOrder(username, amount);

         // Test that the SellOrder is successful. 
         // Zero if failed
         if (amount_result != 9500.0)
         {
            throw new Exception("FAILED TEST: Incorrect amount expected");
         }

         amount_result = DatabaseManagment.ResetOrder(username, 10000);
      }

      private void RunServer()
      {
         Thread thread = new Thread(new ThreadStart(Router.router_start));

         thread.Start();
      }

      private void TestHandleSettingUpAccount()
      {
         string username = "jashook";
         string password = "ev9";

         char function = (char)1;
         char username_size = (char)username.Length;
         char password_size = (char)password.Length;

         string message = "";

         message += function;
         message += username_size;
         message += username;
         message += password_size;
         message += password;

         IPEndPoint endpoint = new IPEndPoint (IPAddress.Loopback, 8080);
         Socket connecting_socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

         connecting_socket.Connect(endpoint);

         connecting_socket.Send(Encoding.ASCII.GetBytes(message));

         byte[] buffer = new byte[256];
         connecting_socket.Receive(buffer);

         int index = 0;

         for (index = 0; index < buffer.Length; ++index)
         {
            if (buffer[index] == 0)
            {
               break; 
            }
         }

         string returned_message = Encoding.ASCII.GetString(buffer, 0, index);

         if (returned_message != "Username already exists")
         {
            throw new Exception("Incorrect response, unexpectedly set up account.");
         }
      }

      private void TestHandleSigningIn()
      {
         string username = "jashook";
         string password = "ev9";

         char function = (char)2;
         char username_size = (char)username.Length;
         char password_size = (char)password.Length;

         string message = "";

         message += function;
         message += username_size;
         message += username;
         message += password_size;
         message += password;

         IPEndPoint endpoint = new IPEndPoint(IPAddress.Loopback, 8080);
         Socket connecting_socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

         connecting_socket.Connect(endpoint);

         connecting_socket.Send(Encoding.ASCII.GetBytes(message));

         byte[] buffer = new byte[256];
         connecting_socket.Receive(buffer);

         int index = 0;

         for (index = 0; index < buffer.Length; ++index)
         {
            if (buffer[index] == 0)
            {
               break;
            }
         }

         string returned_message = Encoding.ASCII.GetString(buffer, 0, index);

         if (returned_message == "Login failed")
         {
            throw new Exception("Incorrect response, unable to sign in.");
         }
      }

      private void TestHandleRemoveAccount()
      {
         string username = "jashook";

         char function = (char)3;
         char username_size = (char)username.Length;

         string message = "";

         message += function;
         message += username_size;
         message += username;

         IPEndPoint endpoint = new IPEndPoint(IPAddress.Loopback, 8080);
         Socket connecting_socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

         connecting_socket.Connect(endpoint);

         connecting_socket.Send(Encoding.ASCII.GetBytes(message));

         byte[] buffer = new byte[1];
         connecting_socket.Receive(buffer);

         string returned_message = Encoding.ASCII.GetString(buffer);

         if (returned_message == "0")
         {
            throw new Exception("Incorrect response, unable to delete account.");
         }
      }

      private void TestHandleBuyOrder()
      {
         string username = "jashook";
         string stock_name = "amzn";
         string value = "1000.0";
         string amount = "100";

         char function = (char)5;
         char username_size = (char)username.Length;
         char stock_name_size = (char)stock_name.Length;
         char value_size = (char)value.Length;
         char amount_size = (char)amount.Length;

         string message = "";

         message += function;
         message += username_size;
         message += username;
         message += stock_name_size;
         message += stock_name;
         message += amount_size;
         message += amount;
         message += value_size;
         message += value;

         IPEndPoint endpoint = new IPEndPoint(IPAddress.Loopback, 8080);
         Socket connecting_socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

         connecting_socket.Connect(endpoint);

         connecting_socket.Send(Encoding.ASCII.GetBytes(message));

         byte[] buffer = new byte[256];
         connecting_socket.Receive(buffer);

         int index = 0;

         for (index = 0; index < buffer.Length; ++index)
         {
            if (buffer[index] == 0)
            {
               break;
            }
         }

         string returned_message = Encoding.ASCII.GetString(buffer, 0, index);

         if (returned_message == "Buy failed")
         {
            throw new Exception("Incorrect response, unable to buy.");
         }
      }

      private void TestHandleSellOrder()
      {
         string username = "jashook";
         string stock_name = "amzn";
         string value = "1000.0";
         string amount = "100";

         char function = (char)6;
         char username_size = (char)username.Length;
         char stock_name_size = (char)stock_name.Length;
         char value_size = (char)value.Length;
         char amount_size = (char)amount.Length;

         string message = "";

         message += function;
         message += username_size;
         message += username;
         message += stock_name_size;
         message += stock_name;
         message += amount_size;
         message += amount;
         message += value_size;
         message += value;

         IPEndPoint endpoint = new IPEndPoint(IPAddress.Loopback, 8080);
         Socket connecting_socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

         connecting_socket.Connect(endpoint);

         connecting_socket.Send(Encoding.ASCII.GetBytes(message));

         byte[] buffer = new byte[256];
         connecting_socket.Receive(buffer);

         int index = 0;

         for (index = 0; index < buffer.Length; ++index)
         {
            if (buffer[index] == 0)
            {
               break;
            }
         }

         string returned_message = Encoding.ASCII.GetString(buffer, 0, index);

         if (returned_message == "Sell failed")
         {
            throw new Exception("Incorrect response, unable to sell.");
         }
      }

      private void TestHandleResetOrder()
      {
         char function = (char)11;
         string message = "";
         message += function;
         string username = "elena2";
         message += (char)username.Length;
         message += username;

         IPEndPoint endpoint = new IPEndPoint(IPAddress.Loopback, 8080);
         Socket connecting_socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

         connecting_socket.Connect(endpoint);

         connecting_socket.Send(Encoding.ASCII.GetBytes(message));

         byte[] buffer = new byte[256];
         connecting_socket.Receive(buffer);
      }

      private void TestHandleAddAndGetFavorites()
      {
         char function = (char)10;
         string message = "";
         message += function;
         string username = "elena2";
         message += (char)username.Length;
         message += username;
         string stock_name = "msft";
         message += (char)stock_name.Length;
         message += stock_name;

         IPEndPoint endpoint = new IPEndPoint(IPAddress.Loopback, 8080);
         Socket connecting_socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

         connecting_socket.Connect(endpoint);

         connecting_socket.Send(Encoding.ASCII.GetBytes(message));

         byte[] buffer = new byte[256];
         connecting_socket.Receive(buffer);

         //connecting_socket.Disconnect (true);

         //connecting_socket.Connect(endpoint);

         string new_message = "";

         function = (char)9;
         new_message += function;
         new_message += (char)username.Length;
         new_message += username;

         connecting_socket.Send(Encoding.ASCII.GetBytes(new_message));

         buffer = new byte[256];
         connecting_socket.Receive(buffer);

         int index = 0;

         for (index = 0; index < buffer.Length; ++index)
         {
            if (buffer[index] == 0)
            {
               break;
            }
         }

         string returned_message = Encoding.ASCII.GetString(buffer, 0, index);
         Console.Write(returned_message);
      }

      private void TestHandleGetStockInformation()
      {
         char function = (char)4;
         string message = "";
         char size = (char)2;
         string stock1 = "msft";
         string stock2 = "amzn";

         message += function;
         message += size;
         message += (char)stock1.Length;
         message += stock1;
         message += (char)stock2.Length;
         message += stock2;

         IPEndPoint endpoint = new IPEndPoint(IPAddress.Loopback, 8080);
         Socket connecting_socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

         connecting_socket.Connect(endpoint);

         connecting_socket.Send(Encoding.ASCII.GetBytes(message));

         byte[] buffer = new byte[256];
         connecting_socket.Receive(buffer);

         int index = 0;

         for (index = 0; index < buffer.Length; ++index)
         {
            if (buffer[index] == 0)
            {
               break;
            }
         }

         string returned_message = Encoding.ASCII.GetString(buffer, 0, index);
         Console.Write(returned_message);
      }

      private void TestHandleGetMoney()
      {
         string username = "jashook";

         char function = (char)8;
         char username_size = (char)username.Length;

         string message = "";

         message += function;
         message += username_size;
         message += username;

         IPEndPoint endpoint = new IPEndPoint(IPAddress.Loopback, 8080);
         Socket connecting_socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

         connecting_socket.Connect(endpoint);

         connecting_socket.Send(Encoding.ASCII.GetBytes(message));

         byte[] buffer = new byte[256];
         connecting_socket.Receive(buffer);

         int index = 0;

         for (index = 0; index < buffer.Length; ++index)
         {
            if (buffer[index] == 0)
            {
               break;
            }
         }

         string returned_message = Encoding.ASCII.GetString(buffer, 0, index);

         if (returned_message == "-1")
         {
            throw new Exception("Incorrect response, unable to get money.");
         }
      }

      private void TestHandleGetHistory()
      {
         string username = "jashook";

         char function = (char)7;
         char username_size = (char)username.Length;

         string message = "";

         message += function;
         message += username_size;
         message += username;

         IPEndPoint endpoint = new IPEndPoint(IPAddress.Loopback, 8080);
         Socket connecting_socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

         connecting_socket.Connect(endpoint);

         connecting_socket.Send(Encoding.ASCII.GetBytes(message));

         byte[] buffer = new byte[256];
         connecting_socket.Receive(buffer);

         int index = 0;

         for (index = 0; index < buffer.Length; ++index)
         {
            if (buffer[index] == 0)
            {
               break;
            }
         }

         string returned_message = Encoding.ASCII.GetString(buffer, 0, index);

         if (returned_message == "Empty")
         {
            throw new Exception("Incorrect response, unable to get money.");
         }
      }

      // Constructor
     
      public DataTest() : base(1)
      {
         // Test with Two Threads

         RunServer();
         Run(TestHandleSettingUpAccount);
         //Run(TestHandleSigningIn);
         //Run(TestHandleRemoveAccount);
         //Run(TestHandleBuyOrder);
         //Run(TestHandleSellOrder);
         //Run(TestHandleGetMoney);
         //Run(TestHandleGetHistory);
         //Run (TestHandleAddAndGetFavorites);
         Run (TestRemoveFavorite);
         //Run (TestGetHistory);
         //Run (TestAddFavoriteAndGetFavorites);
         /*Run (TestProperLogin);
         Run (TestFailedLogin);
         Run (TestSuccessfulSignUp);
         Run (TestUnsuccessfulSignUp);
         Run (TestRemoveAccount);
         Run (TestResetOrder);
         Run (TestBuyOrder);
         Run (TestSellOrder); */
      }
   }
}
