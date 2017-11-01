float location = 0;
float speed = 0;


void setup(){
  size(480,270);

}

void draw(){
  background(0,0,32);

  // obtain the current terrain location
  float mouseFrac = (mouseX-(width/2))/(float)(width/2); // -1...1
  speed = (0.9*speed) + (0.1*mouseFrac);
  location += speed; 

  // draw mountains
  for (int i=0; i<width; i++){
    stroke(255,32,96);
    float mountainA = (height*0.50) * noise((location+i)/150.0);
    line(i,height, i,mountainA);

    stroke(255,150,128);
    float mountainB = (height*0.50) * (0.25 + noise((1.15*location+i)/140.0));
    line(i,height, i,mountainB);
  }


}




