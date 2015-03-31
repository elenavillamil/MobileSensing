#include <toneAC2.h>
#include "pitches.h"


// note durations: 4 = quarter note, 8 = eighth note, etc.:
int noteDurations[] = {4, 8, 8, 4,4,4,4,4 };
 
int high = 200;
int low = 0;
int leds[] = {A1,A2,A3,A4,A5};
int buzzerOne = 5;
int buzzerTwo = 6;
int volumeList[] = {10,8,6,4,2}; 
int ledPin = 13;
int speakerOut = 8;               
byte names[] = {'c', 'd', 'e', 'f', 'g', 'a', 'b', 'C'};  
int tones[] = {1915, 1700, 1519, 1432, 1275, 1136, 1014, 956};
int melody[] = { 262, 196, 196, 220, 196, 0, 247, 262 };
// count length: 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0
//                                10                  20                  30
int count = 0;
int count2 = 0;
int count3 = 0;
int MAX_COUNT = 24;
int statePin = LOW;

//3,5,6,9,10,11
// the setup function runs once when you press reset or power the board
void setup() {
  // initialize digital pin 13 as an output.
   for (int index = 0; index < (sizeof(leds)/sizeof(int)); index++)
  {
   pinMode(leds[index], OUTPUT);
  }
  pinMode(buzzerOne, OUTPUT);
  pinMode(buzzerTwo, OUTPUT);
  boolean buzz = false;
  
  
}

// the loop function runs over and over again forever
void loop() {
  
  for (int index = (sizeof(leds)/sizeof(int))-1; index >= 0; index--)
  {
    analogWrite(leds[index], high);
    delay(500);              // wait for a second
    analogWrite(leds[index], low);    // turn the LED off by making the voltage LOW
    delay(500);     // wait for a second
    
    if (index != 0) {
      for (int thisNote = 0; thisNote < 8; thisNote++) {
        int noteDuration = 1000/noteDurations[thisNote];
        toneAC2(buzzerOne, buzzerTwo, melody[thisNote], volumeList[index], true); // Play thisNote at full volume for noteDuration in the background.
        delay(noteDuration * 4 / 3); // Wait while the tone plays in the background, plus another 33% delay between notes.
      }
    }
    noToneAC2(); // Turn off toneAC2, can also use noToneAC2().
    
  }
  
}
