import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import processing.video.*;

Minim minim;
Movie myMovie;
AudioInput in;

void setup(){
  size(500,500);
  myMovie = new Movie(this, "3.Mousetraps.mp4");
  minim = new Minim(this);
  in = minim.getLineIn();
  myMovie.loop(); 
}

void draw(){
  background(255);
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
    line(i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50);
  }
}

void movieEvent(Movie movie) {
  movie.read();  
}
