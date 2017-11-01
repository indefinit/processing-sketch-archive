/**
 * Flash; a test scene to be played on the Antfood light sculpture
 * @author: Kevin Siwoff
 * @date: 1-26-15
 */
class SoundGlow extends Scene{
  Pattern pattern;
  Gradient gradient;
  
  int colorPos = 0;
  float colorOffset = 0.0;
  float lastTime = 0;

  public SoundGlow (Parameters params, int _length, int _width, int[] _height) {
    super( params, _length, _width, _height);
    this.name = "SoundGlow";
    this.pattern = new Pattern();
  }

  public void setup(){
    //inspired by Adobe Kuler
    color[] FlashColors = { color(219, 0, 100), 
      color(286, 0, 100), 
      color(325, 0, 100), 
      color(281, 0, 100), 
      color(243, 0, 100)};
    pattern.setPaletteColors(FlashColors);
    
    gradient = pattern.makeGradient(pattern.getColorPalette(), 100, true);
  }

  public void updateScene(float t){
    float totalAmplitude = 0.0;
    for(int i = 0; i < in.bufferSize() - 1; i++){
      totalAmplitude += abs(in.left.get(i));
    }
    float averageAmplitude = (totalAmplitude)/(float)in.bufferSize();
    float dt = t - lastTime;
    for (int ribIndex = 0; ribIndex < sceneLength; ++ribIndex) {
      for (int strandIndex = 0; strandIndex < sceneWidth; ++strandIndex) {
        for (int pcbIndex = 0; pcbIndex < sceneHeights[ribIndex]; ++pcbIndex) {
          
          colorPos = int((pcbIndex + colorOffset) % 100);
          
          color newCol = color(hue(gradient.getColor(colorPos)), saturation(gradient.getColor(colorPos)), brightness(int(colorOffset % 100)));
          color rise = color(0,0,colorOffset%100);
          SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, color(0,averageAmplitude*100,averageAmplitude*100));//gradient.getColor(colorPos));
          
//          if(frameCount%2==0){
//            SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, color(0,100,100));
//          }
//          if(frameCount%2==1){
//            SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, color(126,100,100));
//          }
        }
      }
    }
    lastTime = t;
    // if(dt % 1 == 0){
          
    // }
    colorOffset+=25.5;  
  }

}
