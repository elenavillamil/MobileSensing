
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
#include <RBL_BLEShield.h>
#include <toneAC.h>
#include "Pitches.h"
#include "CountDownTimer.h"

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

// EVENTS
#define EVENT_INTERRUPT     20

/*********************************/
/*           VARIABLES           */
/*********************************/

// COUNTDOWN TIMER 
int totalPromptSeconds;
int secondsPerLED;
int timerIterations;
CountDownTimer timer;

//DEBOUNCE -- MODIFIED FROM DEBOUNCE EXAMPLE - DEBOUNCE WAS NOT AN ISSUE SO WE ARE NOT CALLING IT
//int musicState;           // the current state of the output pin
//int buttonState;          // the current reading from the input pin
//int lastButtonState;      // the previous reading from the input pin
//int buttonPressed;

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

int gAmountOfMinutesToCountdown;

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
int lightingKnob255;
boolean lightingKnob_Changed;
int ledIntensity;
int warningTime;
int led_array[] = {LED_RED, LED_ORANGE, LED_YELLOW, LED_BLUE, LED_LTGRN, LED_DKGRN};

// EVENTS
  boolean hasEvent;
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
    pinMode(EVENT_INTERRUPT, INPUT);
    digitalWrite(EVENT_INTERRUPT, HIGH);
    attachInterrupt(3, startEvent, CHANGE);  //interrupt 3 is on pin 20
    
    
    // INITIALIZE SPEAKER I/O PINS & VARIABLES
    pinMode(VOLUME_POT_IN, INPUT);
    analogWrite(VOLUME_POT_IN, 0);
    volume_10scale = 5;
    volumeKnob255 = -1;
    volumeBle255 = -1;
    volumeKnob_Changed = false;
    volumeBle_Changed = false;
    
    shouldPlayMelody = HIGH;
    attachInterrupt(2, silence, RISING); // RISING for when the pin goes from LOW to HIGH.
                                         // interrupt 3 is on pin 21
    
    
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
    
    int lightingKnob255 = 0;
    boolean lightingKnob_Changed = false;
    ledIntensity = 127;
    shouldPlayMelody = LOW;
    hasEvent = false;
    
    // NOTIFICATIONS TO IOS
    changingBuzzerLoudness = false;
    
    // INITALIZE BLE 
    // Default pins set to 9 and 8 for REQN and RDYN
    // Set your REQN and RDYN here before ble_begin() if you need
    ble_set_pins(RB_BLE_REQN, RB_BLE_RDYN);      // DEFINED ABOVE 
    
    // Set your BLE Shield name here, max. length 10
    char team[] = "TeamE2";
    ble_set_name(team);
    
    // Init. and start BLE library.
    ble_begin();
    
    // Thirty Minutes
    totalPromptSeconds = 30 * 60;
    
    // Enable serial debug
    Serial.begin(57600);
    timer.SetTimer(totalPromptSeconds);
    Serial.print("Timer Seconds: "); Serial.println(timer.ShowSeconds());
    timer.StartTimer();
    
}

/*********************************/
/*            LOOP               */
/*********************************/

