import colorLib.calculation.*;
import colorLib.*;
import colorLib.webServices.*;

Palette  p;
Gradient g;

void setup()
{
    size(450, 140);
    
    p = new Palette(this);
    
    for (int i = 0; i < 5; i++) {
        p.addColor( color(random(255), random(255), random(255) ) );
    }
        
    g = new Gradient(p, 450, true);
    
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
