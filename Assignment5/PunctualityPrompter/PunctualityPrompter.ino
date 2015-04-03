
/*

Copyright (c) 2012, 2013 RedBearLab

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

//"services.h/spi.h/boards.h" is needed in every new project
#include <SPI.h>
#include <boards.h>
#include <EEPROM.h>
#include <RBL_nRF8001.h>
#include <toneAC.h>
#include "Pitches.h"
#include <CountDownTimer.h>

/*********************************/
/*       PIN ASSIGNMENTS         */
/*********************************/
// REDBEAR 
#define RB_BLE_RST           4    // CAN USE 4 OR 7
#define RB_BLE_REQN          3    // Flexible REQN and RDYN pins selectable from pin 2 to 10, 
#define RB_BLE_RDYN          2    // these pins are otherwise fixed at 8 & 9 for BLE Shield v1
// ALSO USES SPI PINS 11-13 (uno) // IF YOU MODIFY REQN & RDYN - MUST MOVE JUMPERS ON BOARD
// OR SPI PINS 50-53 ON MEGA

// SOUND
// BY DEFAULT, ARDUINO MEGA REQUIRES FOLLOWING PIN ASSIGNMENTS
// SPEAKER_BLACK: 11, AND SPEAKER_RED: 12, WITH A 120 OHM RESISTOR
#define VOLUME_POT_IN      A11
#define BUTTON_PIN          21    // INT0 ON MEGA 2560

// LIGHTS
#define INTENSITY_POT_IN   A12
#define LED_DKGRN            7
#define LED_LTGRN            6
#define LED_BLUE             5
#define LED_YELLOW          44
#define LED_ORANGE          45
#define LED_RED             46


/*********************************/
/*           VARIABLES           */
/*********************************/


// COUNTDOWN TIMER
int totalPromptSeconds;
int secondsPerLED;
int timerIterations;
CountDownTimer timer;


//DEBOUNCE -- MODIFIED FROM DEBOUNCE EXAMPLE
int musicState;           // the current state of the output pin
int buttonState;          // the current reading from the input pin
int lastButtonState;      // the previous reading from the input pin
int buttonPressed;

// the following variables are long's because the time, measured in miliseconds,
// will quickly become a bigger number than can be stored in an int.
long lastDebounceTime;    // the last time the output pin was toggled
long debounceDelay;       // the debounce time; increase if the output flickers

// SOUND
int volumeKnob255;
int volumeBle255;
boolean volumeKnob_Changed;
boolean volumeBle_Changed;
int volume_10scale;
volatile int shouldPlayMelody;

// Melody liberated from the toneMelody Arduino example sketch by Tom Igoe.
int melody[] = { NOTE_C4, NOTE_F4, NOTE_C4, NOTE_F3, NOTE_C4, NOTE_F4, NOTE_C4,
  NOTE_C4, NOTE_F4, NOTE_C4, NOTE_F4,
  NOTE_A4, NOTE_G4, NOTE_F4, NOTE_E4, NOTE_D4, NOTE_CS4,
  NOTE_C4, NOTE_F4, NOTE_C4, NOTE_F3, NOTE_C4, NOTE_F4, NOTE_C4,
  NOTE_F4, NOTE_D4, NOTE_C4, NOTE_AS3,
  NOTE_A3, NOTE_G3, NOTE_F3 };
  
int noteDurations[] = { 4, 4, 4, 4, 4, 4, 2,
  4, 4, 4, 4,
  3, 8, 8, 8, 8, 8,
  4, 4, 4, 4, 4, 4, 2,
  3, 8, 4, 4,
  4, 4, 4 };

// LIGHTS
int ledKnobReading;
int ledIntensity;
boolean shouldLightLeds;
int warningTime;
int led_array[] = {LED_RED, LED_ORANGE, LED_YELLOW, LED_BLUE, LED_LTGRN, LED_DKGRN};

// NOTIFICATION PROMPTS TO SEND TO IOS

  boolean changingLightIntensity;
  boolean changingBuzzerLoudness;
  int buzzerEvent = 0;
  
  int currentLightIntensity = 0;
  int currentBuzzerLoudness = 0;

/*********************************/
/*      FUNCTION PROTOTYPES      */
/*********************************/
void sendProtocol(unsigned char protocolBuffer[2]);
void silence();
void playMelody();
void lightItUp(int led_qty);

