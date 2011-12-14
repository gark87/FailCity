#include "WProgram.h"
#include "flat.h"

Flat::Flat(int pin): pin(pin) {
  pinMode(pin, OUTPUT);
}

Flat::~Flat() {}

void Flat::ok() {
  digitalWrite(pin, HIGH);
}

void Flat::fail() {
  digitalWrite(pin, LOW);
}
