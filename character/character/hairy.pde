/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/12399*@* */
/* !do not delete the line above, required for linking your tweak if you re-upload */
// Draws a hair character which can have his hair settings changed
//
//import processing.opengl.*;
 
// TODO : make fit the screen better
// and make dependant on screen size
Curve[] hairball;
Curve[] lawn;
GazeControl g_gaze[] = new GazeControl[7];
Eyes g_eyes = new Eyes();
Movement g_movement = new Movement();
boolean g_drawHelp= false;
 
float g_BallRadius = 100.;
HairStyle g_LawnStyle = new HairStyle( 0.4,50.4,3.71,0.5,  0.25,0.f,0.3f, 1.,3.) ;
 
final int NumHairs = 128;
final int NumLawnHairs = 96;
void GenHair()
{
    randomSeed(146914036);
    hairball =  GenerateCurvesOnSphere(NumHairs, g_BallRadius,20.,
                g_HairStyle.mohawk,g_HairStyle.face, g_HairStyle.messy,
                g_HairStyle.clumpStrength, g_HairStyle.clumpScale,0. );
                 
    lawn = GenerateCurvesOnSphere(NumLawnHairs, width * 0.4,20.,
                 g_LawnStyle.mohawk,g_LawnStyle.face, g_LawnStyle.messy,
                g_LawnStyle.clumpStrength, g_LawnStyle.clumpScale,100.  );
}
PVector g_Light;
SuperSampler ss;
WorkQueue g_renderQueue;
void setup()
{
  size(700,400, P3D);//
  ss=new SuperSampler();
  int numproc=Runtime.getRuntime().availableProcessors();
  g_renderQueue = new  WorkQueue(numproc);
  if (numproc<=2){
    ss.useDirect(true);
  }
  GenHair();
   
  for (int i = 0; i < 7; i++)
    g_gaze[i] = new GazeControl();
          
  for (int i= 0; i < g_Streamer.length;i++)
    g_Streamer[i] =new Streamer(new PVector(255.0,230.,196));
     
  g_Light = new PVector(0.707f,-0.707f,0.1);
   g_Light.normalize();
}
HairStyle  g_HairStyle = new HairStyle();
 
float g_LightAngle = 0.55f;
void mouseDragged()
{
  if ( g_HairStyle.ApplyHairCutInput() )
    GenHair();
   g_LightAngle = g_HairStyle.LightAngle;
}
float glastVel = 0.;
void mouseReleased()
{
  float mx  =((float)(mouseX)/(float)width)*2.-1.;
  float my = ((float)(mouseY)/(float)height)*2.-1.;
  float d = mx*mx + my*my;
  if ( d < 0.1)
    g_movement.Hit(800);
}
 
boolean g_DrawBabies = false;
boolean g_HairAnim = false;
boolean g_drawLawn = false;
float g_shaveStength = 0.;
void keyReleased()
{
  g_shaveStength = 0.0f;
}
void keyPressed()
{
  if ( keyCode >='0' && keyCode <='9')
  {
    int code = keyCode-'0';
    g_HairStyle = PresetHairStyles[code%PresetHairStyles.length];
     GenHair();
    return;
  }
  if ( key =='A' || key =='a')
    g_HairAnim = !g_HairAnim ;
  else if ( keyCode =='H' || keyCode == 'h')
    g_drawHelp = !g_drawHelp;
  else if (keyCode =='C' || keyCode =='c')
    g_shaveStength = 0.25f;
  else if (keyCode =='L' || keyCode =='l')
    g_drawLawn = !g_drawLawn;
  else if( key=='s')
    ss.useDirect(!ss.m_useDirect);
  else if  ( keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT)
    g_DrawBabies = !g_DrawBabies;
     
}
 
PVector hairColors[]= {
new PVector(.137, .137, .137),  // poddle hair
new PVector(.81,.81,.81),
new PVector(.037, .037, .037),  // gorrilla hair
new PVector(.2, .2, .2),
new PVector(.1, .3, .5),
new PVector(.1, .55, .05),
new PVector(.109, .037, .007),
new PVector(.519, .325, .125),
new PVector(.3, .037, .1),
new PVector(.3, .6, .75),
new PVector(.3, .01, .3),
new PVector(.75, .4, .75),
 
};
color BackgroundColor = color(196,196,196);
 
