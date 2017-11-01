import processing.pdf.*; 
import toxi.geom.*;
import toxi.geom.mesh2d.*;

import toxi.util.*;
import toxi.util.datatypes.*;

import toxi.processing.*;

// ranges for x/y positions of points
FloatRange xpos, ypos;

// helper class for rendering
ToxiclibsSupport gfx;

// empty voronoi mesh container
Voronoi voronoi = new Voronoi();

// optional polygon clipper
PolygonClipper2D clip;

// switches
boolean doShowPoints = true;
boolean doShowDelaunay;
boolean doClip;
boolean doSave;

void setupVoronoi() {

    
  
  
 
  smooth();
  // focus x positions around horizontal center (w/ 33% standard deviation)
  xpos=new BiasedFloatRange(0, width, width/2, 0.333f);
  // focus y positions around bottom (w/ 50% standard deviation)
  ypos=new BiasedFloatRange(0, height, height, 0.5f);
  // setup clipper with centered rectangle
  clip=new SutherlandHodgemanClipper(new Rect(width*0.125, height*0.125, width*0.75, height*0.75));
  gfx = new ToxiclibsSupport(this);
  textFont(createFont("SansSerif", 10));
  
 
  


  
}

void drawVoronoi() {
  if (doSave) {
    saveFrame("voronoi-" + DateUtils.timeStamp() + ".png");
  }
rect(0,0,width,height);
   // background(255);
    stroke(0); //sets your line color
  strokeWeight(3); //sets your line width
 // stroke(0);
  noFill();
  // draw all voronoi polygons, clip them if needed...
  for (Polygon2D poly : voronoi.getRegions()) {
    if (doClip) {
     gfx.polygon2D(clip.clipPolygon(poly));
    } 
    else {
      gfx.polygon2D(poly);
    }
  }
  // draw delaunay triangulation
  if (doShowDelaunay) {
    stroke(0, 0, 255, 50);
    beginShape(TRIANGLES);
    for (Triangle2D t : voronoi.getTriangles()) {
      gfx.triangle(t, false);
    }
    endShape();
  }
  // draw original points added to voronoi
  if (doShowPoints) {
    fill(255, 0, 255);
    noStroke();
//    for (Vec2D c : voronoi.getSites()) {
//      ellipse(c.x, c.y, 5, 5);
//    }
  }




  if (doSave) {
    endRecord();
    doSave = false;
  }
}




