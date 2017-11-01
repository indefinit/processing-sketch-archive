class Dots extends Scene{
  
  Pattern pattern;
  Gradient gradient;
  Palette p;
  PApplet parent;
  
  ParticleSystem ps;
  float lastTime = 0;
  float delay = 100;

  public Dots (Parameters params, int _length, int _width, int[] _height) {
    super( params, _length, _width, _height);
    this.name = "Dots";
    ps = new ParticleSystem(new PVector((sceneLength*ribDistance)/2,0,(max(sceneHeights)*-strandDistance)/4));
     this.pattern = new Pattern();
     this.p = new Palette(parent);
  }

  public void setup(){
    ps.setup();
    color[] funfetti = { 
      color(338, 85, 100), 
      color(198, 97, 98), 
      color(240, 0, 98), 
      color(56, 69, 93), 
      color(149, 100, 51)};
    pattern.setPaletteColors(funfetti);
    p.addColor(color(338, 85, 100));
    p.addColor(color(198, 97, 98));
    p.addColor(color(240, 0, 98));
    p.addColor(color(56, 69, 93));
    p.addColor(color(149, 100, 51));
    
    gradient = pattern.makeGradient(pattern.getColorPalette(), 360, true);
  }

  public void updateScene(float t){
    if (millis()>(lastTime+delay)){
      lastTime = millis();
    }
    
    if(frameCount%10 == 0){
      ps.addParticle(); 
    }
   
    ps.run();
    
    for (int ribIndex = 0; ribIndex < sceneLength; ++ribIndex) {
      for (int strandIndex = 0; strandIndex < sceneWidth; ++strandIndex) {
        for (int pcbIndex = 0; pcbIndex < sceneHeights[ribIndex]; ++pcbIndex) {
          //float gradientHue = hue(gradient.getColor((int)((ps.getHue(ribIndex, strandIndex, pcbIndex)%360.0))));
          
          //float gradientHue = hue(p.getColor((int)((ps.getHue(ribIndex, strandIndex, pcbIndex)/360.0)*5)));
          
          //float brightnessValue = ps.getBrightness(ribIndex, strandIndex, pcbIndex);
          
          //SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, color (gradientHue,80,brightnessValue));
          
          ///this one
          SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, ps.getColor(ribIndex, strandIndex, pcbIndex));
          
          
          //ps.clearColor(ribIndex, strandIndex, pcbIndex);
          //ps.clearBrightness(ribIndex, strandIndex, pcbIndex);
          //ps.clearHue(ribIndex, strandIndex, pcbIndex);
        }
      }
    }
  }
  class ParticleSystem{
  ArrayList<Particle> particles;
  PVector origin;
  float[] brightVals;
  float[] hueVals;
  color[] particleColors;

  ParticleSystem(PVector location) {
    origin = location.get();
    particles = new ArrayList<Particle>();
    brightVals = new float[ribLength * strandWidth * max(pcbHeights)];
    hueVals = new float[ribLength * strandWidth * max(pcbHeights)];
    particleColors = new color[ribLength * strandWidth * max(pcbHeights)];
  }
  
  void setup(){
    for (int ribIndex = 0; ribIndex < ribLength; ++ribIndex) {
      for (int strandIndex = 0; strandIndex < strandWidth; ++strandIndex) {
        for (int pcbIndex = 0; pcbIndex < pcbHeights[ribIndex]; ++pcbIndex) {
          brightVals[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex] = 0.0;
          hueVals[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex] = 0;
          particleColors[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex] = color(0,0,0);
        }
      }
    }
  }

  void addParticle() {
    particles.add(new Particle(origin));
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();
      
      updateColor(p);
      //if (p.location.z>(max(pcbHeights)*strandDistance)) {
      if (p.location.x>(ribLength*ribDistance)) {
        particles.remove(i);
      }
    }
  }
  
  int getBrightness(int ribIndex, int strandIndex, int pcbIndex){
      return (int)brightVals[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex];
  }
  
  void clearBrightness(int ribIndex, int strandIndex, int pcbIndex){
      brightVals[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex] *= 0.97;
   }
   
   int getHue(int ribIndex, int strandIndex, int pcbIndex){
     return (int)hueVals[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex];
   }
   
   void clearHue(int ribIndex, int strandIndex, int pcbIndex){
     hueVals[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex] = 0;
   }
   
   color getColor( int ribIndex, int strandIndex, int pcbIndex ) {
     return particleColors[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex];
   }
   
   void clearColor( int ribIndex, int strandIndex, int pcbIndex ) {
     particleColors[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex] = addColor(color(0,0,0),particleColors[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex],100);
   }
 
   void updateColor (Particle _p){
     PVector[] realSpace = getRealCoords(sceneLength, sceneWidth, sceneHeights);
     for (int ribIndex = 0; ribIndex < ribLength; ++ribIndex) {
       for (int strandIndex = 0; strandIndex < strandWidth; ++strandIndex) {
         for (int pcbIndex = 0; pcbIndex < pcbHeights[ribIndex]; ++pcbIndex) {
           PVector currentPCBlocation = realSpace[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex];
           float far = _p.location.dist(currentPCBlocation);
           //float mouse = 0;
           //mouse = map(mouseX, 0, width, 1, 30);
           float dark = map(far,_p.bloom, 0, 0, 100);
           float dying = 0;
           //dying = map(mouse, 1,300,1.0,0.0);
           dark = constrain(dark, 0, 100);
           
           //color baseColor = particleColors[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex];
           //color baseColor = color(hueVals[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex],100,100);
           color blended = addColor(particleColors[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex],color(_p.pHue,100,dark),dark);
           //hueVals[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex] = (int)hue(blended);
           particleColors[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex] = blended;
         }
       }
     }
   }
 };


class Particle{
  PVector location;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  float bloom;
  int pHue;
  float ySpeed = 0.5;
  float zSpeed = 0.5;

  Particle(PVector l) {
    acceleration = new PVector(0.0,0.0,0.0);
    //velocity = new PVector(0.0,0.0,1.5);
    zSpeed = random(0.1,.2);
    velocity = new PVector(2.0,0.0,zSpeed);
    //location = l.get();
    //location = new PVector(random(ribLength*ribDistance),random(strandWidth*strandDistance),random(-30.0));
    location = new PVector(random(-30.0),random(strandWidth*strandDistance),random((max(pcbHeights)*strandDistance)));
    pHue = (int)random(360);
    //bloom = random(10,35);
    bloom = random(15,30);
  }
  void update() {
    location.add(velocity);
    checkEdges();
  }
  
  void checkEdges(){
   if (location.y < 0){
    velocity.y = ySpeed;
   }
   if (location.y > strandWidth*strandDistance){
    velocity.y = -ySpeed;
   }
   if (location.z < 0){
    velocity.z *= -1; 
   }
   if (location.z > max(pcbHeights)*strandDistance){
    velocity.z *= -1; 
   }
   
  }
};
}