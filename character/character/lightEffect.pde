// additive blends a sphere on the screen
void DrawLightGlow( PVector p, float sc, float b)
{
  //smooth();
  PVector vel = new PVector(2.,3.,0.);
   
  int cx = (int)p.x*ss.textScale() + ss.width()/2;
  int cy = (int)p.y*ss.textScale() + ss.height()*9/16;
  int sx = constrain(cx-(int)sc,0,ss.width());
  int sy = constrain(cy-(int)sc,0,ss.height());
  int ey = constrain(cy+(int)sc,0,ss.height());
  int ex = constrain(cx+(int)sc,0,ss.width());
  float csc = 1./(sc*sc);
  for (int y = sy; y <ey; y++)
  {
    float dy = (float)(y-cy);
    dy*=dy;
    int idx = y*ss.width() + sx;
    for (int x = sx; x < ex; x++,idx++)
    {
      float dx = (float)(x-cx);
      float iten = dx * dx + dy;
      iten *=csc;
      iten = constrain(1.-iten,0.,1.)*b;
      iten*=iten;
      iten*=iten;
      color c = pixels[idx];
      pixels[idx] = color(red(c) +iten*230,green(c) +iten*200,blue(c) +iten*180.,255);
    }
  }
//  noSmooth();
   
}
PVector NoiseOffset( float time, float offset)
{
  PVector p = new PVector(
    noise(time*2.+offset)*2.-1.,
    noise(time*2.+offset+1275.13)*2.-1.,
    noise(time*2.+offset+869.78)*2.-1.
    );
  p.normalize();
  return p;
}
class Streamer
{
  PVector col;
  PVector[] points;
  Streamer( PVector _c)
  {
    col=_c;
  }
  void update( PVector pos, float time, float offset )
  {
    PVector rpos = new PVector();
    rpos.set( NoiseOffset(time,offset));
    rpos.mult(30.);
    rpos.add(pos);
    if ( points == null )
    {
      points = new PVector[12];
      for (int i = 0; i < points.length;i++)
      {
        points[i]=new PVector();
        points[i].set(rpos);
      }
    }
    for (int i = points.length-1; i >0;i--)
      points[i].set(points[i-1]);
    points[0].set(rpos);
  }
  void Draw(PVector view )
  {
//    smooth();
    noFill();
    strokeWeight(2);
    beginShape();
 
    for(int i =0; i < points.length-1; i++)
    {     
      float w = 1. - (float)i/((float)points.length-1);
      w = sqrt(w);
      stroke(color(col.x,col.y,col.z,255.*w));
      curveVertex( points[i].x,  points[i].y,0.);
    }
    endShape();
    noStroke();
  }
  void DrawGlow()
  {
     DrawLightGlow( points[1], 18,1.);
  }
}

