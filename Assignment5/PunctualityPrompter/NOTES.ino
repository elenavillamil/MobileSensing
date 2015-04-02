
    
//    while (1) {
//      if (counter == 2)
//      {
//        counter = 0;
//        break; 
//      }
//      
//      bt.pollACI();
//      
//      if (bt.available())
//      {
//        Serial.print("* "); Serial.print(bt.available()); Serial.println(F(" bytes available from BTLE"));
//        
//        c[counter++] = bt.read();
//        Serial.println((int)c[0]);
// 
//      }
//      
//    }
//    
//    switch(c[0]){
//        //case 0:
//     
//        case 5:
//                //set light intensity
//               Serial.println(F("set light intensity"));
////               if ((c[2] >= 0) && (c[2] < 255)) {
////                 ledIntensity = c[2];
////               }
//               for (int i = 0; i < ledQty; i++) {
//                 analogWrite(LEDS[i], ledIntensity);
//               }
//               break;
//        //case 1:
//        case 1:
////               //set buzzer intensity
////               Serial.println(F("set buzzer intensity"));
////               if ((c[2] >= 0) && (c[2] < 255)) {
//                 //volume, check how this is working
////               }
//               break;
//        //case 2:
//        case 2:
//               //event/meeting
//               Serial.println(F("event/meeting"));
//               break;
//        //case 3:
//        case 3:
//               //stop buzzer
//               Serial.println(F("stop buzzer"));
//               break;
//        //case 4:
//        case 4:
//               //time to meeting
//               Serial.println(F("time to meeting"));
//               break;
//        default:
//               // nothing received
//               //Serial.println(F("default"));
//               break;
//      
//    }
