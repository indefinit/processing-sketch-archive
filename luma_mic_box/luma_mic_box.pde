import controlP5.*;
import processing.pdf.*;

int numRings = 20;
float ringRadius = 24.0;
float circleRadiusStart = 10.0;
float twist = 0.0;
float radAdjust = 1.30;
int angleAdjust = 12;

boolean pdfMode = true;
ControlP5 cp5;

void setup(){
if(pdfMode){
size(1000,1000,PDF, "output.pdf");
}
else {
  size(1000,1000);
  cp5 = new ControlP5(this);
  
  cp5.addSlider("numRings")
     .setPosition(100,50)
     .setSize(300,20)
     .setValue(20)
     .setColorCaptionLabel(0)
     .setRange(1,50);
     
  cp5.addSlider("ringRadius")
     .setPosition(100,75)
     .setSize(300,20)
     .setColorCaptionLabel(0)
     .setValue(24.0)
     .setRange(0,600.0);
     
   cp5.addSlider("circleRadiusStart")
     .setPosition(100,100)
     .setSize(300,20)
     .setValue(10.0)
     .setColorCaptionLabel(0)
     .setRange(1.0,20.0);
     
   cp5.addSlider("twist")
     .setPosition(100,125)
     .setSize(300,20)
     .setColorCaptionLabel(0)
     .setRange(0.0,20.0);
     
    cp5.addSlider("radAdjust")
     .setPosition(100,150)
     .setSize(300,20)
     .setColorCaptionLabel(0)
     .setValue(1.30)
     .setRange(0.0,5.0);
     
     cp5.addSlider("angleAdjust")
     .setPosition(100,175)
     .setSize(300,20)
     .setColorCaptionLabel(0)
     .setValue(12)
     .setRange(1,20);
     
}
  
  ellipseMode(CENTER);
}
void draw(){
  background(255);

  pushMatrix();
  translate(width/2,height/2);
  float _rad = ringRadius;
  float _rings = numRings;
  float _ringRot = 0.0;
  
  for(int u=0; u< _rings; u++){
    pushMatrix();
    if(u > 0){
      rotate(radians(u));
    }
    float _circleRad = ( (u / _rings))* circleRadiusStart;
    

    for(int i=0;i< 360;i+=angleAdjust){
      fill(0);
      ellipse(cos(radians(i)) * _rad,sin(radians(i)) * _rad, _circleRad + radAdjust,_circleRad+radAdjust);  
  }
    
    popMatrix();
    _rad += (10 + u*0.5);//(_rad / numRings);
  }
  popMatrix();
  
if(pdfMode){
    exit();
}

}
