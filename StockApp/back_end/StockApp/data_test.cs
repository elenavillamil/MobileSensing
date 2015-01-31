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

////////////////////////////////////////////////////////////////////////////////

namespace StockApp
{
   public class DataTest : Tester
   {

      private void TestProperLogin()
      {
         string username = "jashook";
         string password = "ev9";

         string signup_result = DatabaseManagment.SetupAccount (username, password);

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

      // Constructor
     
      public DataTest() : base(1)
      {
         // Test with Two Threads
 
         Run (TestProperLogin);
         Run (TestFailedLogin);
         Run (TestSuccessfulSignUp);
         Run (TestUnsuccessfulSignUp);
         Run (TestRemoveAccount);
         Run (TestResetOrder);
         Run (TestBuyOrder);
         Run (TestSellOrder);
      }
   }
}
