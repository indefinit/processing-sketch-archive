int a=2, b=100, c=48;
int nPoints = 20000;
float dt = 0.01;

void setup(){
  size(800,800, P3D);
}

void draw(){
  background(255);
  float x = 1.0, y = 1.0, z = 1.0;
  int i = 0;
  translate(width/2, height/2, 0);
  beginShape();
  while (i < nPoints + 1){
   vertex(x,y,z);
    x = x + dt * dx(x, y, z);
    y = y + dt * dy(x, y, z);
    z = z + dt * dz(x, y, z);
    
    i++;
  }
  endShape(CLOSE);
}


float dx(float x, float y, float z){
return a * (y - x);
}

float dy(float x, float y, float z){
return -(x * z) + (b * x) - y;
}

float dz(float x, float y, float z){
return x * y - (c) * z;
}
