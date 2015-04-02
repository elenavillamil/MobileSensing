// ---------------------------------------------------------------------------
// Connect your piezo buzzer (without internal oscillator) or speaker to these pins:
//   Pins  9 & 10 - ATmega328, ATmega128, ATmega640, ATmega8, Uno, Leonardo, etc.
//   Pins 11 & 12 - ATmega2560/2561, ATmega1280/1281, Mega
//   Pins 12 & 13 - ATmega1284P, ATmega644
//   Pins 14 & 15 - Teensy 2.0
//   Pins 25 & 26 - Teensy++ 2.0
// Be sure to include an inline 100 ohm resistor on one pin as you normally do when connecting a piezo or speaker.
// ---------------------------------------------------------------------------

#include "pitches.h"
#include <toneAC.h>

#define SPEAKER_RED       10
#define SPEAKER_BLACK      9

#define LED_DKGRN     A4
#define LED_LTGRN     A5
#define LED_BLUE      A3
#define LED_YELLOW    A2
#define LED_ORANGE    5
#define LED_RED       6

#define LEDS_2_LITE   A0
#define INTENSITY     A1
#define MUSIC_SIGNAL  13
#define BUTTON_PIN    12

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
  
int shouldPlayMelody;
int leds_2_light;
int intensity;
int led_array[] = {LED_RED, LED_ORANGE, LED_YELLOW, LED_BLUE, LED_LTGRN, LED_DKGRN};
void playMelody();
void lightItUp();

//DEBOUNCE -- MODIFIED FROM DEBOUNCE EXAMPLE
int musicState;       // the current state of the output pin
int buttonState;      // the current reading from the input pin
int lastButtonState;  // the previous reading from the input pin

// the following variables are long's because the time, measured in miliseconds,
// will quickly become a bigger number than can be stored in an int.
long lastDebounceTime;  // the last time the output pin was toggled
long debounceDelay;    // the debounce time; increase if the output flickers


void setup() {
  
    Serial.begin(9600);
    
    // SETUP SPEAKER I/O PINS
    pinMode(SPEAKER_RED, OUTPUT);
    pinMode(SPEAKER_BLACK, OUTPUT);
    pinMode(MUSIC_SIGNAL, INPUT_PULLUP);
    analogWrite(SPEAKER_RED, 0);
    analogWrite(SPEAKER_BLACK, 0);
    pinMode(MUSIC_SIGNAL, HIGH);
    
    // SETUP DEBOUNCE
    musicState = HIGH;       // the current state of the output pin
    buttonState = LOW;       // the current reading from the input pin
    lastButtonState = LOW;
    lastDebounceTime = 0; 
    debounceDelay = 50; 
    shouldPlayMelody = HIGH;
    buttonState = HIGH;
    
    // LEDS
    pinMode(LED_DKGRN, OUTPUT);
    pinMode(LED_LTGRN, OUTPUT);
    pinMode(LED_BLUE, OUTPUT);
    pinMode(LED_YELLOW, OUTPUT);
    pinMode(LED_ORANGE, OUTPUT);
    pinMode(LED_RED, OUTPUT);
    
    pinMode(LEDS_2_LITE, INPUT);
    pinMode(INTENSITY, INPUT);
    
    analogWrite(LED_DKGRN, 0);
    analogWrite(LED_LTGRN, 0);
    analogWrite(LED_BLUE, 0);
    analogWrite(LED_YELLOW, 0);
    analogWrite(LED_ORANGE, 0);
    analogWrite(LED_RED, 0);
    
    analogWrite(LEDS_2_LITE, 0);
    analogWrite(INTENSITY, 0);
    

    leds_2_light = 0;
    intensity = 0;
    attachInterrupt(0, silence, HIGH);
    shouldPlayMelody = LOW;
} 

void loop() {
  //shouldPlayMelody = digitalRead();
  int buttonPressed = digitalRead(BUTTON_PIN);
  

  
  
  
  if (shouldPlayMelody == LOW) {
      playMelody();
  }
}

void playMelody() {
  
    toneAC(); // Turn off toneAC, can also use noToneAC().

    delay(1000); // Wait a second.

    for (int thisNote = 0; thisNote < (sizeof(noteDurations)/2); thisNote++) {
      int noteDuration = 1000/noteDurations[thisNote];
      toneAC(melody[thisNote], 10, noteDuration, true); // Play thisNote at full volume for noteDuration in the background.
      delay(noteDuration * 4 / 3); // Wait while the tone plays in the background, plus another 33% delay between notes.
      noToneAC();
    }
}

void lightItUp(int led_qty) {
  
  //for (int index = 0; index < (sizeof(led_array)/sizeof(int)); index++)
  for (int index = 0; index < led_qty; index++) 
  {
    analogWrite(led_array[index], intensity);
    delay(1000);              // wait for a second
    //analogWrite(leds[index], ledOff);    // turn the LED off by making the voltage LOW
    //delay(1000);     // wait for a second
  }
  
}
