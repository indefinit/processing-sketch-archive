import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import peasy.test.*; 
import peasy.org.apache.commons.math.*; 
import peasy.*; 
import peasy.org.apache.commons.math.geometry.*; 
import processing.serial.*; 
import java.awt.Color; 
import oscP5.*; 
import netP5.*; 
import colorLib.calculation.*; 
import colorLib.*; 
import colorLib.webServices.*; 
import java.util.Observer; 
import java.util.Observable; 
import processing.serial.*; 
import java.util.Arrays; 
import processing.core.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class sketch_3DLEDstructure extends PApplet {

/**
 * 3D LED Sculpture Animation Engine
 * @authors Gabe Liberti and Kevin Siwoff
 * @version 4.2.3
 * @date 1-15-15
 * @description Generates and sequences patterns and colors for 3D LED systems
 * @TODOs: 
 * 1. Finish universe mapping according to Dave's diagram instead of auto assignment (kevin)
 */






OscManager oscManager;
GammaCorrection gamma;
Parameters controlBoxParams;

int ribLength = 28;
int strandWidth = 5;
int[] pcbHeights =
  {1,1,2,3,3,
  4,3,3,4,6,
  7,6,5,4,4,
  6,7,8,8,7,
  6,5,4,5,3,
  2,1,1};

int spacing = 50;
int boxSize = 25;

int[][][] addressIndexes;

PeasyCam cam;

//////////////////////////////
/// SCENES
//////////////////////////////
Scenes scenes; //reference to all of our scenes
Scene currentScene;
Scene previousScene;
int sceneIndex = 0;
String sceneName;

//////////////////////////////
/// SERIAL globals
//////////////////////////////
boolean serialInitialized;
Serial myPort;  // Create object from Serial class
char HEADER = 'S';    // character to identify the start of a message
short LF = 10;        // ASCII linefeed

public void setup (){
  size(1280,800,P3D);

  colorMode(HSB,360,100,100);//max h:160, max s:100, max b:100
  
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(600);
  cam.setMaximumDistance(2600);

  //initialize our sculpture
  //note: we only need to do this once in our main sketch
  SculptureManager.getInstance().initSculpture(ribLength , strandWidth, pcbHeights);
  
  //@TODO fix this
  // addressIndexes = sculpture.addressIndexes;
 
  //@params: host, sendPort
  oscManager = new OscManager("localhost", 7770);
  
  gamma = new GammaCorrection();//used in comms only!

  for (String portName : Serial.list()) {
    if(portName.matches("(.*)tty.usb(.*)")){
      myPort = new Serial(this, portName, 9600);
      serialInitialized = true;                    
    }  
  }

  
  //create our parameters object.
  //in this case we are creating 4 individual slider params
  //to change this number add more/less zeros to the array literal
  controlBoxParams = new Parameters(new int[]{0,0,0,0});

  scenes = new Scenes(controlBoxParams);
  loadScene(2);
}

public void draw(){
  colorMode(HSB,360,100,100);
  background(105);
  
  //@TODO debug
  currentScene.updateScene(second());
  
  //Send values over OSC
  sendOsc();

  //draw our graphics
  renderSculpture();

  frame.setTitle(PApplet.parseInt(frameRate) + " fps");
  
}

/**
 * Loads current scene
 * @param  {int} index         sceneIndex from 0-8
 * @return {void}
 */
public void loadScene( int index )
{
    boolean doAnimate = (index != sceneIndex);

    float cooldownTime = ( doAnimate ) ? 0.25f : 0;
    
    if( index < 0 ) { index = scenes.getTotalSceneCount() - 1; }
    index %= scenes.getTotalSceneCount();
    
    sceneIndex = index;
    currentScene = scenes.getScene(sceneIndex);

    //@TODO need to implement this method in every Scene superclass
    sceneName = currentScene.getSceneName();
  
    currentScene.setup();
    println("loaded " + sceneName);
    // if animate current on.
    if( doAnimate ) {
      //@TODO figure out scene crossfade        
    }
}

/**
 * render our fixtures to the screen
 */
public void renderSculpture(){
  pushMatrix();
    //center our sculpture before drawing our fixtures
    translate(( -ribLength/2 ) * spacing, ( -strandWidth/2 ) * spacing, 0);
    
    for (int ribIndex = 0; ribIndex < ribLength; ++ribIndex) {
      for (int strandIndex = 0; strandIndex < strandWidth; ++strandIndex) {
        for (int pcbIndex = 0; pcbIndex < pcbHeights[ribIndex]; ++pcbIndex) {
     
          int fixtureColor = color(SculptureManager.getInstance().getFixtureColor(ribIndex , strandIndex, pcbIndex));
          pushMatrix();
            noStroke();
            fill(fixtureColor);
            translate(ribIndex*spacing, strandIndex*spacing, pcbIndex*spacing);
            box(boxSize);
          popMatrix();
        }
      }
    }
  popMatrix();
}


public void sendOsc(){
  int maxFixtures;
  int byteCounter = 0;
  //important that we maintain this color scale
  colorMode(HSB,360,100,100);
  //loop through all of our lights and batch message over OSC
  
  for( int ribIndex = 0 ; ribIndex < ribLength ; ribIndex++){
    for( int strandIndex = 0 ; strandIndex < strandWidth ; strandIndex++){
      for( int pcbIndex = 0 ; pcbIndex < pcbHeights[ribIndex] ; pcbIndex++){
        //println(byteCounter);
        //if our buffers are totally filled with all pixels
        if(byteCounter == 594){
          buildMessages();
          byteCounter = 0;
        }

        int fixtureColor = color(SculptureManager.getInstance().getFixtureColor(ribIndex , strandIndex, pcbIndex)); 
        int[] gammaCorrected = gamma.getGammaVals(hue(fixtureColor),
        saturation(fixtureColor),
        brightness(fixtureColor), true); //hsv mode
        
        //turn that color array into bytes
        byte[] colorBytes = colorsToBytes(gammaCorrected);
        
        /*
        Universe 1 = R1 - R6
        Universe 2 = R7 - R10
        Universe 3 = R11 - R13
        Universe 4 = R14 - R16
        Universe 5 = R17 - R18
        Universe 6 = R19 - R20
        Universe 7 = R21 - R23
        Universe 8 = R24 - R28
         */
        //@TODO: this is the brute force method.  could probably be optimized
        //with a better data structure
        if(ribIndex+1 <= 6) {
          //add the byte array to the osc color buffer
          oscManager.addColorBytes(0, colorBytes);

          // if (oscManager.getByteBufferSize() % 210 == 0) {
          //   buildMessage(32);
          // }
        }
        else if(ribIndex+1 >=7 && ribIndex+1 <=10) {

          //add the byte array to the osc color buffer
          oscManager.addColorBytes(1, colorBytes);


          // if (oscManager.getByteBufferSize() % 240 == 0) {
          //   buildMessage(33);
          // }
        }
        else if(ribIndex+1 >=11 && ribIndex+1 <=13) {
          //add the byte array to the osc color buffer
        oscManager.addColorBytes(2, colorBytes);   
          // if (oscManager.getByteBufferSize() % 270 == 0) {
          //  buildMessage(34);
          // }
        }
        else if(ribIndex+1 >=14 && ribIndex+1 <=16) {
          //add the byte array to the osc color buffer
        oscManager.addColorBytes(3, colorBytes);
          // if (oscManager.getByteBufferSize() % 210 == 0) {
          //  buildMessage(35);
          // }
        }
        else if(ribIndex+1 >= 17 && ribIndex+1 <=18) {
          //add the byte array to the osc color buffer
        oscManager.addColorBytes(4, colorBytes);
          // if(oscManager.getByteBufferSize() % 225 == 0){
          //   buildMessage(36);
          // }
        }
        else if(ribIndex+1 >= 19 && ribIndex+1 <=20) {
          //add the byte array to the osc color buffer
        oscManager.addColorBytes(5, colorBytes);
          // if (oscManager.getByteBufferSize() % 225 == 0) {
          //  buildMessage(37);
          // }
        } 
        else if(ribIndex+1 >= 21 && ribIndex+1 <= 23) {
          //add the byte array to the osc color buffer
        oscManager.addColorBytes(6, colorBytes);
          // if (oscManager.getByteBufferSize() % 225 == 0) {
          //  buildMessage(38);
          // }
        }
        else if(ribIndex+1 >= 24) {
          //add the byte array to the osc color buffer
        oscManager.addColorBytes(7, colorBytes);
          // if (oscManager.getByteBufferSize() % 180 == 0) {
          //   buildMessage(39);
          // }
        }
        byteCounter++; //increment the fixture counter;
      }
    }
  }
}

public void buildMessages(){

  for(int i = 0; i < oscManager.byteBuffers.size(); i++){
    //@TODO hardcoding universe could be problematic
    String addr = "/dmx/universe/" + (32+i);
    OscMessage msg = oscManager.buildMessage(addr, toByteArray(oscManager.getByteBuffer(i)));
    //println("sending buffer at size: " + oscManager.getByteBuffer(i).size());
    oscManager.sendOsc(msg);
  }
  
  //then clearthe byteBuffers
  for (int j = 0; j < oscManager.byteBuffers.size(); ++j) {
    oscManager.clearByteBuffer(j); 
    // println(oscManager.getByteBuffer(j).size()); 
  }
}

public void buildMessage(int uni){
  //send our data 
  String addr = "/dmx/universe/" + uni;
  OscMessage msg = oscManager.buildMessage(addr, toByteArray(oscManager.getByteBuffer()));
  oscManager.sendOsc(msg);
  //then clearthe byteBuffer
  oscManager.clearByteBuffer();
}

// //////////////////////////////////////////
// //// UTILITY FUNCTIONS
// /////////////////////////////////////////

public byte[] toByteArray(ArrayList<Byte> in) {
  final int n = in.size();
  byte ret[] = new byte[n];
  for (int i = 0; i < n; i++) {
      ret[i] = in.get(i);
  }
  return ret;
}

public byte[] colorsToBytes(int[] cols){
    byte[] bytes = { PApplet.parseByte(cols[0]), PApplet.parseByte(cols[1]), PApplet.parseByte(cols[2]) };
    return bytes;
}

/**
 * [colorToBytes description]
 * @param  {[type]} int[] col           [description]
 * @return {[type]}       r,g,b
 */
public byte[] colorToBytes(int[] col){
  byte[] bytes = { PApplet.parseByte(col[0]), PApplet.parseByte(col[1]), PApplet.parseByte(col[2]) };
  return bytes;
}

// /////////////////////////////////////////

public int getAddressIndex (int _rib,int _strand,int _pcb){
 return addressIndexes[_rib][_strand][_pcb]; 
}

////////////////////////////////////////
/// SERIAL
///////////////////////////////////////
public void serialEvent(Serial myPort) {
  if (serialInitialized) {
      String message = myPort.readStringUntil(LF); // read serial data
      if(message != null ){
        // print(message);
        String [] data = message.split(","); // Split the comma-separated message
        if(data[0].charAt(0) == HEADER && data.length > 2){ // check validity
          int[] dataVals = new int[data.length];
          for( int i = 1; i < data.length-1; i++){ // skip the header & end if line                               
            // Print the field values
            // data[i] is our useful info
            dataVals[i-1] = Integer.parseInt(data[i]);
            controlBoxParams.setValues(dataVals);
            //sceneNumber = Integer.parseInt(data[i]);
          }
     
        }
      }
  }
}
// color lerpMultiColors(color[] colors, float t){
//   for (color col : colors) {
    
//   }
//   if( t == 0.0 ){ return colors[0]; }
//   else if( t == 1.0 ){ return colors[colors.length -1]; }
  
//   return color(
//     lerpWrapped( s_hsv.x, f_hsv.x, 1.0f, t )
//     , lerp( s_hsv.y, f_hsv.y, t )
//     , lerp( s_hsv.z, f_hsv.z, t )
//     , lerp( start.a, finish.a, t ) );
// }

// /////////////////////////////////////////////////////////
// //

// ////////////////////////////////////////////////////////////

//    color getColor(int _rib, int _strand, int _pcb){
//      return sceneColors[_rib][_strand][_pcb];
//    }
   
//    void setColor(color _color){
//      sceneColors[rib][strand][pcb] = _color;
//    }
   
//    void layer(color _newLayer){
//      color current = sceneColors[rib][strand][pcb];
//      float blendPercent = (brightness(_newLayer)/100);
//      float aR = (red(current)/360)*255;
//      float aG = (green(current)/100)*255;
//      float aB = (blue(current)/100)*255;
//      float bR = (red(_newLayer)/360)*255;
//      float bG = (green(_newLayer)/100)*255;
//      float bB = (blue(_newLayer)/100)*255;
//      colorMode(RGB,255,255,255);
//      color a = color(aR, aG, aB);
//      color b = color(bR, bG, bB);
//      //float pcent = (mouseX/float(width));
//      color blend = lerpColor(a,b,blendPercent);
//      float newHue = (hue(blend)/255)*360;
//      float newSaturation = (saturation(blend)/255)*100;
//      float newBrightness = (brightness(blend)/255)*100;
//      colorMode(HSB,360,100,100);
//      color composite =  color(newHue,newSaturation,newBrightness);
//      setColor(composite);
//    }
   
//    color paletteWheel(color first, color second, color third, float index){
//      color wheel = color(0,0,0);
//      int stop = 360/3;
//      float aR = (red(first)/360)*255;
//      float aG = (green(first)/100)*255;
//      float aB = (blue(first)/100)*255;
//      float bR = (red(second)/360)*255;
//      float bG = (green(second)/100)*255;
//      float bB = (blue(second)/100)*255;
//      float cR = (red(third)/360)*255;
//      float cG = (green(third)/100)*255;
//      float cB = (blue(third)/100)*255;
//      colorMode(RGB,255,255,255);
//      color a = color(aR, aG, aB);
//      color b = color(bR, bG, bB);
//      color c = color(cR, cG, cB);
//        if(index < stop){
//          wheel = lerpColor(a,b,(index/(float)stop));
//        } else if(index < stop*2){
//          wheel = lerpColor(b,c,((index-stop)/((float)stop)));
//        } else if(index < stop*3){
//          wheel = lerpColor(c,a,((index-(stop*2))/((float)stop)));
//        } else {
//          println("your wheel is ready madame"); 
//        }
       
//      float newHue = (hue(wheel)/255)*360;
//      float newSaturation = (saturation(wheel)/255)*100;
//      float newBrightness = (brightness(wheel)/255)*100;
//      colorMode(HSB,360,100,100);
//      color composite =  color(newHue,newSaturation,newBrightness);
//      //setColor(composite);
//      return composite;
//    }
/**
 * Dusk; a test scene to be played on the Antfood light sculpture
 * @author: Kevin Siwoff
 * @date: 1-26-15
 */
class Dusk extends Scene{
  Pattern pattern;
  Gradient gradient;
  
  int colorPos = 0;
  float colorOffset = 0.0f;
  float lastTime = 0;

  public Dusk (Parameters params, int _length, int _width, int[] _height) {
    super( params, _length, _width, _height);
    this.name = "Dusk";
    this.pattern = new Pattern();
  }

  public void setup(){
    //inspired by Adobe Kuler
    int[] duskColors = { color(219, 44, 49), 
      color(286, 24, 55), 
      color(325, 21, 64), 
      color(281, 13, 68), 
      color(243, 23, 76)};
    pattern.setPaletteColors(duskColors);
    
    gradient = pattern.makeGradient(pattern.getColorPalette(), 100, true);
  }

  public void updateScene(float t){
    float dt = t - lastTime;
    for (int ribIndex = 0; ribIndex < sceneLength; ++ribIndex) {
      for (int strandIndex = 0; strandIndex < sceneWidth; ++strandIndex) {
        for (int pcbIndex = 0; pcbIndex < sceneHeights[ribIndex]; ++pcbIndex) {
          
          colorPos = PApplet.parseInt((pcbIndex + colorOffset) % 100);
          
          SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, gradient.getColor(colorPos));
        }
      }
    }
    lastTime = t;
    if(dt % 2 == 0){
      colorOffset+=0.3f;      
    }
  }

}
/**
 * Flash; a test scene to be played on the Antfood light sculpture
 * @author: Kevin Siwoff
 * @date: 1-26-15
 */
