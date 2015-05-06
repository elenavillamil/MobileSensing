///////////////////////////////////////////////////////////////////////////////
//
// Author: Elena
// 
// Date: 0505/2015
//
// Notes: code taken from:
//      https://projects.ardrone.org/attachments/323/ARDrone.java
//
///////////////////////////////////////////////////////////////////////////////

#ifndef __ARDRONE_HPP__
#define __ARDRONE_HPP__

#include <string>
#include "socket.hpp"

class ar_drone 
{
	private:
		///////////////////////////////////////////////////////////////////////
		// Private Member Variables
		///////////////////////////////////////////////////////////////////////
		ev9::socket<ev9::SOCKET_TYPE::UDP>* sock;
		int seq = 1;
		float speed = 0.1;
		bool shift = false;
		float float_buffer[4];
		int int_buffer[4];
        
        void send_command(int command_key);
		
	public:
		///////////////////////////////////////////////////////////////////////
		// Constructor & Destructor
		///////////////////////////////////////////////////////////////////////
		
		ar_drone(const std::string& ip = "192.168.1.1");
		
		///////////////////////////////////////////////////////////////////////
		//Public Member Functions
		///////////////////////////////////////////////////////////////////////
		
		///////////////////////////////////////////////////////////////////////
		// val has to be a value from 1 to 9 (included). 
        // 0 is the slowest speed setting
        // 9 is the heighst speed setting
		///////////////////////////////////////////////////////////////////////
        void speed_change(int val);
        void take_off();
        void hover();
        void land();
        void reset();
        void go_up();
        void go_forward();
        void go_down();
        void go_backwards();
        void rotate_left();
        void go_left();
        void rotate_right();
        void go_right();	
};

#endif // __ARDRONE_HPP__