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

public class Router
{
	private Socket _socket;

	public Router()
	{
		IPEndPoint endpoint = new IPEndPoint (IPAddress.Loopback, 8080);
		_socket = new Socket (AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

		_socket.Bind (endpoint);
		_socket.Listen (1024);

		while (true) 
		{
			Socket accepting_socket = _socket.Accept ();

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
		}
	}

	private void handler_start(Socket socket, string message)
	{
		if (message.Length < 4) 
		{
			return;
		}

		// Get the switching number from the first character sent
		int switch_number = message [0];

		if (switch_number == 0) {
			handle_setting_up_account (socket, message);
		} else if (switch_number == 1) {
			handle_signing_in (socket, message);
		} else if (switch_number == 2) {
			handle_remove_account (socket, message);
		} else if (switch_number == 3) {
			handle_get_stock_information (socket, message);
		} else if (switch_number == 4) {
			handle_buy_order (socket, message);
		} else if (switch_number == 5) {
			handle_sell_order (socket, message);
		} else if (switch_number == 6) {
			handle_get_history (socket, message);
		} else if (switch_number == 7) {
			handle_get_amount_of_money (socket, message);
		}
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Function Mapping: 0 -> setup_account
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
	private void handle_setting_up_account(Socket socket, string message)
	{
		int username_size = message [1];

		if (message.Length > username_size + 1) {
			return;
		}

		int password_size = message [1 + username_size + 1];

		if (message.Length > username_size + password_size + 3) {
			return;
		}

		string username = message.Substring (2, username_size);
		string password = message.Substring (1 + username_size + 1, password_size);

		string returned_message = StockApp.DatabaseManagment.SetupAccount (username, password);

		socket.Send(Encoding.ASCII.GetBytes(returned_message));
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Function Mapping: 1 -> sign_in
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
	private void handle_signing_in(Socket socket, string message)
	{
		int username_size = message [1];

		if (message.Length > username_size + 1) {
			return;
		}

		int password_size = message [1 + username_size + 1];

		if (message.Length > username_size + password_size + 3) {
			return;
		}

		string username = message.Substring (2, username_size);
		string password = message.Substring (1 + username_size + 1, password_size);

		string returned_message = StockApp.DatabaseManagment.SignIn (username, password);

		socket.Send(Encoding.ASCII.GetBytes(returned_message));
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Function Mapping: 2 -> remove_account
	//
	// Expected format:
	//
	// [<character representing the function to call>
	//  <character with the size of the first string>
	//  "username"]
	//
	////////////////////////////////////////////////////////////////////////////////
	private void handle_remove_account(Socket socket, string message)
	{
		int username_size = message [1];

		if (message.Length > username_size + 1) {
			return;
		}

		string username = message.Substring (2, username_size);

		bool returned_message = StockApp.DatabaseManagment.DeleteAccount (username);

		if (returned_message == false) {
			string return_message = "0";

			socket.Send(Encoding.ASCII.GetBytes(return_message));
		} else {
			string return_message = "1";

			socket.Send(Encoding.ASCII.GetBytes(return_message));
		}
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Function Mapping: 3 -> get_stock_information
	//
	// Expected format:
	//
	// [<character representing the function to call>
	//  <character representing size of size string>
	//  "size of stock names"
	//  [<character with the size of the first string>
	//  "stockname"]]
	//
	////////////////////////////////////////////////////////////////////////////////
	private void handle_get_stock_information(Socket socket, string message)
	{
		int size_of_string_size = message [1];

		if (message.Length > size_of_string_size + 1) {
			return;
		}

		string size_as_string = message.Substring (2, size_of_string_size);
		int amount_of_stock_names = int.Parse (size_as_string);

		List<string> stock_name_list = new List<string> ();

		int start = 2 + size_of_string_size;
		for (int index = 0; index < amount_of_stock_names; ++index) {
			int stock_size = message [start];

			if (message.Length > start + stock_size + 1) {
				throw new Exception ("Incorrectly Formatting String");
			}

			string stock_name = message.Substring (start, stock_size);

			stock_name_list.Add (stock_name);

			start += stock_size;
		}

		// Here there is a list of strings to query the API for

		//base URL
		string sURL = "http://finance.google.com/finance/info?client=ig&q=NASDAQ:";


		// adds stock tickers to url with comma between them
		for (int index = 0; index < stock_name_list.Count - 1; ++index) {
			sURL += stock_name_list [index];
			if (index < stock_name_list.Count - 2) {
				sURL += ",";
			}
		}

		// create web request
		WebRequest wrGETURL;
		wrGETURL = WebRequest.Create(sURL);

		Stream objStream;
		objStream = wrGETURL.GetResponse().GetResponseStream();

		StreamReader objReader = new StreamReader(objStream);

		string sLine = "";
		int i = 0;

		while (sLine!=null)
		{
			i++;
			sLine = objReader.ReadLine();
			if (sLine!=null)
				Console.WriteLine("{0}:{1}",i,sLine);
		}
		Console.ReadLine();
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Function Mapping: 4 -> buy_order
	//
	// Expected format:
	//
	// [<character representing the function to call>
	//  <character with the size of the first string>
	//  "stock"
	//  <character with the size of the second string>
	//  "size of order"]
	//
	////////////////////////////////////////////////////////////////////////////////
	private void handle_buy_order(Socket socket, string message)
	{

	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Function Mapping: 5 -> sell_order
	//
	// Expected format:
	//
	// [<character representing the function to call>
	//  <character with the size of the first string>
	//  "stock"
	//  <character with the size of the second string>
	//  "size of order"]
	//
	////////////////////////////////////////////////////////////////////////////////
	private void handle_sell_order(Socket socket, string message)
	{

	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Function Mapping: 6 -> get_history
	//
	// Expected format:
	//
	// [<character representing the function to call>
	//  <character with the size of the first string>
	//  "username"]
	//
	////////////////////////////////////////////////////////////////////////////////
	private void handle_get_history(Socket socket, string message)
	{

	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Function Mapping: 7 -> get_amount_of_money
	//
	// Expected format:
	//
	// [<character representing the function to call>
	//  <character with the size of the first string>
	//  "username"]
	//
	////////////////////////////////////////////////////////////////////////////////
	private void handle_get_amount_of_money(Socket socket, string message)
	{

	}
}
