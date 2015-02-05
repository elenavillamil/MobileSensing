/////////////////////////////////////////////////////////////////////////////////
// Module: router.cs
//
// Versions:
//
// 28-Jan-14: Version 1.0: Created
// 28-Jan-14: Version 1.0: Last Updated
//
/////////////////////////////////////////////////////////////////////////////////

using System.Net;
using System.Net.Sockets;
using System.Web;
using System.Text;
using System.Threading;
using System.Collections.Generic;
using System;
using System.IO;
using JS;

namespace StockApp
{

   public class Router
   {
   	private static Socket _socket;

      public Router() { }

   	public static void router_start()
   	{
         TcpListener tcpListener = new TcpListener(IPAddress.Any, 8080);
         tcpListener.Start();

   		//_socket.Bind (endpoint);
   		//_socket.Listen (1024);

   		while (true) 
   		{
            Socket accepting_socket = tcpListener.AcceptSocket();

            Console.WriteLine("Connection!");

   			const int ARR_SIZE = 256;
   			int bytes_transfered = 0;

   			//Socket Buffer
   			byte[] buffer = new byte[ARR_SIZE];

   			string message = "";

   			do
   			{
   				bytes_transfered = accepting_socket.Receive(buffer, buffer.Length, 0);

   				message = message + Encoding.ASCII.GetString(buffer, 0, bytes_transfered);

   			} while (bytes_transfered == ARR_SIZE);

   			Thread starting_thread = new Thread (() => handler_start (accepting_socket, message));

            starting_thread.Start();
   		}
   	}

   	private static void handler_start(Socket socket, string message)
   	{
   		if (message.Length < 4) 
   		{
   			return;
   		}

   		// Get the switching number from the first character sent
   		int switch_number = message [0];

   		if (switch_number == 1) {
   			handle_setting_up_account (socket, message);
   		} else if (switch_number == 2) {
   			handle_signing_in (socket, message);
   		} else if (switch_number == 3) {
   			handle_remove_account (socket, message);
   		} else if (switch_number == 4) {
   			handle_get_stock_information (socket, message);
   		} else if (switch_number == 5) {
   			handle_buy_order (socket, message);
   		} else if (switch_number == 6) {
   			handle_sell_order (socket, message);
   		} else if (switch_number == 7) {
   			handle_get_history (socket, message);
   		} else if (switch_number == 8) {
   			handle_get_amount_of_money (socket, message);
   		}
   	}

   	////////////////////////////////////////////////////////////////////////////////
   	//
   	// Function Mapping: 1 -> setup_account
   	//
   	// Expected format:
   	//
   	// [<character representing the function to call>
   	//  <character with the size of the first string>
   	//  "username"
   	//  <character with the size of the second string>
   	//  "password"]
   	//
   	////////////////////////////////////////////////////////////////////////////////
   	private static void handle_setting_up_account(Socket socket, string message)
   	{
   		int username_size = message [1];

   		if (username_size + 1 > message.Length) {
   			return;
   		}

   		int password_size = message [username_size + 2];

   		if (username_size + password_size + 3 > message.Length) {
   			return;
   		}

   		string username = message.Substring (2, username_size);
   		string password = message.Substring (username_size + 3, password_size);

         string returned_message = DatabaseManagment.SetupAccount (username, password);

   		socket.Send(Encoding.ASCII.GetBytes(returned_message));
   	}

   	////////////////////////////////////////////////////////////////////////////////
   	//
   	// Function Mapping: 2 -> sign_in
   	//
   	// Expected format:
   	//
   	// [<character representing the function to call>
   	//  <character with the size of the first string>
   	//  "username"
   	//  <character with the size of the second string>
   	//  "password"]
   	//
   	////////////////////////////////////////////////////////////////////////////////
   	private static void handle_signing_in(Socket socket, string message)
   	{
         int username_size = message[1];

         if (username_size + 1 > message.Length)
         {
            return;
         }

         int password_size = message[username_size + 2];

         if (username_size + password_size + 3 > message.Length)
         {
            return;
         }

         string username = message.Substring(2, username_size);
         string password = message.Substring(username_size + 3, password_size);

         string returned_message = DatabaseManagment.SignIn(username, password);

         if (returned_message == "")
         {
            returned_message = "Login failed";
         }

         socket.Send(Encoding.ASCII.GetBytes(returned_message));
   	}

