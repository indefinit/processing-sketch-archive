class Boxball extends Scene{
  
  Pattern pattern;
  Gradient gradient;
  Palette p;
  PApplet parent;
  
  BoxParticleSystem ps;
  float lastTime = 0;
  float delay = 100;

  public Boxball (Parameters params, int _length, int _width, int[] _height) {
    super( params, _length, _width, _height);
    this.name = "Boxball";
    ps = new BoxParticleSystem(new PVector((sceneLength*ribDistance)/2,0,(max(sceneHeights)*-strandDistance)/4));
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
    
//    if(frameCount%10 == 0){
//      ps.addParticle(); 
//    }
   
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
          
          
          ps.clearColor(ribIndex, strandIndex, pcbIndex);
          //ps.clearBrightness(ribIndex, strandIndex, pcbIndex);
          //ps.clearHue(ribIndex, strandIndex, pcbIndex);
        }
      }
    }
  }
}


class BoxParticleSystem{
  ArrayList<BoxParticle> particles;
  PVector origin;
  float[] brightVals;
  float[] hueVals;
  color[] particleColors;
  color[] selections;
  int numParticles;
  boolean turbo;

  BoxParticleSystem(PVector location) {
    origin = location.get();
    particles = new ArrayList<BoxParticle>();
    brightVals = new float[ribLength * strandWidth * max(pcbHeights)];
    hueVals = new float[ribLength * strandWidth * max(pcbHeights)];
    particleColors = new color[ribLength * strandWidth * max(pcbHeights)];
    numParticles = 40;
    selections = new color[5];
    turbo = false;
  }
  
  void setup(){
    for (int i = 0 ; i < numParticles ; i++){
      particles.add(new BoxParticle(origin));
    }
    
    //purples
 
    
    //neutral tones    
//    selections[0] = color(34,60,100);
//    selections[1] = color(353,48,85);
//    selections[2] = color(339,37,67);
//    selections[3] = color(265,24,47);
//    selections[4] = color(214,44,48);

    //red line
    selections[0] = color(0,100,100);
    selections[1] = color(353,5,85);
    selections[2] = color(339,10,67);
    selections[3] = color(265,2,47);
    selections[4] = color(214,3,48);
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

//  void addParticle() {
//    particles.add(new BoxParticle(origin));
//  }

  void run() {
//    float totalAmplitude = 0.0;
//    for(int i = 0; i < in.bufferSize() - 1; i++){
//      totalAmplitude += abs(in.left.get(i));
//    }
//    float averageAmplitude = (totalAmplitude)/(float)in.bufferSize();
//    if(averageAmplitude>0.2){
//      turbo = true;
//    } else {
//      turbo = false; 
//    }
    
    for(int i = 0; i < in.bufferSize() - 1; i++){
      if(abs(in.left.get(i))>.3){
        turbo = true;
      }
    }
    
    for (int i = particles.size()-1; i >= 0; i--) {
      BoxParticle p = particles.get(i);
      if(turbo){
       p.turboBoost(); 
      }
      p.update();
      
      updateColor(p);
      //if (p.location.z>(max(pcbHeights)*strandDistance)) {
        
//      if (p.location.x>(ribLength*ribDistance)) {
//        particles.remove(i);
//      }
    }
    if(turbo){
     turbo = false; 
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
     particleColors[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex] = addColor(color(0,0,0),particleColors[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex],30);
   }
 
   void updateColor (BoxParticle _p){
     for (int ribIndex = 0; ribIndex < ribLength; ++ribIndex) {
       for (int strandIndex = 0; strandIndex < strandWidth; ++strandIndex) {
         for (int pcbIndex = 0; pcbIndex < pcbHeights[ribIndex]; ++pcbIndex) {
           PVector currentPCBlocation = realSpace[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex];
           float far = _p.location.dist(currentPCBlocation);
           float mouse = 0;
           mouse = map(mouseX, 0, width, 1, 60);
           float dark = map(far,mouse, 0, 0, 100);
           //float dark = map(far,_p.bloom, 0, 0, 100);
           float dying = 0;
           //dying = map(mouse, 1,300,1.0,0.0);

           dark = constrain(dark, 0, 100);
           
           //color baseColor = particleColors[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex];
           //color baseColor = color(hueVals[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex],100,100);
           int selector = (int)((_p.pHue/360.0)*5);
           color blended = addColor(particleColors[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex],color(hue(selections[selector]),saturation(selections[selector]),dark),dark);
           //hueVals[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex] = (int)hue(blended);
           particleColors[ribIndex*strandWidth*max(pcbHeights)+ strandIndex*max(pcbHeights) + pcbIndex] = blended;
         }
       }
     }
   }
 }


class BoxParticle{
  PVector location;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  float bloom;
  int pHue;
  float xSpeed = 0.0;
  float ySpeed = 0.5;
  float zSpeed = 0.5;

  BoxParticle(PVector l) {
    acceleration = new PVector(0.0,0.0,0.0);
    //velocity = new PVector(0.0,0.0,1.5);
    xSpeed = random(0.15, -0.15);
    ySpeed = random(0.15, -0.15);
    zSpeed = random(0.15,-0.15);
    velocity = new PVector(xSpeed,ySpeed,zSpeed);
    //location = l.get();
    //location = new PVector(random(ribLength*ribDistance),random(strandWidth*strandDistance),random(-30.0));
    location = new PVector(random(-10,ribLength*ribDistance+10),random(-10,strandWidth*strandDistance+10),random(-10,max(pcbHeights)*strandDistance+10));
    pHue = (int)random(360);
    //bloom = random(10,35);
    bloom = random(20,40);
  }
  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    checkEdges();
    //acceleration = PVector.mult(acceleration,.8);
    velocity = PVector.mult(velocity,.995);
  }
  
  void turboBoost(){ 
    
   //velocity = new PVector(xSpeed,ySpeed,zSpeed);
   velocity = PVector.mult(velocity,1.1);
  }
  
  void checkEdges(){
   if (location.x < -20){
    velocity.x *= -1; 
   }
   if (location.x > ribLength*ribDistance+20){
    velocity.x *= -1; 
   }
   if (location.y < -10){
    velocity.y *= -1;
   }
   if (location.y > strandWidth*strandDistance+10){
    velocity.y *= -1;
   }
   if (location.z < -20){
    velocity.z *= -1; 
   }
   if (location.z > max(pcbHeights)*strandDistance+20){
    velocity.z *= -1; 
   }
   
  }
}

