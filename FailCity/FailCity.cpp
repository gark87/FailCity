/* vim: set filetype=cpp: */
/**
 * This is main class for FailCity project
 */

#include "WProgram.h"
#include "options.h"
#include "flat.h"
#include "config.h"
#include "Network.h"
#include "html.h"

long previousMillis = 0; 
const long interval = 1000;
const int highPin = 13;
const Flat flats[] = { Flat(2), Flat(3), Flat(4) };
uint8_t macAddr[] = MAC;

void setup() {
  Serial.begin(115200);
  LOG("setup");
  pinMode(highPin, OUTPUT);
  digitalWrite(highPin, HIGH);
  Network.setMacAddr(macAddr);
}

int printOnTag(Client *c, const char * const str) {
  LOG(str);
  return 0;
}

void loop() {
  Client client(Network.getIpAddr(TEAMCITY_SERVER), 80);
  if (client.connect()) {
    LOG("connected");
    client.println("GET /login.html HTTP/1.0");
    client.println();
  } else {
    LOG("connection failed");
  }
  parseHTML(&client, &printOnTag);
  LOG("disconnecting.");
  client.stop();
  for(;;)
    ;
}
