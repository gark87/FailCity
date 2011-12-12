#include "WProgram.h"
#include "flat.h"

Flat::Flat(int okPin, int failPin): okPin(okPin), failPin(failPin) {
  pinMode(okPin, OUTPUT);
  pinMode(failPin, OUTPUT);
}

Flat::~Flat() {}

void Flat::ok() {
  digitalWrite(okPin, HIGH);
}

void Flat::fail() {
  digitalWrite(okPin, LOW);
}