void drawDropShadow(float rad, float s, PVector dir, float d  )
{
  noLights();
  beginShape(TRIANGLE_FAN);
  int c =(int)( (1.-s)*255.);
  fill(c,c,c,255);
  vertex(0.0f,100.001,0.0f);  
 fill(196,196,196,255);
  for (float ang = 0.; ang <= (2.0f * PI+0.001); ang += 2.0f * PI/32.)
  {
    float ox = sin(ang);
    float oz = cos(ang);
    float ex = max(ox*dir.x + oz*dir.z,0.)*d;
    float r = rad + ex;
    vertex(ox*r, 100.001,oz*r);
  }
  endShape();
}
PVector g_Light2;
Streamer[] g_Streamer= new Streamer[8];
void DrawLawn()
{
   HairShader hs = new HairShader(hairColors[6],hairColors[7],// new PVector(0.1,0.2,0.1),new PVector(0.7,1.5,0.2),
                       new PVector(0.,0.,0.), 99.0f + g_LawnStyle.Length, 99.0f ,
                        g_Light, g_Light2);
   
    beginShape(QUADS);
    PVector view = new PVector(0.f,0.,1.);
  int count =0;
  for(int i =0; i < lawn.length; i++)
      count +=  DrawStack(lawn[i], view, hs, g_LawnStyle.rootWidth, g_LawnStyle.tipWidth, 32 );
       
  endShape(QUADS);
}
float gLastTilt= 0;
int DrawHairBall( float time,float quality, boolean isLow,
              GazeControl gaze , float rotateAmt, int skip,
               float tickleAmount, PVector pushPoint )
{
  pushMatrix();
 float extraL = g_HairStyle.Length -g_movement.y;
 float shadS = constrain(extraL/40+.5,0.5,1.);
 float shadR = constrain( (120+ extraL),0,80 + g_HairStyle.Length );
  PVector nl = new PVector(-sin(PI*g_LightAngle),-0.707f,cos(PI*g_LightAngle));
   nl.normalize();
   if ( g_drawLawn == false)
     drawDropShadow(shadR, shadS, nl, shadR);
       
 // drawDropShadow(constrain( (60+ g_HairStyle.Length -g_movement.y),0,60+ g_HairStyle.Length) );
  float vel = -g_movement.yvel*0.01;
  glastVel = 0.8*glastVel + 0.2*vel;
 
  // select hair color at random and blend
  float hairColorIndex = noise(time*0.05+12497)*10.;
  float hI = floor(hairColorIndex);
  float hbl = hairColorIndex - hI;
  hbl = hbl*hbl*(3.-2.*hbl);
  int hl =hairColors.length;
  int hIdx0 = ((int)hI*2 )% hl;
  int hIdx1 = ((int)(hI+1)*2 )% hl;
  PVector rootColor = lerp(hairColors[hIdx0], hairColors[hIdx1], hbl );
  PVector tipColor = lerp(hairColors[hIdx0+1], hairColors[hIdx1+1], hbl );
 
  // rotate to face
  float rot = gaze.lx*.25+rotateAmt;
  
  PVector view = new PVector(sin(rot),0.f,-cos(rot));
  g_Light = new PVector(sin(rot+PI*g_LightAngle),-0.707f,-cos(rot+PI*g_LightAngle));
   
  float rimOffset = -.3;
  g_Light2 = new PVector(sin(rot+PI*(g_LightAngle +rimOffset)),-0.707f,-cos(rot+PI*(g_LightAngle+rimOffset))); 
  g_Light.normalize();
    
   float floppyFactor = constrain((2.-g_HairStyle.stiffness)*.5,0.,1.);
   HairShader hs = new HairShader( rootColor,tipColor,
                       new PVector(0.,0.,0.), 99.0f + g_HairStyle.Length*floppyFactor, 99.0f ,
                        g_Light, g_Light2);
                       
  rotateY(rot);
   
  rotateX(-gaze.ly*.25);
   
  translate( 0, -g_movement.y,0);
   
  float tiltamt = noise(time*2.+12497);
  tiltamt = tiltamt*tickleAmount*-pushPoint.x/g_BallRadius * 0.1;
  gLastTilt = gLastTilt * 0.7 + tiltamt*0.3;
  rotateZ(gLastTilt);
 
  int step = skip;
  float rw= g_HairStyle.rootWidth;
  float tw = g_HairStyle.tipWidth;
  if ( isLow )
  {
    rw *=3;
    tw *=2;
  }    
   
//  noStroke();
  beginShape(QUADS);
  int count =0;
  for(int i =0; i < hairball.length; i+=step)
    if (IsVis(hairball[i], view) )
      count +=  DrawStack(hairball[i], view, hs, rw, tw, quality );
       
  endShape(QUADS);
 
 
noStroke();
  lights();
  sphereDetail( isLow ? 8 : 16 );
   
  fill(0);
  sphere( 100.);
  g_eyes.Draw(gaze, time, tickleAmount); 
 
  noLights();
  popMatrix();
  return count;
}
PVector g_pushPoint;
void draw()
{ 
    
  float time = (float)millis()/1000.;
 
PVector pushPoint = new PVector((float)(mouseX) - (float)width*.5,
                                  (float)(mouseY) - (float)height*9/16,
                                  0.);
   
 
  // project onto sphere
  pushPoint.z = g_BallRadius*g_BallRadius - pushPoint.x*pushPoint.x - pushPoint.y*pushPoint.y;
  pushPoint.z = sqrt(max(pushPoint.z,0.00001));
   
  PVector fireFlyPoint = new PVector();
if ( g_drawLawn)
{
   
  fireFlyPoint.x = g_gaze[0].lx*width/2;
  fireFlyPoint.y = g_gaze[0].ly*height/2;
  fireFlyPoint.z = g_BallRadius*g_BallRadius - fireFlyPoint.x*fireFlyPoint.x - fireFlyPoint.y*fireFlyPoint.y;
  fireFlyPoint.z = sqrt(max(fireFlyPoint.z,0.00001));
 
 PVector off = NoiseOffset( time, 0.125);
  off.mult(2.);
  //fireFlyPoint.add(off);
  pushPoint = fireFlyPoint;
 }
  
  float tickleAmount = pushPoint.mag()<110. ? 1. : 0;
  float hopChance = pushPoint.mag()<110. ? 0.2 : 0.01;
  if ( (random(0,1) < hopChance) && g_movement.y ==0.)
      g_movement.Hit(random(20,200));
       
  if ( tickleAmount > 0.)
    cursor(HAND);
   else
    cursor(CROSS);
     
  PVector pdir = new PVector();
  pdir.set(pushPoint);
  pdir.normalize();
  pdir.mult(6.);
  pushPoint.add(pdir);
  g_pushPoint =pushPoint;
   
   
  g_movement.Update(time);
  for (int i = 0; i < 7; i++)
    g_gaze[i].update(time+15897*i);
 
  float groundH = g_movement.y+100.;
  float rotateAmt =0.f;
  if ( g_HairAnim)
  {
     float hat = time*.2;
     float hI = floor(hat);
     float hbl = hat - hI;
     hbl = hbl*hbl*(3.-2.*hbl);
     hbl = hbl*hbl*(3.-2.*hbl);
    int hl =PresetHairStyles.length;
    g_HairStyle.Lerp( PresetHairStyles[ (int)hI%hl],  PresetHairStyles[ ((int)hI+1)%hl], hbl);
    GenHair();
    rotateAmt =hat*2.*PI*.5;
  }
   
  float rot = g_gaze[0].lx*.25+rotateAmt;
  PVector view = new PVector(sin(rot),0.f,-cos(rot));
   
   
 
 
 if ( g_drawLawn)
{
  for (int i= 0; i < g_Streamer.length;i++)
    g_Streamer[i].update( fireFlyPoint, time, i*125.739f);
   
  }
 ApplyVelocityToCurves( hairball,new PVector(0.f,glastVel -0.96f,0.),
         g_HairStyle.stiffness, g_HairStyle.Length, groundH, pushPoint, view, g_shaveStength );
 
 
 
ss.beginDraw(false);
  noStroke();
     
  if ( g_drawLawn )
      background(color(0,0,0));
  else
    background(color(196,196,196));
   
   
  translate( width/2,  height*9/16); 
  int numSegs = DrawHairBall( time,32., false, g_gaze[0], rotateAmt, g_DrawBabies ? 2 : 1,
                                tickleAmount, pushPoint);
 
  // draw babies
  int numBabies = g_DrawBabies ? 6 :0;
  for (int i =0 ; i < numBabies;i++)
  {
    pushMatrix();
    translate( -(i*width)/8 + width/2 - 40 + ((i > 2) ? -140.: 0.), 0);
    scale(0.3);      
    numSegs +=DrawHairBall( time+15897*(i+1),100.,true,  g_gaze[i+1], 
                    rotateAmt, 6, 0., pushPoint);
 
    popMatrix();
  }
   
  if ( g_drawLawn )
  {
   ApplyVelocityToCurves( lawn,new PVector(-0.0,-0.96f,0.),
         g_LawnStyle.stiffness, g_LawnStyle.Length, groundH, pushPoint, view, 0. );
 
    DrawLawn();
     
    for (int i= 0; i < g_Streamer.length;i++)
      g_Streamer[i].Draw(view);
     
    loadPixels();
    DrawLightGlow( fireFlyPoint, 60.,.75);
    for (int i= 0; i < g_Streamer.length;i++)
      g_Streamer[i].DrawGlow();
  //  updatePixels(); 
  }
 
  ss.endDraw();
 
 
  g_renderQueue.Wait(); 
  //updatePixels();   
    
  if ( g_drawHelp  )
  {
    textMode(SCREEN);
    String hairDescription = g_HairStyle.GetDescription();
    text(  "| Fps " + (int)frameRate + "| NumSegs " + numSegs, 20,height-40);
      text(  hairDescription , 20,height-20);
  }
}

