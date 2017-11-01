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
int sendPort = 4000;
int receivePort = 3000;

void setup() {
  size(400,400);
  frameRate(4);
  /* start oscP5, listening on port 3000 */
  oscP5 = new OscP5(this, receivePort);
  myRemoteLocation = new NetAddress("localhost", sendPort);
}

void draw() {
  background(0);
  colorMode(HSB, 255,255,100);
  color myCol = color( random(0, 255), 200, 100);
  
  //turn the color array into bytes, but first convert r,g,b to int vals
  byte[] colorBytes = colorsToBytes(new int[]{(int) hue(myCol), (int) saturation(myCol), (int) brightness(myCol)});

  //do something with our byte array and send it over OSC
  // params: OSC address, bye array
  OscMessage msg = buildMessage("/awesome/", colorBytes);
  
  oscP5.send(msg, myRemoteLocation); //send osc message to myRemoteLocation
  rectMode(CENTER);
  translate(width/2,height/2);
  fill(myCol);
  rect(0,0,200,200);
}

// //////////////////////////////////////////
// //// UTILITY FUNCTIONS
// /////////////////////////////////////////
// public byte[] toByteArray(ArrayList<Byte> in) {
//   final int n = in.size();
//   byte ret[] = new byte[n];
//   for (int i = 0; i < n; i++) {
//       ret[i] = in.get(i);
//   }
//   return ret;
// }

/**
 * [colorToBytes description]
 * @param  {[type]} int[] col           [description]
 * @return {[type]}       r,g,b
 */
public byte[] colorsToBytes(int[] col){
  byte[] bytes = { byte(col[0]), byte(col[1]), byte(col[2]) };
  return bytes;
}

/**
   * Builds an osc message for functional-style use
   * @param  {[type]} String messAddress   OSC message address; eg. "/awesome/party" 
   * @param  {[type]} byte[]  vals       array of byte values to bundle in address
   * @return {[type]}        OscMessage    You can use this to pass into the sendOsc() method.
   */
  public OscMessage buildMessage(String messAddress, byte[] vals){
    OscMessage oscMessage = new OscMessage(messAddress);
    oscMessage.add(vals); 
    return oscMessage;
  }
