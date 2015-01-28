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

      private void TestSignIn()
      {
         string username = "jashook";
         string password = "ev9";

         DatabaseManagment.SetupAccount (username, password);

         string sign_in = DatabaseManagment.SignIn (username, password);

         if (sign_in == "")
         {
            throw new Exception("[StockApp::TestSignIn]" + " Unable to sign in");
         }

      }

      // Constructor
     
      public DataTest() : base(2)
      {
         // Test with Two Threads

         Run (TestSignIn);
      }
   }
}