/*********************************/
/*            SETUP              */
/*********************************/

void setup()
{
    // INITIALIZE TIMER
    totalPromptSeconds = 0;
    secondsPerLED = 0;
    timerIterations = 0;
    
    // INITIALIZE SPEAKER I/O PINS & VARIABLES
    pinMode(VOLUME_POT_IN, INPUT);
    analogWrite(VOLUME_POT_IN, 0);
    volume_10scale = 5;
    volumeKnob255 = -1;
    volumeBle255 = -1;
    volumeKnob_Changed = false;
    volumeBle_Changed = false;
    
    shouldPlayMelody = HIGH;
    attachInterrupt(2, silence, RISING); // FALLING for when the pin goes from high to low.
    
    // SETUP DEBOUNCE VARIABLES FOR THE BUTTON - DEBOUNCE WAS NOT AN ISSUE SO WE ARE NOT CALLING IT            
//    musicState = HIGH;                     // the current state of the output pin
//    buttonState = HIGH;                    // the current reading from the input pin
//    lastButtonState = LOW;
//    lastDebounceTime = 0;                  // the last time the output pin was toggled
//    debounceDelay = 50;                    // the debounce time; increase if the output flicker
//    buttonPressed = LOW;
  
    // INITALIZE LEDS I/O PINS & VARIABLES
    pinMode(LED_DKGRN, OUTPUT);
    pinMode(LED_LTGRN, OUTPUT);
    pinMode(LED_BLUE, OUTPUT);
    pinMode(LED_YELLOW, OUTPUT);
    pinMode(LED_ORANGE, OUTPUT);
    pinMode(LED_RED, OUTPUT);
    pinMode(INTENSITY_POT_IN, INPUT);
    
    analogWrite(LED_DKGRN, 0);
    analogWrite(LED_LTGRN, 0);
    analogWrite(LED_BLUE, 0);
    analogWrite(LED_YELLOW, 0);
    analogWrite(LED_ORANGE, 0);
    analogWrite(LED_RED, 0);
    analogWrite(INTENSITY_POT_IN, HIGH);
    
    ledKnobReading = 0;
    ledIntensity = 127;
    shouldLightLeds = HIGH;
    warningTime = 1800;
    shouldPlayMelody = LOW;
    
    // NOTIFICATIONS TO IOS
    changingBuzzerLoudness = false;
    
    // INITALIZE BLE 
    // Default pins set to 9 and 8 for REQN and RDYN
    // Set your REQN and RDYN here before ble_begin() if you need
    ble_set_pins(RB_BLE_REQN, RB_BLE_RDYN);      // DEFINED ABOVE 
    
    // Set your BLE Shield name here, max. length 10
    ble_set_name("TeamE2");
    
    // Init. and start BLE library.
    ble_begin();
    
    // Enable serial debug
    Serial.begin(57600);
    
    //DEBUGGING ONLY
    //shouldPlayMelody = LOW;
    shouldLightLeds = LOW;
}

/*********************************/
/*            LOOP               */
/*********************************/

