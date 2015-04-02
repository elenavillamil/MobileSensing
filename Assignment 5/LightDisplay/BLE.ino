/*  Transmit data method uses code found at
http://wiki.lijun.xyz/misc-dust-detector-with-arduino-ble.html
*/


/**************************************************************************/
/*!
    This function is called whenever select ACI events happen
*/
/**************************************************************************/
void aciCallback(aci_evt_opcode_t event)
{
  switch(event)
  {
    case ACI_EVT_DEVICE_STARTED:
      Serial.println(F("Advertising started"));
      break;
    case ACI_EVT_CONNECTED:
      Serial.println(F("Connected!"));
      break;
    case ACI_EVT_DISCONNECTED:
      Serial.println(F("Disconnected or advertising timed out"));
      break;
    default:
      break;
  }
}

/**************************************************************************/
/*!
    This function is called whenever data arrives on the RX channel
*/
/**************************************************************************/
void rxCallback(uint8_t *buffer, uint8_t len)
{
  Serial.print(F("Received "));
  Serial.print(len);
  Serial.print(F(" bytes: "));
  for(int i=0; i<len; i++)
   Serial.print((char)buffer[i]); 

  Serial.print(F(" ["));

  for(int i=0; i<len; i++)
  {
    Serial.print(" 0x"); Serial.print((char)buffer[i], HEX); 
  }
  Serial.println(F(" ]"));

  /* Echo the same data back! */
  bt.write(buffer, len);
}

/**************************************************************************/
/*!
    This function is called sends a message to the BLE it will transmit 4 bytes
*/
/**************************************************************************/


void transmitValBle (int data) {
   // Note that data is an integer between 0 and 1023
    // To transmit in ASCII string, need to get the digits on each 
    // decimal place
    uint8_t dd[4]; 
    dd[3] = data/1000; 
    dd[2] = (data - dd[3]*1000)/100; 
    dd[1] = (data - dd[3]*1000 - dd[2]*100)/10;
    dd[0] = data - dd[3]*1000 - dd[2]*100 - dd[1]*10; 
    
    uint8_t sendbuffer[5];
    // Now convert int to ASCII
    for(int ii=0; ii<4; ii++) {  
      sendbuffer[ii] = dd[3-ii] + '0';
    }
    sendbuffer[4]='\0';

    Serial.print(F("\n* Sending -> \"")); 
    Serial.print((char *)sendbuffer); 
    Serial.println("\"");

    // write the data to nRF8001, to be sent to smartphone
    bt.write(sendbuffer, 4);
    delay(3000);
}   
