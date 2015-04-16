////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// Module: server.hpp
//
// Author: Jarret Shook
// Modified by: Candie Solis, 15 April 2015
//
// Versions
//
// Jan 11, 2015: Version 1.0: Created
// Jan 11, 2015: Version 1.0: Last Updated
// 
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#ifndef __SERVER_HPP__
#define __SERVER_HPP__

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#include <functional>
#include <vector>

#include "socket.hpp"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

namespace ev9 {

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

template<bool __WriteBack = true> class server
{
   public:  // Constructor | Destructor

      server(std::size_t socket_number, std::function<void(std::vector<char>&, std::vector<char>&)> response_function) { _ctor(socket_number, response_function); }
      ~server() { _dtor(); }

   public:  // Public Member Functions

      void start() { _start(); }

   private: // Private Member Function

      void _ctor(std::size_t socket_number, std::function<void(std::vector<char>&, std::vector<char>&)> response_function)
      {
         m_socket_number = socket_number;
         m_function = response_function;
      }

      void _dtor()
      {

      }

      void _start()
      {
         ev9::socket* socket = new ev9::socket(m_socket_number);

         socket->bind();
         socket->listen();
         socket->accept();

         while (1)
         {
            std::vector<char> input, output;

            socket->read(input);

            m_function(input, output);

            std::string output_string(output.begin(), output.end());
            
            if (__WriteBack)
            {
               socket->write_back(output_string);
            }
         }

         delete socket;
      }

   private: // Private member variable

      std::function<void(std::vector<char>&, std::vector<char>&)> m_function;
      int m_socket_number;

}; // end of class(sever)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

} // end of namespace(ev9)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#endif // __SERVER_HPP__

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
