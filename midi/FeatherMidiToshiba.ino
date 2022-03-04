/*
 * Copyright (C) 2022 Humberto Martínez Barberá
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
 
 #include <MIDI.h>

/*---------------------------------------------
    Board and options configuration 
 ----------------------------------------------*/
// Uncomment the line appropiate for you board
//#define M0_LORA     1       // Adafruit Feather M0 LORA
#define M0_LOGGER   1       // Adafruit Feather M0 logger
//#define SERIAL_DUMP 1

/*---------------------------------------------
    MIDI Initialisation 
 ----------------------------------------------*/

MIDI_CREATE_DEFAULT_INSTANCE();

/*---------------------------------------------
    Note definition
 ----------------------------------------------*/
String note[] = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B",};

/*---------------------------------------------
    Matrix keyboard arrangement
    Toshiba HX-MU901
 ----------------------------------------------*/
#define T_ENTER               1
#define T_STOP                2
#define T_RED                 3
#define T_RED_YELLOW          4
#define T_YELLOW              5
#define T_YELLOW_GREEN        6
#define T_GREEN               7
#define T_GREEN_BLUE          8
#define T_BLUE                9
#define T_BLUE_PURPLE        10
#define T_PURPLE             11

byte out[] = { A2, SDA, A3, SCL, A4, 13, A5, SCK, A0, A1 };
const int outCount = sizeof(out)/sizeof(out[0]);
 
byte in[] = { 12, 5, 9, MISO, 10, MOSI, 6, 11 };
const int inCount = sizeof(in)/sizeof(in[0]);
 
byte keys[inCount][outCount];
bool chan[inCount][outCount];
byte notes[][outCount] = {  { 00, 36, 37, 38, 39, 40, 41, 42,  6, 11 },
                            { 00, 00, 43, 44, 45, 46, 47, 48,  3,  7 },
                            { 00, 00, 49, 50, 51, 52, 53, 54,  3,  8 },
                            { 00, 00, 55, 56, 57, 58, 59, 60,  4,  9 },
                            { 00, 00, 61, 62, 63, 64, 65, 66,  5, 10 },
                            { 00, 00, 67, 68, 69, 70, 71, 72,  6, 11 },
                            { 00, 00, 73, 74, 75, 76, 77, 78,  2,  0 },
                            { 00, 00, 79, 80, 81, 82, 83, 84,  1,  0 } };

/*---------------------------------------------
    Program state
 ----------------------------------------------*/
int count = 0;
int program = 0;

// -----------------------------------------------------------------------------

void readMatrix() 
{
  byte    val;
  
  for (int j=0; j < outCount; j++) 
  {
    byte col = out[j];
    pinMode(col, OUTPUT);
    digitalWrite(col, LOW);

    for (int i=0; i < inCount; i++) 
    {
        byte row = in[i]; 
        pinMode(row, INPUT_PULLUP);
        delayMicroseconds(50);    // Stabilize lines before reading
         
        val = digitalRead(row);
        chan[i][j] = (keys[i][j] != val);
        keys[i][j] = val;
        
        pinMode(row, INPUT);
    }
    
    pinMode(col, INPUT);
  }
}

void sendNotes() 
{
  // Send note information
 for (int j=0; j < outCount-2; j++) 
    for (int i=0; i < inCount; i++) 
        if (chan[i][j])
          switch (keys[i][j])
          {
            case 0:  
              MIDI.sendNoteOn(notes[j][i], 127, 1); 
              count++; 
#ifdef SERIAL_DUMP
              printNotes ("ON", i, j); 
#endif
              break;
            case 1:  
              MIDI.sendNoteOff(notes[j][i], 127, 1); 
              count--; 
#ifdef SERIAL_DUMP
              printNotes ("OFF", i, j); 
#endif
              break;
          }

  // Send additional MIDI commands
  for (int j=outCount-2; j < outCount; j++) 
    for (int i=0; i < inCount; i++) 
        if (chan[i][j] && (keys[i][j]==0))
          switch (notes[i][j])
          {
            case T_ENTER:
              break;
            case T_STOP:
              break;
            case T_RED:
              break;
            case T_RED_YELLOW:
              break;
            case T_YELLOW:
              program -= 5;
              if (program < 0)
                program = 0;
              MIDI.sendProgramChange(program, 1);
              break;
            case T_YELLOW_GREEN:
              break;
            case T_GREEN:
              program --;
              if (program < 0)
                program = 0;
              MIDI.sendProgramChange(program, 1);
              break;
            case T_GREEN_BLUE:
              break;
            case T_BLUE:
              program ++;
              if (program > 127)
                program = 127;
              MIDI.sendProgramChange(program, 1);
              break;
            case T_BLUE_PURPLE:
              break;
            case T_PURPLE:
              program += 5;
              if (program > 127)
                program = 127;
              MIDI.sendProgramChange(program, 1);
              break;

            default:
              break;
          }

#ifdef M0_LOGGER
  digitalWrite(8, (count > 0 ? HIGH : LOW));
#endif
}

void printNotes(String str, int i, int j)
{
  Serial.print(str + " in="); 
  Serial.print(i); 
  Serial.print(" out="); 
  Serial.print(j); 
  Serial.print(" ==>"); 
  Serial.print(notes[j][i]);
  Serial.print(" (");
  Serial.print(note[notes[j][i]%12]+(notes[j][i]/12-1));
  Serial.println(")");
}

// -----------------------------------------------------------------------------

void setup()
{
  Serial.begin (115200);
  
  MIDI.begin(MIDI_CHANNEL_OMNI);

  // Configure status LED
  pinMode(8, OUTPUT);
#ifdef M0_LORA
  digitalWrite(8, HIGH);  // Hack for LORA
#endif

  // Configure keyboard pins
  for(int x=0; x<outCount; x++) 
    pinMode(out[x], INPUT);
  for (int x=0; x<inCount; x++) 
    pinMode(in[x], INPUT_PULLUP);
  
 for (int j=0; j < outCount; j++) 
     for (int i=0; i < inCount; i++) 
         keys[i][j] = 1;
}

void loop()
{
  readMatrix ();
  sendNotes ();
}
