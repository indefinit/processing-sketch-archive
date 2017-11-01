/**
 * 3D LED Sculpture Animation Engine
 * @authors Gabe Liberti and Kevin Siwoff
 * @version 4.2.3
 * @date 1-15-15
 * @description Generates and sequences patterns and colors for 3D LED systems
 * @TODOs: 
 * 1. Finish universe mapping according to Dave's diagram instead of auto assignment (kevin)
 */
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioInput in;

FFT fftLog;
 
import peasy.test.*;
import peasy.org.apache.commons.math.*;
import peasy.*;
import peasy.org.apache.commons.math.geometry.*;
import processing.serial.*;

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

/////////////////////////////
//@TODO: these need to be moved to which ever class makes the most sense (probably the scene superclass?)
PVector[] realSpace;
int ribDistance = 12;
int strandDistance = 8;

int spacing = 50;
int boxSize = 13;

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

void setup (){
  size(1280,800,P3D);
  frameRate(100);
  colorMode(HSB,360,100,100);//max h:160, max s:100, max b:100
  
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(600);
  cam.setMaximumDistance(2600);
  
  minim = new Minim(this);
  // use the getLineIn method of the Minim object to get an AudioInput
  in = minim.getLineIn();
  
  fftLog = new FFT( in.bufferSize(), in.sampleRate() );
  fftLog.logAverages( 11, 4 );

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

///////////////////////////////////////////////////
//@TODO: this should be moved into the setup function in whatever class the realspace array will be moved to
  realSpace = new PVector[ribLength*strandWidth*max(pcbHeights)];
    for ( int r = 0 ; r < ribLength ; r++ ){
      for ( int s = 0 ; s < strandWidth ; s++ ){
        for ( int p = 0 ; p < max(pcbHeights) ; p++ ){
          realSpace[r*strandWidth*max(pcbHeights) + s*max(pcbHeights) + p] = new PVector(r*ribDistance, s*strandDistance, p*strandDistance);
        }
      }
    }

  
  //create our parameters object.
  //in this case we are creating 4 individual slider params
  //to change this number add more/less zeros to the array literal
  controlBoxParams = new Parameters(new int[]{0,0,0,0});

  scenes = new Scenes(controlBoxParams);
  previousScene = scenes.getScene(0);
  loadScene(0);
}

void draw(){
  colorMode(HSB,360,100,100);
  background(85);
  
  fftLog.forward( in.mix );
  
  //@TODO debug
  currentScene.updateScene(second());
  
  //Send values over OSC
  sendOsc();

  //draw our graphics
  renderSculpture();

  frame.setTitle(int(frameRate) + " fps");
  
}

/**
 * Loads current scene
 * @param  {int} index         sceneIndex from 0-8
 * @return {void}
 */
void loadScene( int index )
{
    boolean doAnimate = (index != sceneIndex);

    float cooldownTime = ( doAnimate ) ? 0.25 : 0;
    
    if( index < 0 ) { index = scenes.getTotalSceneCount() - 1; }
    index %= scenes.getTotalSceneCount();
    
    sceneIndex = index;
    currentScene = scenes.getScene(sceneIndex);
    previousScene.setDoTransition(true);
    currentScene.setDoTransition(true);

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
void renderSculpture(){
  pushMatrix();
    //center our sculpture before drawing our fixtures
    translate(( -ribLength/2 ) * spacing * 1.5, ( -strandWidth/2 ) * spacing - 80, 0);
    rotateX(-PI/2);
    for (int ribIndex = 0; ribIndex < ribLength; ++ribIndex) {
      for (int strandIndex = 0; strandIndex < strandWidth; ++strandIndex) {
        for (int pcbIndex = 0; pcbIndex < pcbHeights[ribIndex]; ++pcbIndex) {
     
          color fixtureColor = color(SculptureManager.getInstance().getFixtureColor(ribIndex , strandIndex, pcbIndex));
          pushMatrix();
            noStroke();
            fill(fixtureColor);
            translate(ribIndex*spacing*1.5, strandIndex*spacing, pcbIndex*spacing);
            box(boxSize);
          popMatrix();
        }
      }
    }
  popMatrix();
}


void sendOsc(){
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

        color fixtureColor = color(SculptureManager.getInstance().getFixtureColor(ribIndex , strandIndex, pcbIndex)); 
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

void buildMessages(){

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

void buildMessage(int uni){
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
    byte[] bytes = { byte(cols[0]), byte(cols[1]), byte(cols[2]) };
    return bytes;
}

/**
 * [colorToBytes description]
 * @param  {[type]} int[] col           [description]
 * @return {[type]}       r,g,b
 */
public byte[] colorToBytes(int[] col){
  byte[] bytes = { byte(col[0]), byte(col[1]), byte(col[2]) };
  return bytes;
}

// /////////////////////////////////////////

int getAddressIndex (int _rib,int _strand,int _pcb){
 return addressIndexes[_rib][_strand][_pcb]; 
}

void keyPressed(){
 if (key == ' '){
    sceneIndex++;
    loadScene(sceneIndex);
 } 
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
