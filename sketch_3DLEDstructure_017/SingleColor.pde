class SingleColor extends Scene{
  color singleColor;
  
  int colorPos = 0;
  float colorOffset = 0.0;
  float lastTime = 0;
  float interval = 0;
  float delay = .1;

  public SingleColor (Parameters params, int _length, int _width, int[] _height) {
    super( params, _length, _width, _height);
    this.name = "SingleColor";
  }

  public void setup(){
    singleColor = color(30,100,100);
  }

  public void updateScene(float t){
    updateColor();
    for (int ribIndex = 0; ribIndex < sceneLength; ++ribIndex) {
      for (int strandIndex = 0; strandIndex < sceneWidth; ++strandIndex) {
        for (int pcbIndex = 0; pcbIndex < sceneHeights[ribIndex]; ++pcbIndex) {
          SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, singleColor);
        }
      }
    }
    if(interval < t){
      interval = t + delay;
      colorOffset+=0.3;      
    }
  }
  
  public void updateColor(){
    float newHue = map(mouseX, 0, width, 0, 360);
    float sat = map(mouseX, 0, width, 0, 360);
    float brit = map(mouseY, height, 0, 0, 100);
    singleColor = color(newHue,sat,brit);
  }

}