   	////////////////////////////////////////////////////////////////////////////////
   	//
   	// Function Mapping: 3 -> remove_account
   	//
   	// Expected format:
   	//
   	// [<character representing the function to call>
   	//  <character with the size of the first string>
   	//  "username"]
   	//
   	////////////////////////////////////////////////////////////////////////////////
   	private static void handle_remove_account(Socket socket, string message)
   	{
         int username_size = message[1];

         if (username_size + 1 > message.Length)
         {
            return;
         }

         string username = message.Substring(2, username_size);
         bool deleted = DatabaseManagment.DeleteAccount(username);

         string return_message = "";
         if (deleted == false)
         {
            return_message = "0";
         }

         else
         {
            return_message = "1";
         }

         socket.Send(Encoding.ASCII.GetBytes(return_message));
   	}

   	////////////////////////////////////////////////////////////////////////////////
   	//
   	// Function Mapping: 4 -> get_stock_information
   	//
   	// Expected format:
   	//
   	// [<character representing the function to call>
   	//  <character representing amount of stocks as strings>
   	//  [<character with the size of the first string>
   	//  "stockname"]]
   	//
   	////////////////////////////////////////////////////////////////////////////////
   	private static void handle_get_stock_information(Socket socket, string message)
   	{
         // Getting the list of stock names from the message string.
   		int amount_of_stock_names = message [1];

   		List<string> stock_name_list = new List<string> ();

         bool last_string = false;

         int start = 2;
   		for (int index = 0; index < amount_of_stock_names; ++index) 
         {
            if (index == amount_of_stock_names - 1)
            {
               last_string = true;
            }

   			int stock_size = message [start++];

            if (last_string == false)
            {
               if (start + stock_size + 1 > message.Length) {
                  Console.WriteLine("Incorrectly formatted string");

                  return;
               }
            }

   			string stock_name = message.Substring (start, stock_size);

   			stock_name_list.Add (stock_name);

   			start += stock_size;
   		}

         // Query Google Stock API for the information for each stock

   		string sURL = "http://finance.google.com/finance/info?client=ig&q=NASDAQ:";

   		// adds stock tickers to url with comma between them
   		for (int index = 0; index < stock_name_list.Count; ++index) {
   			sURL += stock_name_list [index];
   			if (index < stock_name_list.Count - 1) {
   				sURL += ",";
   			}
   		}

   		// create web request
   		WebRequest wrGETURL;
   		wrGETURL = WebRequest.Create(sURL);

   		Stream objStream;
   		objStream = wrGETURL.GetResponse().GetResponseStream();

   		StreamReader objReader = new StreamReader(objStream);

   		string  response = objReader.ReadToEnd();
         response = response.Substring (4);

         Console.WriteLine (response);

         StockInfo[] stock_info_from_json = JSON<StockInfo[]>.Parse (response);

         string to_be_send = "";
         to_be_send += (char)stock_info_from_json.Length;

         for (int i = 0; i < stock_info_from_json.Length; i++) 
         {
            to_be_send += stock_info_from_json [i].EncodeToSend ();
         }

         socket.Send(Encoding.ASCII.GetBytes(to_be_send));

   	}

   	////////////////////////////////////////////////////////////////////////////////
   	//
   	// Function Mapping: 5 -> buy_order
   	//
   	// Expected format:
   	//
   	// [<character representing the function to call>
   	//  <character with the size of the first string>
   	//  "stock"
   	//  <character with the size of the second string>
   	//  "size of order"
      //  <character with the size of the third string>
      //  "price of order" ]
   	//
   	////////////////////////////////////////////////////////////////////////////////
   	private static void handle_buy_order(Socket socket, string message)
   	{
         int first_str_size = message[1];

         if (first_str_size + 1 > message.Length)
         {
            return;
         }

         int second_string_size = message[first_str_size + 2];

         if (first_str_size + second_string_size + 3 > message.Length)
         {
            return;
         }

         int third_string_size = message[first_str_size + second_string_size+ 3];

         if (first_str_size + second_string_size + third_string_size + 4 > message.Length)
         {
            return;
         }

         int fourth_string_size = message[first_str_size + second_string_size + third_string_size + 4];

         if (first_str_size + second_string_size + third_string_size + fourth_string_size + 5 > message.Length)
         {
            return;
         }

         string username = message.Substring(2, first_str_size);
         string stock_name = message.Substring(first_str_size + 3, second_string_size);
         string order_size = message.Substring(first_str_size + second_string_size + 4, third_string_size);
         string sell_value = message.Substring(first_str_size + second_string_size + third_string_size + 5, fourth_string_size);

         int amount = int.Parse(order_size);
         double value = double.Parse(sell_value);

         double return_value = DatabaseManagment.BuyOrder(username, stock_name, amount, value);

         string return_message = "";
         if (return_value == -1)
         {
            return_message = "Buy failed";
         }

         else
         {
            return_message = return_value.ToString();
         }

         socket.Send(Encoding.ASCII.GetBytes(return_message));
   	}

