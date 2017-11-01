/*
tiny_rose
sketch by Jim Bumgardner
http://www.openprocessing.org/sketch/3378
The Rose equation is the same formula described by John Whitney 
as RD/TD in his book "Digital Harmony", and used extensively in his film "Moon Drum". 
It is closely related to the motion seen in my "Whitney Music Box", 
except the angles and radii are swapped.
modified by kevin siwoff
*/

int w=400;//width
int j=w/2; //half width
float n=1;//offset
int filterNum;

void setup() { 
size(w,400); 
}
void draw(){
  background(0);
  smooth();
  //loop from 1 to 999
  for(int i=1;i<999;++i){
    float t=i*.01; //t is 1/100th of the iteration count 
    
    //the main algorithm
    float r=j*sin((n+mouseX*100/w)*t);
    
    ellipse(j+cos(t)*r,j+sin(t)*r,8,8); //elipses with diameter = 8 spin around a circle 
  }
  n += .001;
  filter(BLUR, filterNum);
//  filter(11);
//  filter(17);
}

void keyPressed(){
  if(keyCode == RIGHT){
    filterNum++;
    println(filterNum);
  }
  else if(keyCode == LEFT){
    if(filterNum >= 0){
      filterNum--;
      println(filterNum);
    }
  }
}