class Flash extends Scene{
  Pattern pattern;
  Gradient gradient;
  
  int colorPos = 0;
  float colorOffset = 0.0f;
  float lastTime = 0;

  public Flash (Parameters params, int _length, int _width, int[] _height) {
    super( params, _length, _width, _height);
    this.name = "Flash";
    this.pattern = new Pattern();
  }

  public void setup(){
    //inspired by Adobe Kuler
    int[] FlashColors = { color(219, 0, 100), 
      color(286, 0, 100), 
      color(325, 0, 100), 
      color(281, 0, 100), 
      color(243, 0, 100)};
    pattern.setPaletteColors(FlashColors);
    
    gradient = pattern.makeGradient(pattern.getColorPalette(), 100, true);
  }

  public void updateScene(float t){
    float dt = t - lastTime;
    for (int ribIndex = 0; ribIndex < sceneLength; ++ribIndex) {
      for (int strandIndex = 0; strandIndex < sceneWidth; ++strandIndex) {
        for (int pcbIndex = 0; pcbIndex < sceneHeights[ribIndex]; ++pcbIndex) {
          
          colorPos = PApplet.parseInt((pcbIndex + colorOffset) % 100);
          
          int newCol = color(hue(gradient.getColor(colorPos)), saturation(gradient.getColor(colorPos)), brightness(PApplet.parseInt(colorOffset % 100)));
          int rise = color(0,0,colorOffset%100);
          SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, rise);//gradient.getColor(colorPos));
        }
      }
    }
    lastTime = t;
    // if(dt % 1 == 0){
          
