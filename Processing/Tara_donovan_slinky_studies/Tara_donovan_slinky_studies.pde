import netP5.*;
import oscP5.*;

OscP5 oscP5; 
float translationZ = 0.0;
PVector mousePos = new PVector(0,0);
float mSpeed = 0.0;
float translationalAngle = 0.0;

String toSend = "";

NetAddress myBroadcastLocation;
OscMessage arrayMsg = new OscMessage("/array"); // "/array" is an arbitrary header/filter that the

void setup(){
  size(500,500, P3D);
    oscP5 = new OscP5(this, 6882); 
  myBroadcastLocation = new NetAddress("localhost", 6881);  //broadcast to port 6881 and
  background(255);
  noFill();
  stroke(100,100,100);
  smooth();
  ellipseMode(CENTER);
}
void draw(){

  
  translate(mouseX,mouseY,translationZ);
  //sphere(50);
  ellipse(0,0,50,50);
  
}

/**
** When we click the mouse, it clears the OSC message so that points
** are no longer in the Grasshopper buffer
**/
void mousePressed(){
  //background(255);
  //toSend = "";
  //arrayMsg=new OscMessage("/array");
  //arrayMsg.add("");
  //oscP5.flush(arrayMsg,myBroadcastLocation);
}

void keyPressed(){
  if(key == 'c'){
  background(255);
  toSend = "";
  arrayMsg=new OscMessage("/array");
  arrayMsg.add("");
  oscP5.flush(arrayMsg,myBroadcastLocation);
  translationZ = 0.0;
  }
}
void mouseDragged(){
   arrayMsg=new OscMessage("/array");
   PVector currMousePos = new PVector(mouseX,mouseY);
   float mouseSpeed = currMousePos.dist(mousePos);
   float mouseAccel = mouseSpeed - mSpeed;
   if(mouseSpeed > 4.0){
     mousePos = currMousePos;
     mSpeed = mouseSpeed;
     //translationalAngle +=mouseSpeed;
     translationalAngle +=mouseAccel;
     translationalAngle %= 360;
     translationZ += sin(radians(translationalAngle)) * 10.0;
     
   

     //now assemble the message to send in a string
    toSend+="{"; 
    toSend+=mousePos.x + ",";
    toSend+= -translationZ + ",";
    toSend+= height - mousePos.y + "}";
    toSend+="*";
    //this assembles "{x,y,z)" : a "Grasshopper ready" point 
     arrayMsg.add(toSend); //this loads the string to the message container prior to sending
  // you can actually load(add) many strings/values before sending them. The OSC library
  //separates these values with commas. Thats why in this example we "devised" this trick with
  //with * and & to send the whole array as a single string, everytime the "void draw" runs,  
  //and separate the array into rows and columns in Grasshopper.
  //The way we did this was to assemble "Grasshopper-ready" points: {x,y,z}
  //in the case of a 3x3 array, the string will be something like this:
  // {0,0,0}*{1,0,0)*{2,0,0}&{0,1,0}*{1,1,0)*{2,1,0}&{0,2,0}*{1,2,0)*{2,2,0}
  //which in grasshopper we will read more or less like this:
  //{0,0,0},{1,0,0),{2,0,0}
  //{0,1,0},{1,1,0),{2,1,0}
  //{0,2,0},{1,2,0),{2,2,0}
  //oscP5.flush(arrayMsg,myBroadcastLocation);
  oscP5.send(arrayMsg, myBroadcastLocation); //this is the actual command that sends
  //the message
  //arrayMsg.clear();
 }
}