class Rain extends Scene{
  
  Pattern pattern;
  Gradient gradient;
  Palette p;
  PApplet parent;
  float colorOffset = 0.0;
  RainParticleSystem ps;
  float lastTime = 0;
  float delay = 100;

  public Rain (Parameters params, int _length, int _width, int[] _height) {
    super( params, _length, _width, _height);
    this.name = "Rain";
    ps = new RainParticleSystem(new PVector(0,0,0));
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
    
    if(frameCount%16 == 0){
      ps.addParticle(); 
    }
   
    ps.run();
    
    for (int ribIndex = 0; ribIndex < sceneLength; ++ribIndex) {
      for (int strandIndex = 0; strandIndex < sceneWidth; ++strandIndex) {
        for (int pcbIndex = 0; pcbIndex < sceneHeights[ribIndex]; ++pcbIndex) {
          //float gradientHue = hue(gradient.getColor((int)((ps.getHue(ribIndex, strandIndex, pcbIndex)%360.0))));
          
          //float gradientHue = hue(p.getColor((int)((ps.getHue(ribIndex, strandIndex, pcbIndex)/360.0)*5)));
          
          float brightnessValue = ps.getBrightness(ribIndex, strandIndex, pcbIndex);
//          println(brightnessValue + " is " + pcbIndex);
          color NEW =color((colorOffset+((pcbIndex/(float)max(sceneHeights))*360))%360,80,brightnessValue);
          SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, NEW);
          
          ///this one
          //SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, ps.getColor(ribIndex, strandIndex, pcbIndex));
          
          
          //ps.clearColor(ribIndex, strandIndex, pcbIndex);
          ps.clearBrightness(ribIndex, strandIndex, pcbIndex);
          //ps.clearHue(ribIndex, strandIndex, pcbIndex);
        }
      }
    }
    colorOffset+=0.5; 
  }
}


class RainParticleSystem{
  ArrayList<RainParticle> particles;
  PVector origin;
  float[] brightVals;
  float[] hueVals;
  color[] particleColors;

  RainParticleSystem(PVector location) {
    origin = location.get();
    particles = new ArrayList<RainParticle>();
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
    particles.add(new RainParticle(origin));
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      RainParticle p = particles.get(i);
      p.update();
      
      updateColor(p);
      if (p.location.z>(max(pcbHeights)*strandDistance)) {
      //if (p.location.x>(ribLength*ribDistance)) {
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
 
   void updateColor (RainParticle _p){
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
//           color blended = addColor(particleColors[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex],color(_p.pHue,100,dark),dark);

             brightVals[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex] += dark;
             //brightVals[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex] = constrain(brightVals[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex],0,100);
             
           //hueVals[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex] = (int)hue(blended);
//           particleColors[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex] = blended;
         }
       }
     }
   }
 }


class RainParticle{
  PVector location;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  float bloom;
  int pHue;
  float ySpeed = 0.5;
  float zSpeed = 0.5;

  RainParticle(PVector l) {
    acceleration = new PVector(0.0,0.0,0.0);
    //velocity = new PVector(0.0,0.0,1.5);
    zSpeed = random(0.5,1.2);
    velocity = new PVector(0.0,0.0,1.0);
    //location = l.get();
    location = new PVector(random(ribLength*ribDistance),random(strandWidth*strandDistance),random(-15.0,-30.0));
    //location = new PVector(random(-30.0),random(strandWidth*strandDistance),random((max(pcbHeights)*strandDistance)));
    pHue = (int)random(360);
    //bloom = random(10,35);
    bloom = random(5,10);
  }
  void update() {
    location.add(velocity);
    //checkEdges();
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
}