    // }
    colorOffset+=0.5f;  
  }

}

public class GammaCorrection {
      //inspired by Micah Scott / Fadecandy gamma correction
    private double gamma                       = 2.8f; // Exponent for the nonlinear portion of the brightness curve
    private PVector whitepoint                 = new PVector(1.0f,1.0f,1.0f); //Vector of [red, green, blue] values to multiply by colors prior to gamma correction
    private float linearSlope                  = 1.0f; //Slope (output / input) of the linear section of the brightness curve
    private float linearCutoff                 = 1.0f; //Y (output) coordinate of intersection between linear and nonlinear curves
    private int maxIn                          = 255; // Top end of INPUT range
    private int maxOut                         = 220; // Top end of OUTPUT range
    private int tableRes                       = 256; //size of our gamma correction table
    
    //these vals should match the HSB color range in our app sketch
    private float maxHueIn                     = 360.0f; 
    private float maxSatIn                     = 100.0f;
    private float maxBriIn                     = 100.0f;

    int[] correctionTable; 
    GammaCorrection(){
      correctionTable = new int[tableRes];
      for(int i = 0; i < correctionTable.length; i++){
        //temporary fix
        int index = (int) Math.floor(Math.pow((double) i / (double) maxIn, gamma) * maxOut + 0.5f);
        correctionTable[i] = index;
      }
    }

