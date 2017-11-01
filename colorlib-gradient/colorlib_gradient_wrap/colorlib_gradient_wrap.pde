import colorLib.calculation.*;
import colorLib.*;
import colorLib.webServices.*;

Gradient g;

void setup()
{
    size(450, 140);
    
    color[] c = new color[4];
    c[0] = color(255, 0, 0);
    c[1] = color(255, 255, 0);
    c[2] = color(255, 0, 128);
    c[3] = color(128, 0, 255);
    
    g = new Gradient(this, c, 450, true);
    
    noLoop();
}

void draw()
{
    background(0);
    noFill();
    for (int i = 0; i < g.totalSwatches(); i++) {
        stroke( g.getColor(i) );
        line(i, 0, i, height); 
    }
}
