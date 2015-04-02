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


// REDBEAR BLE PIN ASSIGNMENTS
#define RB_BLE_RST         4    // CAN USE 4 OR 7

// SPI 11-13

#define MUSIC_SIGNAL_OUT    7

#define VOLUME_POT_IN      A4
#define INTENSITY_POT_IN   A5

#define LEDS_2_LITE        A0
#define INTENSITY_OUT      A1



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
  
  // If data is ready
  while(ble_available())
  {
    // read out command and data
    byte data0 = ble_read();
    byte data1 = ble_read();
    
    Serial.println(data0);
    Serial.println(data1);
    
    if (data0 == 0x01)  // Command is to control digital out pin
    {
      if (data1 == 0x01)
        digitalWrite(MUSIC_SIGNAL_OUT, HIGH);
      else
        digitalWrite(MUSIC_SIGNAL_OUT, LOW);
    }

  }
  
  if (ble_connected()) 
  {
    unsigned char str[2];
    str[0] = 0;
    str[1] = 188;
 
    ble_write_bytes(str, sizeof(char)*2);
   
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




