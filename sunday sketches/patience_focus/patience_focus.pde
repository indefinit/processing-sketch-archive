import processing.pdf.*;

float t = 0.0;
float u = 0.0;
float yScalar = 50.0;
float xScalar = 10.0;
PImage pointerTexture;
float radius  = 250.0;
ArrayList<Pointer> pointers;
int numPointers = 100;
boolean record = false;
void setup(){
  size(displayWidth,displayHeight);

   

//  noLoop();
  smooth();
  pointerTexture = loadImage("cursor_2.png");
  pointers = new ArrayList<Pointer>();
  for(int i=0; i < numPointers; i++){
    pointers.add(new Pointer(width/2,height/2));
  }
}
void draw(){
  if (record) {
    // Note that #### will be replaced with the frame number. Fancy!
    beginRecord(PDF, "frame-" + millis() +".pdf"); 
  }
  
  background(255);

  //patience();
  focus();
  
  if (record) {
    endRecord();
  record = false;
  }
  
}

void patience(){
    for(int i=0; i < width; i+=10){
    strokeWeight(int(random(3,4)));
    stroke(24);
    pushMatrix();
    translate(0,height/2);
    
    line(i+(random(-3,3)),noise(t)* -yScalar, i+(random(-3,3)), yScalar );
    popMatrix();

    t+=0.02;
    u+=0.05;
  }
}

void focus(){
  for (Pointer p : pointers) {
    // Path following and separation are worked on in this function
    p.applyBehaviors(pointers);
    // Call the generic run method (update, borders, display, etc.)
    p.update();
    p.display(pointerTexture);
  }
}

void mousePressed(){
  record = true;
}
