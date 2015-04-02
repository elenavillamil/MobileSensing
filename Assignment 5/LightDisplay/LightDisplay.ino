#include <SPI.h>
#include <toneAC.h>
#include <Wire.h>
#include "pitches.h"
#include "Adafruit_BLE_UART.h"


// PIN ASSIGNMENTS
int LEDS[] = {A0,A1,A2,A3,A4,A5};
// USED TO SEND AC SIGNALS TO SPEAKER - BOTH USING PWM
//#define BUZZER_ONE 9
//#define BUZZER_TWO 10
// REDBEAR BLE PIN DEFAULTS
// REQ - 8
// RDY - 9
// RESET - USE 4 OR 7
// SPI 11-13
#define BUTTON 3
#define LED_INTENSITY_POT A6
#define VOLUME_POT A7


// SPEAKER VARIABLES
// note durations: 4 = quarter note, 8 = eighth note, etc.:
//int noteDurations[] = {4, 8, 8, 4,4,4,4,4 };
int volumeList[] = {20,16,12,8,4}; 
boolean buzz;
byte names[] = {'c', 'd', 'e', 'f', 'g', 'a', 'b', 'C'};  
//int tones[] = {1915, 1700, 1519, 1432, 1275, 1136, 1014, 956};
//int melody[] = { 262, 196, 196, 220, 196, 0, 247, 262 };
// count length: 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0
//        10                  20                  30

int melody[] = {
	NOTE_C2, NOTE_F3, NOTE_C3, NOTE_A2,
	NOTE_C3, NOTE_F3, NOTE_C3,
	NOTE_C3, NOTE_F3, NOTE_C3, NOTE_F3,
	NOTE_AS3, NOTE_G3, NOTE_F3, NOTE_E3, NOTE_D3, NOTE_CS3,
	NOTE_C3, NOTE_F3, NOTE_C3, NOTE_A2, // the same again
	NOTE_C3, NOTE_F3, NOTE_C3,
	NOTE_AS3, 0, NOTE_G3, NOTE_F3,
	NOTE_E3, NOTE_D3, NOTE_CS3, NOTE_C3};
 
// note durations: 4 = quarter note, 8 = eighth note, etc.:
int noteDurations[] = {
	4,    4,    4,    4,
	4,    4,          2,
	4,    4,    4,    4,
	3,   8, 8, 8, 8, 8,
	4,    4,    4,    4, // the same again
	4,    4,          2,
	4, 8, 8,    4,    4,
	4,    4,    4,    4,
	0};

int count = 0;
int count2 = 0;
int count3 = 0;
int MAX_COUNT = 24;
int statePin = LOW;

// LED VARIABLES
//int high = 200;
//int low = 0;

int ledQty = 6;
int ledOff = 0;
int ledIntensity = 200;

// TEMP BLE VARIABLES FOR ADAFRUIT BLE
#define ADAFRUITBLE_REQ 6
#define ADAFRUITBLE_RDY 2
#define ADAFRUITBLE_RST 5
Adafruit_BLE_UART bt = Adafruit_BLE_UART(ADAFRUITBLE_REQ, ADAFRUITBLE_RDY, ADAFRUITBLE_RST);

void playMelody();
void cycleDisplayAndSound();


// the setup function runs once when you press reset or power the board
void setup() {
  for (unsigned int index = 0; index < (sizeof(LEDS)/sizeof(int)); index++)
  {
   pinMode(LEDS[index], OUTPUT);
  }
//  pinMode(BUZZER_ONE, OUTPUT);
//  pinMode(BUZZER_TWO, OUTPUT);
  buzz = false;
  
  // BLE READY
  Serial.begin(9600);
  while(!Serial); // Leonardo/Micro should wait for serial init
  Serial.println(F("Adafruit Bluefruit Low Energy nRF8001"));
  //bt.setDeviceName("ARDUINO"); /* 7 characters max! */
  bt.begin(); 
  
  
}


/**************************************************************************/
/*!
    Constantly checks for new events on the nRF8001
*/
/**************************************************************************/
aci_evt_opcode_t laststatus = ACI_EVT_DISCONNECTED;