void loop()
{
  // TO DO - UPDATE PHONE WITH NEW LOUDNESS VALUE WHEN VOLUME CHANGED
  
  
  //shouldPlayMelody = digitalRead();
  //buttonPressed = digitalRead(BUTTON_PIN);
  //volumeKnobReading = analogRead(VOLUME_POT_IN);

 delay(1000);
 //playMelody();
    



 // Serial.print("LEDs: ");
//  Serial.print(analogRead(A12));
//  Serial.print(",   ");
//  Serial.println(analogRead(A12));

//  static boolean analog_enabled = false;
//  static byte old_state = LOW;
//  

  // Default to an unused protocol value
  unsigned char protocolBuffer[2] = { 255, 255 };
  unsigned char outputBuffer[2] = { 0, 0 };
  
  // If data is ready
  if (ble_available())
  {
    // Read the protocol value and its date
    protocolBuffer[0] = ble_read();
    protocolBuffer[1] = ble_read();
    
    Serial.println((int)protocolBuffer[0]);
    Serial.println((int)protocolBuffer[1]);
    
    // CHANGE LIGHT INTENSITY VALUE --- DONE UNLESS WE ADD BACK POTENTIOMETER
    if (protocolBuffer[0] == 0)
    {
      ledIntensity = (int)protocolBuffer[1];
    }
    
    // CHANGE SPEAKER VOLUME -- DONE UNLESS WE WANT TO TWEAK VOLUME VALUES (WRITE OUR OWN MAP FN)
    else if (protocolBuffer[0] == 1)
    {
      volumeBle255 = (int)protocolBuffer[1];
      volumeBle_Changed = true;
    }
    
    // WE HAVE AN EVENT TO START COUNTING DOWN
    else if (protocolBuffer[0] == 2)
    {
      startEvent((int)protocolBuffer[1]);
    }
    
    // TURN SOUND OFF - DONE
    else if (protocolBuffer[0] == 3)
    {
      volumeBle255 = 0;
      volumeBle_Changed = true; 
    }
    
    // CHANGE EVENT COUNT TIME
    else if (protocolBuffer[0] == 4)
    {
     
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
    //analog_enabled = false;
    //digitalWrite(MUSIC_SIGNAL_OUT, LOW);
    //analogWrite(VOLUME_SIGNAL_OUT, volume);
  }
  
  // Allow BLE Shield to send/receive data
  ble_do_events();

  delay(50);  
} // en loop

/*********************************/
/*          FUNCTIONS            */
/*********************************/

void silence() {
    Serial.println("I'm supposed to shut up!");
    if (shouldPlayMelody == LOW) {
      Serial.println("Getting in the if");
      shouldPlayMelody = HIGH;
    }
//    
//    if (buttonPressed != lastButtonState) {
//      lastDebounceTime = millis();
//  }
//  
//  if ((millis() - lastDebounceTime) > debounceDelay) {
//      if (buttonPressed != lastButtonState) {
//          buttonState = buttonPressed;
//      
//          if (buttonState == HIGH) {
//              if (shouldPlayMelody == LOW) {
//                Serial.println("Getting in the if");
//                  shouldPlayMelody = HIGH;
//              }
//          }
//      }
//  }
}

void updateVolumeKnob255() {
  int volumeKnobReading1024 = analogRead(VOLUME_POT_IN);
  
  Serial.println(volumeKnobReading1024);
  
  int volumeKnobReading = map(volumeKnobReading1024, 1023, 0, 0, 255);
  if (volumeKnob255 != volumeKnobReading) {
    volumeKnob255 = volumeKnobReading;
    volumeKnob_Changed = true;
  }
}

void updateVolume10scale(){
  
  if (volumeKnob_Changed) {
    volume_10scale = map(volumeKnob255, 0, 255, 0, 10);
    if (volumeBle_Changed) {
      changingBuzzerLoudness = true;
      volumeBle255 = volumeKnob255;
    }
  }
  else if (volumeBle_Changed){
    volume_10scale = map(volumeBle255, 0, 255, 0, 10);
  }  
}

void playMelody() {
  
    toneAC(); // Turn off toneAC, can also use noToneAC().
    delay(2000); // Wait a second.
    Serial.print ("I'm in the mood for a melody!");
    for (int thisNote = 0; thisNote < (sizeof(noteDurations)/2); thisNote++) {
      if (shouldPlayMelody == LOW) {
        int noteDuration = 1000/noteDurations[thisNote];
        updateVolumeKnob255();
        updateVolume10scale();
        Serial.print("Knob255: "); Serial.print(volumeKnob255); Serial.print(",  Scale10: "); Serial.print(volume_10scale); Serial.print("\n");
        toneAC(melody[thisNote], volume_10scale, noteDuration, true); // Play thisNote at full volume for noteDuration in the background.
        delay(noteDuration * 4 / 3); // Wait while the tone plays in the background, plus another 33% delay between notes.
      }
    }
    noToneAC();
}

void lightItUp(int led_qty) {
  for (int index = 0; index < led_qty; index++) 
  {
    analogWrite(led_array[index], ledIntensity);
  }
}

void sendProtocol(unsigned char protocolBuffer[2])
{
  // Write everything over bluetooth
  if (ble_connected())
  {  
    ble_write_bytes(protocolBuffer, sizeof(char) * 2); 
  }
}

void startEvent (int minutes) {
  totalPromptSeconds = minutes * 60; 
  secondsPerLED = totalPromptSeconds / led_array.length();
  timerIterations = led_array.length(); 
  lightItUp(timerIterations);
  timer.StartTimer();
}

void updateEvent () {
  if (timer.TimeCheck(0, 0, 0)) {
    timerIterations = timerIterations - 1;
  }
}




