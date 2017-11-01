import netP5.*;
import oscP5.*;
import controlP5.*;

OscP5 oscP5; 
ControlP5 cp5;

float translationZ = 0.0;
float zVariance = 0.0;
PVector mousePos = new PVector(0,0);
float translationalAngle = 0.0;
String toSend = "";
ArrayList<PVector> points;
int lineWeight;

NetAddress myBroadcastLocation;
OscMessage arrayMsg = new OscMessage("/array"); // "/array" is an arbitrary header/filter that the

void setup(){
  size(displayWidth,displayHeight, P3D);
  points = new ArrayList<PVector>();
  oscP5 = new OscP5(this, 6882); 
  myBroadcastLocation = new NetAddress("localhost", 6881);  //broadcast to port 6881 and
  cp5 = new ControlP5(this);
  cp5.addSlider("pointResolution")
    .setPosition(20,20)
    .setRange(0.0,1.0)
    .setSize(200,55);
  cp5.addSlider("lineWeight")
    .setPosition(20,95)
    .setRange(1,45)
    .setSize(200,55);
  background(255);
  noFill();
  stroke(100,100,100);
  smooth();
  ellipseMode(CENTER);
  perspective();
}
void draw(){
  background(255);
  strokeWeight(lineWeight);
  beginShape();
  for(PVector point : points){
    vertex(point.x, point.y,point.z);
  }
  endShape();
}

void keyPressed(){
  if(key == 'c'){
    background(255);
    points.clear();
    toSend = "";
    arrayMsg=new OscMessage("/array");
    arrayMsg.add("");
    OscP5.flush(arrayMsg,myBroadcastLocation);
  }
}

void mouseDragged(){

   PVector currMousePos = new PVector(mouseX,mouseY);
   float mouseSpeed = currMousePos.dist(mousePos);
   if(mouseSpeed > 4.0){
     points.add(new PVector(mouseX,mouseY,0));
     send(currMousePos.x,height-currMousePos.y,0);
     //pushMatrix();
     //  translate(mouseX,mouseY);
     //  ellipse(0,0,50,50);
     //popMatrix();
  }
}

void send(float x, float y, float z){
  float _y = height - y;
   arrayMsg=new OscMessage("/array");
    //now assemble the message to send in a string
     toSend+="{"; 
     toSend+=x + ",";
     toSend+= z + ",";
     toSend+= _y + "}";
     toSend+="*";
     arrayMsg.add(toSend);
     OscP5.flush(arrayMsg,myBroadcastLocation);
}