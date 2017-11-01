/**
 * Dusk; a test scene to be played on the Antfood light sculpture
 * @author: Kevin Siwoff
 * @date: 1-26-15
 */
class Dusk extends Scene{
  Pattern pattern;
  Gradient gradient;
  
  int colorPos = 0;
  float colorOffset = 0.0;
  float lastTime = 0;

  public Dusk (Parameters params, int _length, int _width, int[] _height) {
    super( params, _length, _width, _height);
    this.name = "Dusk";
    this.pattern = new Pattern();
  }

  public void setup(){
    //inspired by Adobe Kuler
    color[] duskColors = { color(219, 44, 49), 
      color(286, 24, 55), 
      color(325, 21, 64), 
      color(281, 13, 68), 
      color(243, 23, 76)};
    pattern.setPaletteColors(duskColors);
    
    gradient = pattern.makeGradient(pattern.getColorPalette(), 100, true);
  }

  public void updateScene(float t){
    float dt = t - lastTime;
    for (int ribIndex = 0; ribIndex < sceneLength; ++ribIndex) {
      for (int strandIndex = 0; strandIndex < sceneWidth; ++strandIndex) {
        for (int pcbIndex = 0; pcbIndex < sceneHeights[ribIndex]; ++pcbIndex) {
          
          colorPos = int((pcbIndex + colorOffset) % 100);
          
//          SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, gradient.getColor(colorPos));
          SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, color((colorOffset+((ribIndex/(float)sceneLength)*360))%360,80,100));  
        }
      }
    }
    colorOffset+=0.7;
    lastTime = t;
    if(dt % 2 == 0){
      colorOffset+=2;      
    }
  }

}
