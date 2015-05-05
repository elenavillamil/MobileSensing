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
    	  	break;
    	case 38:	// Up
            if (shift)
            {
    	  	    action = "Go Up (gaz+)";
    	   	    at_cmd = start + std::to_string(seq++) + ",1,0,0," + std::to_string(static_cast<int>(speed)) + ",0";
    	    } else 
            {
    	  	    action = "Go Forward (pitch+)";
    	   	    //at_cmd = "AT*PCMD=" + (seq++) + ",1," + intOfFloat(speed) + ",0,0,0";
				at_cmd = start + std::to_string(seq++) + ",1,0," + std::to_string(static_cast<int>(-speed)) + ",0,0";
    	    }
    	    break;
    	case 40:	// Down
    	   	if (shift) {
    	   	    action = "Go Down (gaz-)";
    	   	    at_cmd = start + std::to_string(seq++) + ",1,0,0," + std::to_string(static_cast<int>(-speed)) + ",0";
    	   	} else {
    	   	    action = "Go Backward (pitch-)";
    	   	    //at_cmd = "AT*PCMD=" + (seq++) + ",1," + intOfFloat(-speed) + ",0,0,0";
				at_cmd = start + std::to_string(seq++) + ",1,0," + std::to_string(static_cast<int>(speed)) + ",0,0";
    	    }
       	   	break;
    	case 37:	// Left 
    	   if (shift) 
           {
    	       action = "Rotate Left (yaw-)";
			   at_cmd = start + std::to_string(seq++) + ",1,0,0,0," + std::to_string(static_cast<int>(-speed));
		   } else {
		       action = "Go Left (roll-)";
		       //at_cmd = "AT*PCMD=" + (seq++) + ",1,0," + intOfFloat(-speed) + ",0,0";
			   at_cmd = start + std::to_string(seq++) + ",1," + std::to_string(static_cast<int>(-speed)) + ",0,0,0";
		   }
    	   break;
    	case 39:	// Right
            if (shift) {
                action = "Rotate Right (yaw+)";
			    at_cmd = start + std::to_string(seq++) + ",1,0,0,0," + std::to_string(static_cast<int>(speed));
		    } else {
			    action = "Go Right (roll+)";
				//at_cmd = "AT*PCMD=" + (seq++) + ",1,0," + intOfFloat(speed) + ",0,0";
				at_cmd = start + std::to_string(seq++) + ",1," + std::to_string(static_cast<int>(speed)) + ",0,0,0";
			}
    	    break;
        case 32:	// SpaceBar
    	   	action = "Hovering";
    	   	at_cmd = start + std::to_string(seq++) + ",1,0,0,0,0";
    	   	break;
    	case 'u':	
    	  	action = "Takeoff";
    	   	at_cmd = std::string("AT*REF=") + std::to_string(seq++) + ",290718208";
    	   	break;
    	 case 'd':
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
		
	sock->write(at_cmd);
}