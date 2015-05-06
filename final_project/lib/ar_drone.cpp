#include <iostream>
#include "ARDrone.hpp"

ar_drone::ar_drone(const std::string& ip)
{
	sock = new ev9::socket<ev9::SOCKET_TYPE::UDP>(ip, 5556);
	sock->write("AT*CONFIG=1,\"control:altitude_max\",\"2000\"");
	
    
    std::thread droneReset ([](){
        while (true) {
            std::string at_cmd = "AT*COMWDG=1";
            try {
                soc.write(at_cmd);
            } catch (exception& e) {
                cout << e.what() << '\n';
            }
            std::this_thread::sleep_for(300);
        }
    });
}

void ar_drone::speed_change(int val)
{
    send_command(val);
}

void ar_drone::take_off()
{
    send_command(19);
}

void ar_drone::hover()
{
    send_command(18);    
}

void ar_drone::land()
{
    send_command(20);    
}

void ar_drone::reset()
{
    send_command(21);    
}

void ar_drone::go_up()
{
    send_command(10);    
}

void ar_drone::go_forward()
{
    send_command(11);    
}

void ar_drone::go_down()
{
    send_command(12);    		
}

void ar_drone::go_backwards()
{
    send_command(13);    		
}


void ar_drone::rotate_left()
{
    send_command(14);    		
}


void ar_drone::go_left()
{
    send_command(15);    		
}


void ar_drone::rotate_right()
{
    send_command(16);   		
}

void ar_drone::go_right()
{
    send_command(17);    		
}


void ar_drone::send_command(int command_key)
{
    std::string action = "";
    std::string at_cmd = "";
    std::string start = std::string("AT*PCMD=");
    
	switch(command_key)
	{
		case 1:	
    	    speed = 0.05;
    	   	break;
    	case 2:	
    	    speed = 0.1;
    	  	break;
    	case 3:
    	    speed = 0.15;
    	  	break;
    	case 4:	
    	    speed = 0.25;
    	   	break;
    	case 5:	
    	    speed = 0.35;
    	  	break;
    	case 6:	
    	    speed = 0.45;
    	  	break;
    	case 7:	
    	    speed = 0.6;
    	  	break;
    	case 8:	
    	    speed = 0.8;
    	 	break;
    	case 9:	
    	    speed = 0.99;
    	  	break;
    	case 10:	// Go up
    	  	action = "Go Up (gaz+)";
    	   	at_cmd = start + std::to_string(seq++) + ",1,0,0," + std::to_string(static_cast<int>(speed)) + ",0";
    	    break;
        case 11:   // Go forward 
    	  	action = "Go Forward (pitch+)";
    	   	//at_cmd = "AT*PCMD=" + (seq++) + ",1," + intOfFloat(speed) + ",0,0,0";
		    at_cmd = start + std::to_string(seq++) + ",1,0," + std::to_string(static_cast<int>(-speed)) + ",0,0";
    	    break;
    	case 12:	// Go Down
    	   	action = "Go Down (gaz-)";
    	   	at_cmd = start + std::to_string(seq++) + ",1,0,0," + std::to_string(static_cast<int>(-speed)) + ",0";
    	   	break;
        case 13:    // Go Backwards
    	   	action = "Go Backward (pitch-)";
    	   	//at_cmd = "AT*PCMD=" + (seq++) + ",1," + intOfFloat(-speed) + ",0,0,0";
		    at_cmd = start + std::to_string(seq++) + ",1,0," + std::to_string(static_cast<int>(speed)) + ",0,0";
       	   	break;
    	case 14:	// Rotate Left 
    	    action = "Rotate Left (yaw-)";
			at_cmd = start + std::to_string(seq++) + ",1,0,0,0," + std::to_string(static_cast<int>(-speed));
		    break;
       case 15:     // Go Left
		    action = "Go Left (roll-)";
		    //at_cmd = "AT*PCMD=" + (seq++) + ",1,0," + intOfFloat(-speed) + ",0,0";
            at_cmd = start + std::to_string(seq++) + ",1," + std::to_string(static_cast<int>(-speed)) + ",0,0,0";
    	    break;
    	case 16:	// Rotate Right
            action = "Rotate Right (yaw+)";
			at_cmd = start + std::to_string(seq++) + ",1,0,0,0," + std::to_string(static_cast<int>(speed));
            break;  
        case 17:    // Go right
			action = "Go Right (roll+)";
		    //at_cmd = "AT*PCMD=" + (seq++) + ",1,0," + intOfFloat(speed) + ",0,0";
			at_cmd = start + std::to_string(seq++) + ",1," + std::to_string(static_cast<int>(speed)) + ",0,0,0";
    	    break;
        case 18:	// Hovering
    	   	action = "Hovering";
    	   	at_cmd = start + std::to_string(seq++) + ",1,0,0,0,0";
    	   	break;
    	case 19:	// Take off
            std::string action = "Takeoff";
            std::string at_cmd = std::string("AT*REF=") + std::to_string(seq++) + ",290718208";
    	  	break;
    	 case 20:	// Land
    	   	action = "Landing";
    	   	at_cmd = std::string("AT*REF=") + std::to_string(seq++) + ",290717696";
    	   	break;
		case 21:	// Reset
    	   	action = "Reset";
    	   	at_cmd = "AT*REF=1,290717952";
    	   	break;
    	default:
    	   	break;
    }
    
    std::cout << "Speed: " << speed << std::endl;
	std::cout << "Action: " << action << std::endl;
    std::cout << "Command: " << at_cmd << std::endl;		

	sock->write(at_cmd);
}