    /**
     * [getGammaVals description]
     * @param  {[type]} color   col           [description]
     * @param  {[type]} boolean isHsv         is the value passed as arg hsb?
     * @return {[int]}         Color as rgb 32bit int
     */
    public int[] getGammaVals(float first, float second, float third, boolean isHsb){
      int _red; 
      int _green; 
      int _blue;
      int[] colors = new int[3];

      if(!isHsb){//it must be rgb
        int _first = (int) first;
        int _second = (int) second;
        int _third = (int) third;
        colors[0] = correctionTable[_first];
        colors[1] = correctionTable[_second];
        colors[2] = correctionTable[_third];
      }
      else {//it must be hsb

        
        //_red = (int) (255 * (Math.pow((double) first / (double) 255, gamma)));
        //_green = (int) (255 * (Math.pow((double) second / (double) 255, gamma)));
        //_blue = (int) (255 * (Math.pow((double) third / (double) 255, gamma)));

        float mappedHue = map(first, 0.0f, maxHueIn, 0.0f, 1.0f);
        float mappedSat = map(second, 0.0f, maxSatIn, 0.0f, 1.0f);
        float mappedBri = map(third, 0.0f, maxBriIn, 0.0f, 1.0f);
        //println(mappedHue + " s: " + mappedSat + " b: " + mappedBri );
        
        Color _rgb = new Color(Color.HSBtoRGB(mappedHue, mappedSat, mappedBri));
        
        colors[2] = correctionTable[(int) _rgb.getRed()];
        colors[1] = correctionTable[(int) _rgb.getGreen()];
        colors[0] = correctionTable[(int) _rgb.getBlue()];

      }

      return colors;
    }
}
/**
 * OscManager class
 * @description: A simple wrapper for Andreas Schlegel's oscP5
 * To use, add this .pde in your Processing sketch and you should be good to go
 * @author: kevin siwoff
 * @date: 1-12-15
 */



