import colorLib.calculation.*;
import colorLib.*;
import colorLib.webServices.*;

Gradient g;

void setup()
{
    size(450, 240);
    
    color[] c = new color[2];
    c[0] = color(255, 0, 0);
    c[1] = color(255, 255, 0);
    
    g = new Gradient(this, c, 120);
    
    noLoop();
}

void draw()
{
    background(0);
    strokeWeight(2);
    noFill();
    for (int i = 0; i < g.totalSwatches(); i++) {
        stroke( g.getColor(i) );
        line(0, i*2, width, i*2);
    }
}
