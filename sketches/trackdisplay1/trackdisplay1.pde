/*
 
*/

void setup() {
    // Set up the built-in LED pin as an output:
    pinMode(BOARD_LED_PIN, OUTPUT);
    SerialUSB.begin();
    Serial3.begin(9600);
    delay(500);
    Serial3.print("\376\001....Waiting....");
}

void loop() {
  char ch;
  if (SerialUSB.available()){
    ch=SerialUSB.read();
    Serial3.print(ch);
  }
}
