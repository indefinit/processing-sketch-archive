boolean dosave = false;

void setup(){
  size(1000,1000, P3D);
}
void draw(){
  background(255);
  float t=0.0, u=0.0;
  beginShape(POINTS);

    // vertex(x,y,-10);
    // vertex(x+1,y+1,-10);
    
    for(int x=0; x < width; x++){
      for(int y=0; y < height; y++){
        float _x = random(x-1,x);
        float _y = random(y-1,y);
        
        // vertex(x,y,-10);
        //vertex(_x+noise(u,t),_y+noise(u,t),0);
        vertex(_x+noise(t),_y+noise(t));
        u +=0.004;
      }
      t+=0.001;
    }
  endShape();
  if(dosave) {
    save("output.tif");
    dosave=false;
    println("ended tif render");
  }
}
void keyPressed() {
  if (key == 's') { 
    dosave=true;
    //redraw();
  }
}
 
void mouseReleased() {
  background(255);
}