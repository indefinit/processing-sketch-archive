class Wave extends Scene{
  Pattern pattern;
  Gradient gradient;
  
  int colorPos = 0;
  float colorOffset = 0.0;
  float lastTime = 0;
  float interval = 0;
  float delay = 10;
  
  float startAngle = 0;
  float angleVel = 0.93;

  public Wave (Parameters params, int _length, int _width, int[] _height){
    super( params, _length, _width, _height);
    this.name = "Wave";
    this.pattern = new Pattern();
  }

  public void setup(){
    //inspired by Adobe Kuler
    color[] sunriseColors = { 
      color(45, 86, 95), 
      color(22, 93, 90), 
      color(28, 93, 95), 
      color(16, 98, 75), 
      color(13, 100, 49)};
    pattern.setPaletteColors(sunriseColors);
    
    gradient = pattern.makeGradient(pattern.getColorPalette(), 100, true);
  }

  public void updateScene(float t){
    //float dt = t - lastTime;
    
    startAngle += 0.015;
    float angle = startAngle;
    angleVel = map(mouseY,0,width,.2,1.5);
    for (int ribIndex = 0; ribIndex < sceneLength; ++ribIndex) {
      for (int strandIndex = 0; strandIndex < sceneWidth; ++strandIndex) {
        for (int pcbIndex = 0; pcbIndex < sceneHeights[ribIndex]; ++pcbIndex) {
          
          PVector currentPCBLocation = realSpace[ribIndex*sceneWidth*max(sceneHeights)+ strandIndex*max(sceneHeights) + pcbIndex];
          float x = realSpace[ribIndex*sceneWidth*max(sceneHeights)].x;
          float y = map(sin(angle*2), -1, 1, 0, sceneWidth*strandDistance);
//          float y = realSpace[2*max(sceneHeights)].y;
          float z = map(sin(angle), -1, 1, 0, max(sceneHeights)*strandDistance);
          PVector wave = new PVector (x, y, z);
          float dist = wave.dist(currentPCBLocation);
          float mouse = 0;
          mouse = map(mouseX, 0, width, 1, 100);
          //float bulge = 0;
          //bulge = map(sin(angle*2), -1, 1, 20, 50);
          float bright = map(dist, mouse, 0, 0, 100);
          bright = constrain(bright, 0, 99);
          
          
//          
//          float ribRange = map(ribIndex, 0, sceneLength, 0, 100);
//          colorPos = int((ribRange) % 100);
          
          //SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, gradient.getColor((int)bright));
          float hue = hue(gradient.getColor((int)bright));
          SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, color(hue,100,(int)bright));
        }
      }
      angle += angleVel;
    }
    //lastTime = t;
//    if(interval < millis()){
//      interval = millis() + delay;
//      colorOffset+=0.3;      
//    }
  }


}