class OscManager {
  private String _address;
  private int _sendPort;
  private int _receivePort;
  private OscP5 _oscP5;
  private NetAddress _broadcastLoc;
  public ArrayList<Byte> byteBuffer;
  //holds all of our byte buffers
  public ArrayList<ArrayList<Byte>> byteBuffers;

  /**
   * Default constructor w/ no args
   */
  OscManager(){
    this._address = "127.0.0.1";//localhost
    this._sendPort = 3000;
    this._receivePort = _sendPort + 1000;
    //we initialize our oscP5 instance by passing in parent and receive port
    _oscP5 = new OscP5(this, _receivePort);
    _broadcastLoc = new NetAddress(_address, _sendPort);
    byteBuffer = new ArrayList<Byte>();
    byteBuffers = new ArrayList<ArrayList<Byte>>(8);
  }

  OscManager(String address, int port){
    this._address = address;
    this._sendPort = port;
    this._receivePort = port + 1000;
    //we initialize our oscP5 instance by passing in parent and receive port
    _oscP5 = new OscP5(this, _receivePort);
    _broadcastLoc = new NetAddress(_address, _sendPort);
    byteBuffer = new ArrayList<Byte>();
    
    //create 8 byteBuffers
    byteBuffers = new ArrayList<ArrayList<Byte>>(){{
      add(new ArrayList<Byte>());
      add(new ArrayList<Byte>());
      add(new ArrayList<Byte>());
      add(new ArrayList<Byte>());
      add(new ArrayList<Byte>());
      add(new ArrayList<Byte>());
      add(new ArrayList<Byte>());
      add(new ArrayList<Byte>());
    }};

  }
  
