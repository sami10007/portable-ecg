#define ANALOG_IN 0

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
  Serial.write(0xff);
  Serial.write((val >> 8) & 0xff);
  Serial.write(val & 0xff);
}
