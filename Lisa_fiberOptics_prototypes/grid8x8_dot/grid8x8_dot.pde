
import de.voidplus.leapmotion.*;
OPC opc;
PImage dot;
LeapMotion leap;
float dx, dy, dz;


void setup()
{
  size(640, 360);
  leap = new LeapMotion(this);
  
  // Load a sample image
  dot = loadImage("dot.png");

  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  // Map an 8x8 grid of LEDs to the center of the window
  opc.ledGrid8x8(0, width/2, height/2, height / 12.0, 0, false);
}

void draw()
{
  background(0);
  float hx = 0, hy = 0, hz = 0;
  for (Hand hand : leap.getHands()) {
     PVector position = hand.getStabilizedPosition();
     hx += position.x;
     hy += position.y;
     hz += position.z;
  }
  // Draw the image, centered at the mouse location
  float dotSize = height * 0.7;
  image(dot, hx - dotSize/2, hy - dotSize/2, hz*10.0, hz*10.0);
}

