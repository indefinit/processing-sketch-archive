import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 
import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Osc_blobreceive_tester extends PApplet {

/**
 * oscP5parsing by andreas schlegel
 * example shows how to parse incoming osc messages "by hand".
 * it is recommended to take a look at oscP5plug for an
 * alternative and more convenient way to parse messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */





OscP5 oscP5;
NetAddress myRemoteLocation;

//holds the max amount of colors in a strand
ArrayList<Integer> strandCols;

public void setup() {
  size(400,400);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,7770);
  strandCols = new ArrayList<Integer>();
}

public void draw() {
  background(0);
  for (int i = 0; i < 8; ++i) {
      rect(width/2, height/8 * i, height/8, height/8);
    }  
}



public void oscEvent(OscMessage theOscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */
  
  // if(theOscMessage.checkAddrPattern("/dmx/universe/38")==true) {
  //    processEvent(theOscMessage);
  // } 
  
  if(theOscMessage.checkAddrPattern("/dmx/universe/39")==true) {
     processEvent(theOscMessage); 
  } 
  //  println("### received an osc message. with address pattern "+theOscMessage.addrPattern());
}

public void processEvent(OscMessage theOscMessage){

  /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("b")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */  
      byte[] data = theOscMessage.get(0).blobValue();
      
//      print("### received an osc message /test with typetag b.");
      
//      println(" byte array size: "+ data.length);
     for(int i = 0; i < data.length; i+=3){
      if (PApplet.parseInt(data[i]) > 0){
        background(255);
        println(i + ":", PApplet.parseInt(data[i]), i+1 + ":", PApplet.parseInt(data[i+1]), i+2 + ":", PApplet.parseInt(data[i+2]));
      }      
     }
      return;
    }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "Osc_blobreceive_tester" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
