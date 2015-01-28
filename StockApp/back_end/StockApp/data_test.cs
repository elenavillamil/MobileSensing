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
         // An empty string is sign 
         if ("" == DatabaseManagment.SignIn (username, password))
         {
            throw new Exception("FAILED TEST: Unable to sign in with correct username and password");
         }
      }

      private void TestFailedLogin()
      {
         string username = "jashook";
         string password = "mmm";

         if ("" != DatabaseManagment.SignIn (username, password)) 
         {
            throw new Exception("FAILED TEST: granted access when username and password are incorrect");
         }
      }

      private void TestSuccessfulSignUp()
      {
         string username = "elena";
         string password = "villamil";

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

         if (DatabaseManagment.SetupAccount (username, password) == 1) 
         {
            throw new Exception("FAILED TEST: sign up allows duplicated accounts");
         }
      }

      private void TestRemoveAccount()
      {
         string username = "ele";
         string password = "villa";

         int result = DatabaseManagment.SetupAccount (username, password);

         if (result != 1) 
         {
            throw new Exception ("FAILED TEST: failed to add account in TestRemoveAccount");
         }
         else if (!DatabaseManagment.DeleteAccount (username)) 
         {
            throw new Exception ("FAILED TEST: failed to removed account");
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
