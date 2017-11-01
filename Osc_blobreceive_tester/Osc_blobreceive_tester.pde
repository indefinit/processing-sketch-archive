/**
 * oscP5parsing by andreas schlegel
 * example shows how to parse incoming osc messages "by hand".
 * it is recommended to take a look at oscP5plug for an
 * alternative and more convenient way to parse messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */

import oscP5.*;
import netP5.*;
import java.util.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

//holds the max amount of colors in a strand
ArrayList<Integer> strandCols;

void setup() {
  size(400,400);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,7770);
  strandCols = new ArrayList<Integer>();
}

void draw() {
  background(0);
  for (int i = 0; i < 8; ++i) {
      rect(width/2, height/8 * i, height/8, height/8);
    }  
}



void oscEvent(OscMessage theOscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */
  
  // if(theOscMessage.checkAddrPattern("/dmx/universe/38")==true) {
  //    processEvent(theOscMessage);
  // } 
  
  if(theOscMessage.checkAddrPattern("/dmx/universe/39")==true) {
     processEvent(theOscMessage); 
  } 
  //  println("### received an osc message. with address pattern "+theOscMessage.addrPattern());
}

void processEvent(OscMessage theOscMessage){

  /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("b")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */  
      byte[] data = theOscMessage.get(0).blobValue();
      
//      print("### received an osc message /test with typetag b.");
      
//      println(" byte array size: "+ data.length);
     for(int i = 0; i < data.length; i+=3){
      if (int(data[i]) > 0){
        background(255);
        println(i + ":", int(data[i]), i+1 + ":", int(data[i+1]), i+2 + ":", int(data[i+2]));
      }      
     }
      return;
    }
}
