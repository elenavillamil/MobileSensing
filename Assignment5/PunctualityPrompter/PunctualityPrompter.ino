
/*

Copyright (c) 2012, 2013 RedBearLab

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

//"services.h/spi.h/boards.h" is needed in every new project
#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <EEPROM.h>
#include <RBL_nRF8001.h>
#include <RBL_services.h>


// REDBEAR BLE PIN ASSIGNMENTS
#define RB_BLE_RST         4    // CAN USE 4 OR 7

// SPI 11-13

#define MUSIC_SIGNAL_OUT    7

#define VOLUME_POT_IN      A4
#define INTENSITY_POT_IN   A5

#define LEDS_2_LITE        A0
#define INTENSITY_OUT      A1

void sendProtocol(unsigned char protocolBuffer[2])
{
  // Write everything over bluetooth
  if (ble_connected())
  {  
    ble_write_bytes(protocolBuffer, sizeof(char) * 2); 
  }
}

void setup()
{
  
  // Set your BLE Shield name here, max. length 10
  ble_set_name("TeamE2");
  
  // Init. and start BLE library.
  ble_begin();
  
  // Enable serial debug
  Serial.begin(57600);
  
  pinMode(MUSIC_SIGNAL_OUT, OUTPUT);
  //pinMode(DIGITAL_IN_PIN, INPUT);
  
  // Default to internally pull high, change it if you need
  digitalWrite(MUSIC_SIGNAL_OUT, HIGH);
  //digitalWrite(DIGITAL_IN_PIN, LOW);
  
}

void loop()
{
  static boolean analog_enabled = false;
  static byte old_state = LOW;
  
  // Default to an unused protocol value
  unsigned char protocolBuffer[2] = { 255, 255 };
  unsigned char outputBuffer[2] = { 0, 0 };
  
  int changingLightIntensity = 0;
  int changingBuzzerLoudness = 0;
  int buzzerEvent = 0;
  
  int currentLightIntensity = 0;
  int currentBuzzerLoudness = 0;
  
  // If data is ready
  if (ble_available())
  {
    // Read the protocol value and its date
    protocolBuffer[0] = ble_read();
    protocolBuffer[1] = ble_read();
    
    Serial.println((int)protocolBuffer[0]);
    Serial.println((int)protocolBuffer[1]);
    
    // Command is to control digital out pin
    if (protocolBuffer[0] == 0)
    {
      int lightIntensity = (int)protocolBuffer[1];
  
      // Add in code to set the light intensity.
  
      Serial.println("Set light intensity");
      
    }
    
    else if (protocolBuffer[0] == 1)
    {
      int buzzerIntensity = (int)protocolBuffer[1];
    
      // Add in the code to set the buzzer intensity 
      
      Serial.println("Set buzzer intensity");
      
    }
    
    else if (protocolBuffer[0] == 2)
    {
      // Start the countdown for the event
      
      Serial.println("Start event countdown");
      
    }
    
    else if (protocolBuffer[0] == 3)
    {
      // Turn off the sound being played.
      
      //digitalWrite(MUSIC_SIGNAL_OUT, LOW); 
      
      Serial.println("Turn the sound off");
      
    }
    
    else if (protocolBuffer[0] == 4)
    {
      // Change the amount of time to wait for the event
     
     Serial.println("Change the wait time.");
      
    }

  }  
  
  if (changingLightIntensity)
  {
    // Send a signal to change the light intensity
    
    outputBuffer[0] = 0;
    outputBuffer[1] = currentLightIntensity;
    
    sendProtocol(outputBuffer);
  }
  
  else if (changingBuzzerLoudness)
  {
    // Send a signal to change the loudness
    
    outputBuffer[0] = 1;
    outputBuffer[1] = currentBuzzerLoudness;
    
    sendProtocol(outputBuffer);
  }
  
  else if (buzzerEvent)
  {
    // Send a signal saying the buzzer is going off
    
    outputBuffer[0] = 2;
    outputBuffer[1] = 255;
    
    sendProtocol(outputBuffer);
  }
  
  if (!ble_connected())
  {
    analog_enabled = false;
    digitalWrite(MUSIC_SIGNAL_OUT, LOW);
  }
  
  // Allow BLE Shield to send/receive data
  ble_do_events();

  delay(50);  
}




