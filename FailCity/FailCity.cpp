/* vim: set filetype=cpp: */
/**
 * This is main class for FailCity project
 */

#include "WProgram.h"
#include "options.h"
#include "flat.h"
#include "connect.h"

long previousMillis = 0; 
const long interval = 1000;
const int highPin = 13;
const Flat flats[] = { Flat(2), Flat(3), Flat(4) };

void setup() {
  Serial.begin(115200);
  LOG("setup");
  pinMode(highPin, OUTPUT);
  digitalWrite(highPin, HIGH);
  connect_setup();
}

void loop() {
  connect_loop();
}
