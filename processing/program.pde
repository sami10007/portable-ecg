import processing.serial.*;

#define USART_TOKEN_ECG_DATA_TO_DRAW      0xFF
#define USART_TOKEN_HEART_BEAT_TO_BEEP    0xFE

Serial port;      // Create object from Serial class
int val;              // Data received from the serial port
float val2;
int cnt;
int hht;
int wm1;
int[] values;
PFont f;
PGraphics buffer;

/* BPM */
int lastValue;
unsigned long lastPeakTime; 
int bpm;

void setup() 
{
  size(800, 600);                                  //currently set to 5 sec
  // Open the port that the board is connected to and use the same speed (19200 bps)
  port = new Serial(this, Serial.list()[0], 19200);
  values = new int[width];  
  hht = 300;     // Sets display DC offset; must adjust if gain is changed# 
  wm1= width-1; 
  cnt = 1;     
  frameRate(180);                                //read/draw 180 samples/sec
  for (int s = 0; s < width ; s++) {             //set initial values to midrange
    values[s] = 0;
  }
  
  f = createFont("Arial",16,true); // Arial, 16 point, anti-aliasing on
  
  buffer = createGraphics(200, 50);
}

void draw() {
  if(cnt == 1) {
    background(0);

    stroke(60);
    for (int d = 0; d < width-1; d = d + 100) {   //**draw lines for seconds
      line(d,0,d,600);
    }
    for (int d = 0; d < width-1; d = d + 100) {   //**draw lines for amplitude
      line(0,d,800,d);
    }
  }
  
  cnt++;                                                 //increment the count
  if (cnt > wm1) {                                //back to beginning
    cnt = 1;
  }
  
  //stroke(255,255,0);
  //line(cnt,0,cnt,600);                      //draw the leading edge line
  
  while (port.available() >= 3) {                  //read the latest value
    if (port.read() == 0xff) {
      val = (port.read() << 8) | (port.read());
    }
  }
  
  //values[cnt] = val;                              //put it in the array#
  //values[cnt] = round(sin(cnt * PI / 100) * 100); //put it in the array#
  
  int x = 20 * height;
  int y = x / 2;
  
  val2 = val;
  val2 = ceil((val2 / 1024) * height - height / 2);
  values[cnt] = (int)val2;  //put it in the array#
  
  buffer.beginDraw();
  buffer.background(0);
  buffer.textFont(f,14);
  buffer.text("val = " + val2,20,20);
  buffer.endDraw();
  image(buffer, 0, 0); 
  
  stroke(255,0,0);
  if(cnt > 1) {
    line(cnt-1, hht - values[cnt-1], cnt, hht - values[cnt]);    //increment the data line
  }
  //for (int x = 2; x < wm1; x++) {
  //  if(x <= cnt) {
  //    line(x-1, hht - values[x-1], x, hht - values[x]);    //increment the data line
  //  }
  //}
}

void serialEvent(Serial p) {
  if(p.avaiable()) {
    switch(p.read()) {
      case USART_TOKEN_ECG_DATA_TO_DRAW:
        /*
          Vai ter duas variaveis: LastValue and LastPeakTime
          Para cada novo valor obtido, ele sera comparado com o LastValue para checar se o mesmo é 100% maior que o LastValue.
          Caso seja, isso significa que o valor atual é um pico, e o tempo deve ser setado no LastPeakTime(caso seja o primeiro pico)
          ou deve pegar o tempo e comparar com o LastPeakTime para obter o BPM, subtraindo os tempos e dividindo por 60000(?)
        */
        int value = (p.read() << 8) & ~(0x00FF);
        value |= (p.read() & ~(0xFF00));
        
        bpm = calculateBPM(value);
        break;
      default:
        break;
    }
  }
}

int calculateBPM(int value) {
  int ret = 0;
  
  if(lastValue == 0) {
    lastValue = value;
  } else {
    // Peak detection
    if(value >= 2*lastValue) {
      if(lastPeakTime == 0) {
        lastPeakTime = millis();
        sendPeakSignalToArduino();
      } else {
        unsigned long actualPeakTime = millis();
        unsigned long peakRate = actualPeakTime - lastPeakTime;
        
        ret = (int)(60000/peakRate);
      }
    }
  }
  
  return ret;
} 

void sendPeakSignalToArduino() {
  p.write(USART_TOKEN_HEART_BEAT_TO_BEEP);
}
