void setup() {
  // Укажем, что данная ножка будет использоваться для выводаa
  Serial.begin(115200);
  Serial.println("setup");
}

void loop() {
  static int i = 0;
  Serial.println(i++);
}
