int count;

void setup(){
  size(480,272);
  textSize(128);
  frameRate(1);
  colorMode(HSB, 60,100,100);
}
void draw(){
  if(count >=60){
    exit();
  }
  background(second(), 100,100);
  textAlign(CENTER, CENTER);
  translate(width/2 - 24, height/2 - 24);
  text(nfs(second(), 1), 0, 0);
  saveFrame("frame-"+nfs(second(),1)+".png");
  count++;
}