  public OscP5 getInstance(){
    return _oscP5;
  }

  public ArrayList<Byte> getByteBuffer(){
    return byteBuffer;
  }

  /**
   * gets a given byteBuffer from our byteBuffers ArrayList
   * @param  {[type]} int i             [description]
   * @return {[type]}     [description]
   */
  public ArrayList<Byte> getByteBuffer(int i){
    return byteBuffers.get(i);
  }

  public void sendOsc(OscBundle messageBundle){
    _oscP5.send(messageBundle, _broadcastLoc);
  }
  
  public void sendOsc(OscMessage message){
    _oscP5.send(message, _broadcastLoc);
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

  /**
   * Builds an osc message for functional-style use
   * @param  {[type]} String messAddress   OSC message address; eg. "/awesome/party" 
   * @param  {[type]} int    val           value to bundle in address
   * @return {[type]}        OscBundle    You can use this to pass into the sendOsc() method.
   */
  public OscMessage buildMessage(String messAddress, int val){
    OscMessage oscMessage = new OscMessage(messAddress);
    oscMessage.add(val);

    return oscMessage;
  }  

  /**
   * Builds an osc message for functional-style use
   * @param  {[type]} String messAddress   OSC message address; eg. "/awesome/party" 
   * @param  {[type]} int[]  vals       array of values to bundle in address
   * @return {[type]}        OscBundle    You can use this to pass into the sendOsc() method.
   */
  public OscMessage buildMessage(String messAddress, int[] vals){
    OscMessage oscMessage = new OscMessage(messAddress);
    for(int val : vals){
      oscMessage.add(val);
    }

    return oscMessage;
  }

  /**
   * Builds an osc message for functional-style use
   * @param  {[type]} String messAddress   OSC message address; eg. "/awesome/party" 
   * @param  {[type]} float[]  vals       array of values to bundle in address
   * @return {[type]}        OscBundle    You can use this to pass into the sendOsc() method.
   */
  public OscMessage buildMessage(String messAddress, float[] vals){
    OscMessage oscMessage = new OscMessage(messAddress);
    for(float val : vals){
      oscMessage.add(val);
    }
    return oscMessage;
  }

  public void addColorBytes(byte[] data){
    for(byte component : data){
      byteBuffer.add(component);
    }
  }

  public void addColorBytes(int i, byte[] data){
    ArrayList<Byte> buffer = getByteBuffer(i);
    // println(buffer.size());
    for(int j=0; j < data.length; j++){
      buffer.add(data[j]);
      // if(buffer == null || buffer.size() <= 0) buffer.set(j, data[j]);//buffer.add(data[j]);
      //else println(buffer.get(0));//buffer.set(j, data[j]);
    }
  }
  
  public void clearByteBuffer(){
    byteBuffer.clear();
  }

  public void clearByteBuffer(int i){
    byteBuffers.get(i).clear();
  }

  public int getByteBufferSize(){
    return byteBuffer.size();
  } 
}
/**
* Pattern Manager
* @author Gabe Liberti, Kevin Siwoff
* @version 1.1
* @date 1-27-15
* @description Generic pattern class for handling color palette and gradient processing.
* Class is intentionally setup to hold only 1 color palette per pattern.
* Best practice is to subclass Pattern and create custom patterns there.
*/





class Pattern {
	private Palette palette;// our ColorLib Palette
	PApplet parent; //important to pass in reference to PApplet otherwise functions won't work
	Pattern(){
		palette = new Palette(parent);
	} 

	/**
	 * sets an arbitrary number of colors as our palette
	 * @param {int[] | color[]} color[] cols collection of colors
	 */
	public void setPaletteColors(int[] cols){
		for (int col : cols) {
				palette.addColor(col);		
		}
	}

	/**
	 * creates a new gradient from a given palette. after calling this method
	 * you can access specific cols along the gradient like gradient.getColor(i),
	 * where gradient is a local variable and i is a step index.
	 * @param  {Palette} p             palette
	 * @param  {int}     steps         steps in gradient
	 * @param  {boolean} wrap          does the gradient wrap around?
	 * @return {Gradient}         		 Gradient obj
	 */
	public Gradient makeGradient(Palette p, int steps, boolean wrap){
		return new Gradient(p, steps, wrap);
	}

	/**
	 * convenience function for returning ColorLib palette
	 * @return {Palette} a collection of colors
	 */
	public Palette getColorPalette(){
		return palette;
	}
}//END PATTERN CLASS
/**
 * Scene Builder
 * @author Gabe Liberti, Kevin Siwoff
 * @version 1.0
 * @date 1-15-15
 * @description A generic Scene class.  To create your own scene, subclass this.
 * See Dusk.pde for more info.
 */



class Scene implements Observer{