// the loop function runs over and over again forever
void loop() {
  //cycleDisplayAndSound();
  playMelody();
// Tell the nRF8001 to do whatever it should be working on.
  bt.pollACI();
// Ask what is our current status
  aci_evt_opcode_t status = bt.getState();
  // If the status changed....
  if (status != laststatus) {
    // print it out!
    if (status == ACI_EVT_DEVICE_STARTED) {
        Serial.println(F("* Advertising started"));
    }
    if (status == ACI_EVT_CONNECTED) {
        Serial.println(F("* Connected!"));
    }
    if (status == ACI_EVT_DISCONNECTED) {
        Serial.println(F("* Disconnected or advertising timed out"));
    }
    // OK set the last status change to this one
    laststatus = status;
  }

  if (status == ACI_EVT_CONNECTED) {
    // Lets see if there's any data for us!
    if (bt.available()) {
      Serial.print("* "); Serial.print(bt.available()); Serial.println(F(" bytes available from BTLE"));
    }
    // OK while we still have something to read, get a character and print it out
    //int c[2] = {0, 0}; 

    while (bt.available()) {
        int c = bt.read();
        Serial.println(c);

      
    switch(c){
        //case 0:
        case 48:
                //set light intensity
               Serial.println(F("set light intensity"));
//               if ((c[2] >= 0) && (c[2] < 255)) {
//                 ledIntensity = c[2];
//               }
               for (int i = 0; i < ledQty; i++) {
                 analogWrite(LEDS[i], ledIntensity);
               }
               break;
        //case 1:
        case 49:
//               //set buzzer intensity
//               Serial.println(F("set buzzer intensity"));
//               if ((c[2] >= 0) && (c[2] < 255)) {
                 //volume, check how this is working
//               }
               break;
        //case 2:
        case 50:
               //event/meeting
               Serial.println(F("event/meeting"));
               break;
        //case 3:
        case 51:
               //stop buzzer
               Serial.println(F("stop buzzer"));
               break;
        //case 4:
        case 52:
               //time to meeting
               Serial.println(F("time to meeting"));
               break;
        default:
               // nothing received
               //Serial.println(F("default"));
               break;
      }
    }
    Serial.println("I broke");

    // Next up, see if we have any data to get from the Serial console

    if (Serial.available()) {
      // Read a line from Serial
      Serial.setTimeout(100); // 100 millisecond timeout
      String s = Serial.readString();

      // We need to convert the line to bytes, no more than 20 at this time
      uint8_t sendbuffer[20];
      s.getBytes(sendbuffer, 20);
      char sendbuffersize = min(20, s.length());

      Serial.print(F("\n* Sending -> \"")); Serial.print((char *)sendbuffer); Serial.println("\"");

      // write the data
      bt.write(sendbuffer, sendbuffersize);
    }
  }
}


 
  
 void cycleDisplayAndSound() {
   for (int index = (sizeof(LEDS)/sizeof(int))-1; index >= 0; index--)
  {
    analogWrite(LEDS[index], ledIntensity);
    delay(500);              // wait for a second
    //analogWrite(leds[index], ledOff);    // turn the LED off by making the voltage LOW
    delay(500);     // wait for a second
  }
    //if (index != 0) {
//      for (int thisNote = 0; thisNote < 8; thisNote++) {
//        int noteDuration = 1000/noteDurations[thisNote];
//        toneAC(BUZZER_ONE, BUZZER_TWO, melody[thisNote], volumeList[0], true); // Play thisNote at full volume for noteDuration in the background.
//        delay(noteDuration * 4 / 3); // Wait while the tone plays in the background, plus another 33% delay between notes.
//        delay(1);
//      //}
//    }
//    noToneAC(); // Turn off toneAC2, can also use noToneAC2().
   //}  
 }
 
 


void playMelody(){

  // iterate over the notes of the melody:
  for (int thisNote = 0; noteDurations[thisNote] != 0; thisNote++) {
 
    // to calculate the note duration, take one second 
    // divided by the note type.
    //e.g. quarter note = 1000 / 4, eighth note = 1000/8, etc.
    int noteDuration = 2000/noteDurations[thisNote];
    tone(8, melody[thisNote],noteDuration * 0.9);
 
    // to distinguish the notes, set a minimum time between them.
    // the note's duration + 30% seems to work well:
    //int pauseBetweenNotes = noteDuration * 1.30;
    //delay(pauseBetweenNotes);
	delay(noteDuration);

  }
  }
 
