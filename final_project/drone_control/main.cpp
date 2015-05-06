////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// Author: Jarret Shook
//
// Module: main.cpp
//
// Timeperiod:
//
// 29-Oct-14: Version 1.0: Created
// 29-Oct-14: Version 1.0: Last updated
//
// Notes:
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#include <unistd.h>
#include <termios.h>

#include "ar_drone.hpp"

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


char getch() 
{
    char buf = 0;
    struct termios old = {0};
    
    if (tcgetattr(0, &old) < 0)
        perror("tcsetattr()");
            
    old.c_lflag &= ~ICANON;
    old.c_lflag &= ~ECHO;
    old.c_cc[VMIN] = 1;
    old.c_cc[VTIME] = 0;
    
    if (tcsetattr(0, TCSANOW, &old) < 0)
        perror("tcsetattr ICANON");
    
    if (read(0, &buf, 1) < 0)
        perror ("read()");
    
    old.c_lflag |= ICANON;
    old.c_lflag |= ECHO;
    
    if (tcsetattr(0, TCSADRAIN, &old) < 0)
        perror ("tcsetattr ~ICANON");
    
    return (buf);
}


int main()
{
    ar_drone drone;
    
    char key_code;
    
    while (1)
    {
        key_code = getch();
        
        switch (key_code)
        {
            case '1':	
        	    drone.speed_change(key_code - '0');
        	   	break;
        	case '2':	
        	    drone.speed_change(key_code - '0');
        	  	break;
        	case '3':
                drone.speed_change(key_code - '0');
        	  	break;
        	case '4':	
        	    drone.speed_change(key_code - '0');
        	   	break;
        	case '5':	
        	    drone.speed_change(key_code - '0');
        	  	break;
        	case '6':	
        	    drone.speed_change(key_code - '0');
        	  	break;
        	case '7':	
        	    drone.speed_change(key_code - '0');
        	  	break;
        	case '8':	
        	    drone.speed_change(key_code - '0');
        	 	break;
        	case '9':	
        	    drone.speed_change(key_code - '0');
        	  	break;
            case 'o':	// o
                drone.go_up();
                break;
            case 'w':   // w
    	  	    drone.go_forward();
                break;
        	case 'l':	// l
           	    drone.go_down();
                break;
            case 's':  // s
                drone.go_backwards();
                break;
        	case 'k':	// n
                drone.rotate_left();
                break;
            case 'a':   // a
                drone.go_left();
                break;
        	case ';':	// m
                drone.rotate_right();
                break;
            case 'd':   // d
    		    drone.go_right();
                break;
            case 'h':	// SpaceBar
        	   	drone.hover();
                break;
        	case 'u':	
        	  	drone.take_off();
                break;
        	 case 'j':
        	   	drone.land();
                break;
    		case 82:	// R of reset
        	   	drone.reset();
                break;
            default:
                break;       
        }   
        
    }
}

////////////////////////////////////////////////////////////////////////////////
// End of main.cpp
////////////////////////////////////////////////////////////////////////////////
