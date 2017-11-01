float theta;

void setup()
{
  size(500,500,P3D);
  
}

void draw()
{
  background(0);
  float fov = PI/2.0;
float cameraZ = height-10.0 / tan(fov/2.0);
perspective(fov, float(width)/float(height), 
            cameraZ/10.0, cameraZ*10.0);
translate(width/2, height/2, 0);
rotateX(-PI/6);
//rotateY(PI/3);

fill(100,100,0);
box(45);

pushMatrix();
translate(0, 0, -90);
box(45);
popMatrix();

pushMatrix();
translate(0,0, -180);
box(45);
popMatrix();

pushMatrix();
translate(0,0,-360);
box(45);
popMatrix();
}
