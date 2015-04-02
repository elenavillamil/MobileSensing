//int melody[] = {
//	NOTE_C2, NOTE_F3, NOTE_C3, NOTE_A2,
//	NOTE_C3, NOTE_F3, NOTE_C3,
//	NOTE_C3, NOTE_F3, NOTE_C3, NOTE_F3,
//	NOTE_AS3, NOTE_G3, NOTE_F3, NOTE_E3, NOTE_D3, NOTE_CS3,
//	NOTE_C3, NOTE_F3, NOTE_C3, NOTE_A2, // the same again
//	NOTE_C3, NOTE_F3, NOTE_C3,
//	NOTE_AS3, 0, NOTE_G3, NOTE_F3,
//	NOTE_E3, NOTE_D3, NOTE_CS3, NOTE_C3};
// 
//// note durations: 4 = quarter note, 8 = eighth note, etc.:
//int noteDurations[] = {
//	4,    4,    4,    4,
//	4,    4,          2,
//	4,    4,    4,    4,
//	3,   8, 8, 8, 8, 8,
//	4,    4,    4,    4, // the same again
//	4,    4,          2,
//	4, 8, 8,    4,    4,
//	4,    4,    4,    4,
//	0};
//
//
//void playMelody(){
//
//  // iterate over the notes of the melody:
//  for (int thisNote = 0; noteDurations[thisNote] != 0; thisNote++) {
// 
//    // to calculate the note duration, take one second 
//    // divided by the note type.
//    //e.g. quarter note = 1000 / 4, eighth note = 1000/8, etc.
//    int noteDuration = 2000/noteDurations[thisNote];
//    tone(8, melody[thisNote],noteDuration * 0.9);
// 
//    // to distinguish the notes, set a minimum time between them.
//    // the note's duration + 30% seems to work well:
//    //int pauseBetweenNotes = noteDuration * 1.30;
//    //delay(pauseBetweenNotes);
//	delay(noteDuration);
//
//  }
