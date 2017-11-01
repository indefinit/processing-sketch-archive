
import ddf.minim.*;
import ddf.minim.analysis.*;

OPC opc;
PImage dot;

float dx, dy, dz;

Minim minim;

AudioInput in;
FFT fftLog;

AudioRecorder recorder;
float lastTotalVolume;

void setup()
{
  size(640, 360);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO);
  // create a recorder that will record from the input to the filename specified
  // the file will be located in the sketch's root folder.
  recorder = minim.createRecorder(in, "myrecording.wav");
  
  // create an FFT object for calculating logarithmically spaced averages
  fftLog = new FFT( in.bufferSize(), in.sampleRate() );
    // calculate averages based on a miminum octave width of 22 Hz
  // split each octave into three bands
  // this should result in 60 averages
  fftLog.logAverages( 22, 6 ); 
  
  // Load a sample image
  dot = loadImage("dot.png");

  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  // Map an 8x8 grid of LEDs to the center of the window
  opc.ledGrid8x8(0, width/2, height/2, height / 12.0, 0, false);
}

void draw()
{
  background(0);
  float centerFrequency = 0;
  fftLog.forward(in.left);
  
  float hx = 0, hy = 0, hz = 0;
  float dotSize = 0.0;
  
  float totalVolume = 0.0;
  
  // draw the waveforms so we can see what we are monitoring
  for(int i = 0; i < fftLog.avgSize(); i++){
    centerFrequency    = fftLog.getAverageCenterFrequency(i);
    totalVolume += fftLog.getAvg(i);
//    map(fftLog.getAvg(i), 0, 1, 0, 100);
    
  }
  
  
//  for(int i = 0; i < in.bufferSize() - 1; i++)
//  {
//    totalVolume += in.left.get(i);
//    
//  }
//    totalVolume /= in.bufferSize();
    //println(totalVolume);
    dotSize = map(totalVolume, 0.0,255.0,100.0,450.0);
//  if ( recorder.isRecording() )
//  {
//    text("Currently recording...", 5, 15);
//  }
//  else
//  {
//    text("Not recording.", 5, 15);
//  }
tint(0,206,180);
//  tint(7,242,170);
  image(dot, mouseX - dotSize/2, mouseY - dotSize/2, dotSize, dotSize);
}

