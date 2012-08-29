/*------------------------------------------------KitchenTrackDisplay
 * this is a quick one. All it does is clear the screen on the 
 * serial lcd and then send all characters recieved by the usb port
 * to the display. (currently a sparkfun serial lcd)
 * 
 * (c) 2012 don@suspectdevices.com
 ------------------------------------------------------------------*/

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