#include <iostream>
#include "ar_drone.hpp"

ar_drone::ar_drone(const std::string& ip)
{
	sock = new ev9::socket<ev9::SOCKET_TYPE::UDP>(ip, 5556);
	sock->write("AT*CONFIG=1,\"control:altitude_max\",\"2000\"");
	
}

void ar_drone::control(int key_code)
{
	std::string at_cmd = "";
	std::string action = "";
	
	std::string start("AT*PCMD=");
	
    float current_speed = -speed;
    
	switch(key_code)
	{
		case '1':
    	    speed = 0.05;
    	   	break;
    	case '2':
    	    speed = 0.1;
    	  	break;
    	case '3':
    	    speed = 0.15;
    	  	break;
    	case '4':
    	    speed = 0.25;
    	   	break;
    	case '5':
    	    speed = 0.35;
    	  	break;
    	case '6':
    	    speed = 0.45;
    	  	break;
    	case '7':	// 7
    	    speed = 0.6;
    	  	break;
    	case '8':
    	    speed = 0.8;
    	 	break;
    	case '9':
    	    speed = 0.99;
    	  	break;
    	case 16:	// Shift
    	    shift = true;
            std::cout << "shifted" << std::endl;
    	  	break;
    	case 'o':	// o
            action = "Go Up (gaz+)";
    	    at_cmd = start + std::to_string(seq++) + ",1,0,0," + std::to_string(reinterpret_cast<int&>(speed)) + ",0";
            break;
        case 'w':   // w
	  	    action = "Go Forward (pitch+)";
	   	    //at_cmd = "AT*PCMD=" + (seq++) + ",1," + intOfFloat(speed) + ",0,0,0";
            
            current_speed = -speed;
               
			at_cmd = start + std::to_string(seq++) + ",1,0," + std::to_string(reinterpret_cast<int&>(current_speed)) + ",0,0";
    	    break;
    	case 'l':	// l
       	    action = "Go Down (gaz-)";
            
            current_speed = -speed;
               
       	    at_cmd = start + std::to_string(seq++) + ",1,0,0," + std::to_string(reinterpret_cast<int&>(current_speed)) + ",0";
       	    break;
        case 's':  // s
            action = "Go Backward (pitch-)";
	   	    //at_cmd = "AT*PCMD=" + (seq++) + ",1," + intOfFloat(-speed) + ",0,0,0";
			at_cmd = start + std::to_string(seq++) + ",1,0," + std::to_string(reinterpret_cast<int&>(speed)) + ",0,0";
       	   	break;
    	case 'k':	// n
            action = "Rotate Left (yaw-)";
            current_speed = -speed;
            
            at_cmd = start + std::to_string(seq++) + ",1,0,0,0," + std::to_string(reinterpret_cast<int&>(current_speed));
            break;
        case 'a':   // a
            action = "Go Left (roll-)";
	       //at_cmd = "AT*PCMD=" + (seq++) + ",1,0," + intOfFloat(-speed) + ",0,0";
           current_speed = -speed;
           
		   at_cmd = start + std::to_string(seq++) + ",1," + std::to_string(reinterpret_cast<int&>(current_speed)) + ",0,0,0";
    	   break;
    	case ';':	// m
            action = "Rotate Right (yaw+)";
		    at_cmd = start + std::to_string(seq++) + ",1,0,0,0," + std::to_string(reinterpret_cast<int&>(speed));
		    break;
        case 'd':   // d
		    action = "Go Right (roll+)";
			//at_cmd = "AT*PCMD=" + (seq++) + ",1,0," + intOfFloat(speed) + ",0,0";
			at_cmd = start + std::to_string(seq++) + ",1," + std::to_string(reinterpret_cast<int&>(speed)) + ",0,0,0";
    	    break;
        case 'h':	// SpaceBar
    	   	action = "Hovering";
    	   	at_cmd = start + std::to_string(seq++) + ",1,0,0,0,0";
    	   	break;
    	case 'u':	
    	  	action = "Takeoff";
    	   	at_cmd = std::string("AT*REF=") + std::to_string(seq++) + ",290718208";
    	   	break;
    	 case 'j':
    	   	action = "Landing";
    	   	at_cmd = std::string("AT*REF=") + std::to_string(seq++) + ",290717696";
    	   	break;
		case 82:	// R of reset
    	   	action = "Reset";
    	   	at_cmd = "AT*REF=1,290717952";
    	   	break;
    	default:
    	   	break;
    }
		
	std::cout << "Speed: " << speed << std::endl;
	std::cout << "Action: " << action << std::endl;
    std::cout << "Command: " << at_cmd << std::endl;
    
    at_cmd += '\r';
		
	sock->write(at_cmd);
}