   	////////////////////////////////////////////////////////////////////////////////
   	//
   	// Function Mapping: 6 -> sell_order
   	//
   	// Expected format:
   	//
      // [<character representing the function to call>
      //  <character with the size of the first string>
      //  "stock"
      //  <character with the size of the second string>
      //  "size of order"
      //  <character with the size of the third string>
      //  "price of order" ]
   	//
   	////////////////////////////////////////////////////////////////////////////////
   	private static void handle_sell_order(Socket socket, string message)
   	{
         int first_str_size = message[1];

         if (first_str_size + 1 > message.Length)
         {
            return;
         }

         int second_string_size = message[first_str_size + 2];

         if (first_str_size + second_string_size + 3 > message.Length)
         {
            return;
         }

         int third_string_size = message[first_str_size + second_string_size + 3];

         if (first_str_size + second_string_size + third_string_size + 4 > message.Length)
         {
            return;
         }

         int fourth_string_size = message[first_str_size + second_string_size + third_string_size + 4];

         if (first_str_size + second_string_size + third_string_size + fourth_string_size + 5 > message.Length)
         {
            return;
         }

         string username = message.Substring(2, first_str_size);
         string stock_name = message.Substring(first_str_size + 3, second_string_size);
         string order_size = message.Substring(first_str_size + second_string_size + 4, third_string_size);
         string sell_value = message.Substring(first_str_size + second_string_size + third_string_size + 5, fourth_string_size);

         int amount = int.Parse(order_size);
         double value = double.Parse(sell_value);

         double return_value = DatabaseManagment.SellOrder(username, stock_name, amount, value);

         string return_message = "";
         if (return_value == -1)
         {
            return_message = "Sell failed";
         }

         else
         {
            return_message = return_value.ToString();
         }

         socket.Send(Encoding.ASCII.GetBytes(return_message));
   	}

   	////////////////////////////////////////////////////////////////////////////////
   	//
   	// Function Mapping: 7 -> get_history
   	//
   	// Expected format:
   	//
   	// [<character representing the function to call>
   	//  <character with the size of the first string>
   	//  "username"]
   	//
   	////////////////////////////////////////////////////////////////////////////////
   	private static void handle_get_history(Socket socket, string message)
   	{
         int username_size = message[1];

         if (username_size + 1 > message.Length)
         {
            return;
         }

         string username = message.Substring(2, username_size);
         var result = DatabaseManagment.GetHistory(username);

         // <character representing the size of the list's size as a string>
         // "the list's size as a string"
         // <character representing the size of the first string>
         // "first string (buy or sell)"
         // <character representing the size of the second string>
         // "String representation of a double (
         // <character representing the size of the third string>
         // "String representation of a double (
         // <character representing the size of the third string>
         // "String representation of a double (

         string list_size_as_string = result.Count.ToString();
         char list_size = (char)list_size_as_string.Length;

         StringBuilder string_builder = new StringBuilder();

         string_builder.Append(list_size);
         string_builder.Append(list_size_as_string);

         foreach (var tuple in result)
         {
            char first_string_size = (char)tuple.Item1.Length;
            string first_string = tuple.Item1;
            
            string second_string = tuple.Item2.ToString();
            char second_string_size = (char)second_string.Length;

            string third_string = tuple.Item3.ToString();
            char third_string_size = (char)third_string.Length;

            string fourth_string = tuple.Item4.ToString();
            char fourth_string_size = (char)fourth_string.Length;
         
            string_builder.Append(first_string_size);
            string_builder.Append(first_string);

            string_builder.Append(second_string_size);
            string_builder.Append(second_string);

            string_builder.Append(third_string_size);
            string_builder.Append(third_string);

            string_builder.Append(fourth_string_size);
            string_builder.Append(fourth_string);
         }
            
         string return_message = string_builder.ToString();

         if (result.Count == 0)
         {
            return_message = "Empty";
         }

         socket.Send(Encoding.ASCII.GetBytes(return_message));
   	}

   	////////////////////////////////////////////////////////////////////////////////
   	//
   	// Function Mapping: 8 -> get_amount_of_money
   	//
   	// Expected format:
   	//
   	// [<character representing the function to call>
   	//  <character with the size of the first string>
   	//  "username"]
   	//
   	////////////////////////////////////////////////////////////////////////////////
   	private static void handle_get_amount_of_money(Socket socket, string message)
   	{
         int username_size = message[1];

         if (username_size + 1 > message.Length)
         {
            return;
         }

         string username = message.Substring(2, username_size);

         double returned_money = DatabaseManagment.GetMoney(username);

         if (returned_money == -1)
         {
            string return_message = "-1";

            socket.Send(Encoding.ASCII.GetBytes(return_message));
         }
         else
         {
            string return_message = returned_money.ToString();

            socket.Send(Encoding.ASCII.GetBytes(return_message));
         }
   	}
   }
}
