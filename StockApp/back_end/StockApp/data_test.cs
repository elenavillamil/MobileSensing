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

         // Test that the SignIn is successful. 
         // An empty string is returned when login fails
         if ("" == DatabaseManagment.SignIn (username, password))
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

         // Test that the account could be created with this unique credentials.
         // A 1 is returned when the sing up is successful.
         if (DatabaseManagment.SetupAccount (username, password) != 1)
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
         if (DatabaseManagment.SetupAccount (username, password) != 0) 
         {
            throw new Exception("FAILED TEST: sign up allows duplicated accounts");
         }
      }

      private void TestRemoveAccount()
      {
         string username = "ele";
         string password = "villa";

         // This line of code has its own test as well.
         int result = DatabaseManagment.SetupAccount (username, password);

         // Ensuring that account was actually created before trying to remove it.
         if (result != 1) {
            throw new Exception ("FAILED TEST: failed to add account in TestRemoveAccount");
         }
         // Ensurign successful removal of the account.
         else if (!DatabaseManagment.DeleteAccount (username)) {
            throw new Exception ("FAILED TEST: failed to removed account");
         } 
         // Ensuring the account was acctually removed and we cannot login back into it.
         else if (DatabaseManagment.SignIn (username, password) == "") 
         {
            throw new Exception ("FAILED TEST: account persists after removal");
         }
      }

      // Constructor
     
      public DataTest() : base(2)
      {
         // Test with Two Threads
 
         Run (TestProperLogin);
         Run (TestFailedLogin);
         Run (TestSuccessfulSignUp);
         Run (TestUnsuccessfulSignUp);
      }
   }
}
