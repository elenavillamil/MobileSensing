#include <functional>
#include <thread>
#include <vector>

#include "server.hpp"

int main() 
{
	//new std::thread([] () 
   //{
      auto server = new ev9::server<false>(8080, [](std::vector<char>& input, std::vector<char>& output)
      {
			//output.push_back('h');
		}); // end new server
	//});  // end new thread

   return 0;

}//end main

// get png decoder
