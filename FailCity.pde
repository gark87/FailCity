/* vim: set filetype=cpp: */
/**
 * This is main class for FailCity project
 */

#include "options.h"
#include "flat.h"

long previousMillis = 0; 
const long interval = 1000;
const int highPin = 13;
const Flat flats[] = { Flat(2), Flat(3) };

void setup() {
  Serial.begin(115200);
  LOG("setup");
  pinMode(highPin, OUTPUT);
  digitalWrite(highPin, HIGH);

}

void loop() {
  static int i = 0;
  if (millis() - previousMillis < interval)
    return;
  previousMillis = millis();
  LOG(i++);
  for (int j = 0; j < 2; j++) {
    Flat fl = flats[j];
    if (i % (j+2) == 0) {
      fl.ok();
    } else {
      fl.fail();
    }
  }
}
