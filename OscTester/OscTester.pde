OscSender sender;

void setup(){
  size(500,500);
//  sender = new OscSender();
  sender = new OscSender("127.0.0.1", 4000);  
}
void draw(){
  background(0);
}

void mousePressed(){
  sender.sendOsc(sender.buildMessage("/hello", mouseX));
  
}