  private Parameters params;
  int[] scenePalette;
  int sceneLength;
  int sceneWidth;
  int[] sceneHeights;
  protected String name;

  Scene(Parameters params, int _length, int _width, int[] _height){
     sceneLength = _length;
     sceneWidth = _width;
     sceneHeights = _height;
     this.params = params;
  }

  //@TODO
  public void setup(){}
  
  /**
   * [update description]
   * @param  {[type]} Observable obs           [description]
   * @param  {[type]} Object     obj           [description]
   * @param  {[type]} float      t             [description]
   * @return {[type]}            [description]
   */
  public void update(Observable obs, Object obj){
    if(obs == params){
      println("Ive got some values: " + params.getValues());
    }
  }

  public void updateScene(float t){}

  public String getSceneName(){
      if (name == null) return "";
      else return name;
  }
}


public class SceneControl extends PApplet {
  Serial myPort;  // Create object from Serial class
  char HEADER = 'S';    // character to identify the start of a message
  short LF = 10;        // ASCII linefeed
  boolean isChanged;
  public SceneControl () {
    //hardcoded; this could be dangerous if there's no usbmodem attached
    println(Serial.list());
    myPort = new Serial(this, Serial.list()[5], 9600);
    
//    for(int i=0; i < Serial.list().length; i++){
//      if (Serial.list()[i] == "/dev/tty.usbmodem1411"){
//          myPort = new Serial(this, "/dev/tty.usbmodem660981", 9600);      
//      }
//      else {
//        println("error.  you do not have a usb modem attached");
//      }
//    }
    isChanged = false;
  }
  
  public boolean bIsSceneChanged(){
    return isChanged;
  }
  
  public void serialEvent(Serial myPort) {

    String message = myPort.readStringUntil(LF); // read serial data
    if(message != null ){
      //print(message);
      String [] data = message.split(","); // Split the comma-separated message
      if(data[0].charAt(0) == HEADER && data.length > 2) // check validity
      {
        for( int i = 1; i < data.length-1; i++) // skip the header & end if line                               
      {
        // Print the field values
        // data[i] is our useful info
        println("Value " +  i + " = " + data[i]);  
        if (data[i] == "0"){
          isChanged = true;
        } else if(data[i] == "1"){
        
        }
        else if(data[i] == "2"){
        isChanged = true;
        }
        else if(data[i] == "3"){
        isChanged = false;
        }
        else if(data[i] == "4"){
        isChanged = true;
        }
        else if(data[i] == "5"){
        isChanged = false;
        }
        else if(data[i] == "6"){
        isChanged = true;
        }
        else if(data[i] == "7"){
        isChanged = false;
        }
        else if(data[i] == "8"){
        isChanged = true;
        }
        
    }
      println();
      
    }
    }
  }

}
/**
 * Scenes class
 * @description: a generic scene manager.  Made for read-only operations.
 * Usage: create a new instance of this in your main app class.
 */



public class Scenes {
  private ArrayList<Scene> _scenes; //polymorphic ArrayList of scenes
  
  //THIS SHOULD NOT BE HERE BUT I'M BEING LAZY RIGHT NOW
  int ribLength = 28;
  int strandWidth = 5;
  int[] pcbHeights =
    {1,1,2,3,3,
    4,3,3,4,6,
    7,6,5,4,4,
    6,7,8,8,7,
    6,5,4,5,3,
    2,1,1};

  public Scenes (Parameters params) {

    _scenes = new ArrayList<Scene>(Arrays.asList(
        //... list our scenes here
        //comma separated like this:
        //new AwesomeSceneClass(), new AnotherAwesomeSceneClass()...
        new Dusk(params, ribLength, strandWidth, pcbHeights),
        new Swarm(params, ribLength, strandWidth, pcbHeights),
        new Flash(params, ribLength, strandWidth, pcbHeights)
      ));
    for (Scene scene : _scenes) {
      params.addObserver(scene);      
    }

  }


  public Scene getScene(int index){
    return _scenes.get(index);
  }

  /**
   * gets scene name from given scene
   * @param  {int} int index         scene number starting at 0 index
   * @return {String}                Name
   */
  public String getSceneName(int index){
    return (String) _scenes.get(index).getSceneName();
  }

  public int getTotalSceneCount(){
    return _scenes.size();
  }

