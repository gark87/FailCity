/* vim: set filetype=cpp: */
/**
 * This is main class for FailCity project
 */

#include "options.h"
void setup() {
  // Укажем, что данная ножка будет использоваться для выводаa
  Serial.begin(115200);
  LOG("setup");
}

void loop() {
  static int i = 0;
  LOG(i++);
}
