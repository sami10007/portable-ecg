
#define ANALOG_IN 0

/* USART TOKENS */
#define USART_TOKEN_ECG_DATA_TO_DRAW      0xFF
#define USART_TOKEN_HEART_BEAT_TO_BEEP    0xFE

int led = 13;

void setup() {
  Serial.begin(19200);
  //analogReference(INTERNAL);
  pinMode(led, OUTPUT); 
  digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(1000);               // wait for a second
  digitalWrite(led, LOW);    // turn the LED off by making the voltage LOW
  delay(1000); 
}

void loop() {
  int val = analogRead(ANALOG_IN);
  Serial.write(USART_TOKEN_ECG_DATA_TO_DRAW);
  // Send MSB Byte
  Serial.write((val >> 8) & ~(0xFF00));
  // Send LSB Byte
  Serial.write(val & ~(0xFF00));
}

/*
  SerialEvent occurs whenever a new data comes in the
 hardware serial RX.  This routine is run between each
 time loop() runs, so using delay inside loop can delay
 response.  Multiple bytes of data may be available.
 */
void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read(); 
    switch(inChar) {
      case USART_TOKEN_HEART_BEAT_TO_BEEP:
        // BEEP and TOGGLE LED!
        beep(BEEP_SIMPLE);
        digitalWrite(led, HIGH);
        delay(500);
        digitalWrite(led, LOW);
        break;
      default:
        break;
    }
  }
}