void loop()
{
  timer.Timer();
  // TO DO - UPDATE PHONE WITH NEW LOUDNESS VALUE WHEN VOLUME CHANGED
  
  
  //shouldPlayMelody = digitalRead();
  //buttonPressed = digitalRead(BUTTON_PIN);
  //volumeKnobReading = analogRead(VOLUME_POT_IN);
  if (hasEvent) {
    updateEvent();
  }
  // Default to an unused protocol value
  unsigned char protocolBuffer[2] = { 255, 255 };
  unsigned char outputBuffer[2] = { 0, 0 };
  
  // If data is ready
  if (ble_available())
  {
    // Read the protocol value and its date
    protocolBuffer[0] = ble_read();
    protocolBuffer[1] = ble_read();
    
    Serial.print((int)protocolBuffer[0]);
    Serial.print(",  ");
    Serial.print((int)protocolBuffer[1]);
    
    // CHANGE LIGHT INTENSITY VALUE --- DONE UNLESS WE ADD BACK POTENTIOMETER
    if (protocolBuffer[0] == 0)
    {
      Serial.println("    CHANGE LED INTENSITY");
      ledIntensity = (int)protocolBuffer[1];
      updateBrightness();
    }
    
    // CHANGE SPEAKER VOLUME -- DONE UNLESS WE WANT TO TWEAK VOLUME VALUES (WRITE OUR OWN MAP FN)
    else if (protocolBuffer[0] == 1)
    {
      Serial.println("    CHANGE SPEAKER VOLUME");
      volumeBle255 = (int)protocolBuffer[1];
      volumeBle_Changed = true;
    }
    
    // WE HAVE AN EVENT TO START COUNTING DOWN - DONE
    else if (protocolBuffer[0] == 2)
    {
      Serial.println("    NEW EVENT");
      startEvent();
    }
    
    // TURN SOUND OFF - DONE
    else if (protocolBuffer[0] == 3)
    {
      Serial.println("    TURN OFF SOUND");
      volumeBle255 = 0;
      volumeBle_Changed = true; 
    }
    
    // CHANGE EVENT COUNT TIME - DONE
    else if (protocolBuffer[0] == 4)
    {
     Serial.println("     CHANGE EVENT TIME");
     int minutes = (int)protocolBuffer[1];
     totalPromptSeconds = minutes * 60; 
    }
  }  
  // NOTIFY iOS OF LIGHTING CHANGE ----- NEED TO TEST
  if (lightingKnob_Changed)
  {   
    outputBuffer[0] = 0;
    outputBuffer[1] = lightingKnob255;

    sendProtocol(outputBuffer);
    lightingKnob_Changed = false;
  }
  
  // NOTIFY iOS OF LIGHTING CHANGE ----- NEED TO TEST
  else if (volumeKnob_Changed)
  {
    // Send a signal to change the loudness
    
    outputBuffer[0] = 1;
    outputBuffer[1] = volumeKnob255;
    
    sendProtocol(outputBuffer);
    volumeKnob_Changed = false;
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

void updateLightingKnob255() {
  int lightingKnobReading1024 = analogRead(INTENSITY_POT_IN);
  
  Serial.println(lightingKnobReading1024);
  
  int lightingKnobReading = map(lightingKnobReading1024, 1023, 0, 0, 255);
  if (lightingKnob255 != lightingKnobReading) {
    lightingKnob255 = lightingKnobReading;
    lightingKnob_Changed = true;
  }
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
    for (int thisNote = 0; thisNote < (int)(sizeof(noteDurations)/2); thisNote++) {
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

void updateBrightness() {
  Serial.println(" * I'm updating LED brightness. ");
  lightItUp(timerIterations);
}

void lightItUp(int led_qty) {
  Serial.print(" * I'm lighting up ");
  Serial.print(led_qty);
  Serial.print(" LEDs with intensity value: ");
  Serial.print(ledIntensity);
  Serial.println(".");
  for (int index = 0; index < 6; index++) 
  {
    analogWrite(led_array[index], 0);
  }
  for (int index = 0; index < led_qty; index++)  { 
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

void startEvent () {
  //Serial.println(" * I'm starting a new event. ");
  secondsPerLED = totalPromptSeconds / 6;
  timerIterations = 6;
  
  //Serial.print("Going to wait for "); Serial.println(secondsPerLED);
  
  timer.SetTimer(secondsPerLED);
  lightItUp(timerIterations);

  hasEvent = true;
}

void updateEvent () {
  if (timerIterations != 0) {
    unsigned int cero = 0;
    Serial.println(timer.ShowSeconds());
    
    if (timer.TimeCheck(cero, cero, cero)) {
      //Serial.println("Starting the next timer");
       timerIterations = timerIterations - 1;
       timer.SetTimer(secondsPerLED); 
       if(timerIterations != 0) {
         lightItUp(timerIterations);
       }
       else {
         hasEvent = false;
         playMelody();
       }
     }
  }
  else {
    if (timer.TimeCheck((unsigned int)0, (unsigned int)0, (unsigned int)0)) {
      hasEvent = false;
      playMelody();
    }
  }
}