  public ArrayList<Scene> getScenes(){
    return _scenes;
  }
}
/**
 * Swarm; a potential scene to be played on the Antfood light sculpture
 * @author: Kevin Siwoff
 * @date: 1-27-15
 */
class Swarm extends Scene{
  Pattern pattern;
  Gradient gradient;

  ////////////////////////////
  //// FLOCK
  ///////////////////////////
  ArrayList<Boid> boids;
  
  int colorPos = 0;
  float colorOffset = 0.0f;
  float lastTime = 0;
  float radius = 10.0f;

  public Swarm (Parameters params, int _length, int _width, int[] _height) {
    super( params, _length, _width, _height);
    this.name = "Swarm";
    this.pattern = new Pattern();
    boids = new ArrayList<Boid>();
  }

  public void setup(){
    //inspired by Adobe Kuler
    int[] duskColors = { color(219, 44, 49), 
      color(286, 24, 55), 
      color(325, 21, 64), 
      color(281, 13, 68), 
      color(243, 23, 76)};
    pattern.setPaletteColors(duskColors);
    gradient = pattern.makeGradient(pattern.getColorPalette(), 100, true);
    
    //create 5 boids
    for (int i = 0; i < 10; i++) {
      createBoid(radius);
    }
  }

  public void updateScene(float t){
    //wow this is bad practice
    for (Boid boid : boids) {
      boid.run(boids);
    }

    float dt = t - lastTime;
    float val = 0.0f;//brightness value
    for (int ribIndex = 0; ribIndex < sceneLength; ++ribIndex) {
      for (int strandIndex = 0; strandIndex < sceneWidth; ++strandIndex) {
        for (int pcbIndex = 0; pcbIndex < sceneHeights[ribIndex]; ++pcbIndex) {
          
          //loop through all boids and check distance to given fixture
          for(Boid b : boids){
            float distance = b.getPos().dist( new PVector(PApplet.parseFloat(ribIndex), PApplet.parseFloat(strandIndex), PApplet.parseFloat(pcbIndex)));
            distance /= radius;
            if (distance < 1.0f){

              val = 1.0f - distance;
            }
            float bright = max(brightness(gradient.getColor(0)), val * 100.0f);
            int colAdjusted = color(hue(gradient.getColor(0)), saturation(gradient.getColor(0)), bright);
            SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, colAdjusted);
          }
        }
      }
    }
    lastTime = t;
    if(dt % 2 == 0){
      colorOffset+=0.3f;      
    }
  }

  private void createBoid(float radius){
    boids.add(new Boid(0,0,0,radius));

    // boids.add(new Boid(( -sceneLength/2 ) * 50, ( -sceneWidth/2 ) * 50, 0, radius));
  }

};


//based on Dan Shiffman's
// Boid class
// Methods for Separation, Cohesion, Alignment added

class Boid {

  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

  Boid(float x, float y, float z, float rad) {
    acceleration = new PVector(0,0,0);
    velocity = PVector.random3D();
    location = new PVector(x,y,z);
    r = rad;
    maxspeed = 3;
    maxforce = 0.05f;
  }

  public PVector getPos(){
    return location;
  }

  public void run(ArrayList<Boid> boids) {
    flock(boids);
    update();
    borders();
    render();
  }

  public void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }


  // We accumulate a new acceleration each time based on three rules
  public void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(1.5f);
    ali.mult(1.0f);
    coh.mult(1.0f);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  // Method to update location
  public void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  public PVector seek(PVector target) {
    PVector desired = PVector.sub(target,location);  // A vector pointing from the location to the target
    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);
    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }
  
  public void render() {
    // Draw a triangle rotated in the direction of velocity
    //float theta = velocity.heading2D() + radians(90);
    fill(175);
    stroke(0);
    pushMatrix();
    translate(location.x,location.y, location.z);
    //rotate(theta);
    sphere(r);
    // beginShape(TRIANGLES);
    // vertex(0, -r*2);
    // vertex(-r, r*2);
    // vertex(r, r*2);
    // endShape();
    popMatrix();
  }

  // Wraparound
  public void borders() {
    if (location.x < -r) location.x = width+r;
    if (location.y < -r) location.y = height+r;
    if (location.z < -r) location.z = 0;
    if (location.x > width+r) location.x = -r;
    if (location.y > height+r) location.y = -r;
    if (location.z > 0) location.z = -r;
  }

  // Separation
  // Method checks for nearby boids and steers away
  public PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 50.0f;
    PVector steer = new PVector(0,0,0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(location,other.location);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(location,other.location);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  public PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0,0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location,other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum,velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0,0);
    }
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  public PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0,0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location,other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.location); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the location
    } else {
      return new PVector(0,0);
    }
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "sketch_3DLEDstructure" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
