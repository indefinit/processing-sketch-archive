class SoundRibs extends Scene{
  color singleColor;
  
  int colorPos = 0;
  float colorOffset = 0.0;
  float lastTime = 0;
  float interval = 0;
  float delay = .1;
  float[] binIntensity = new float[28];

  public SoundRibs (Parameters params, int _length, int _width, int[] _height) {
    super( params, _length, _width, _height);
    this.name = "SoundRibs";
  }

  public void setup(){
    singleColor = color(30,100,100);
    for(int i = 0 ; i < binIntensity.length ; i++){
    binIntensity[i] = 0; 
    }
  }

  public void updateScene(float t){
    for(int i = 9; i < fftLog.avgSize()-7; i++)
    {
      //centerFrequency    = fftLog.getAverageCenterFrequency(i);
      
      // how wide is this average in Hz?
      float averageWidth = fftLog.getAverageBandWidth(i);   
      //println(fftLog.getAvg(i)*fftLog.getAverageBandWidth(i) + " is " + centerFrequency);
      binIntensity[i-9] += fftLog.getAvg(i)*3;
      binIntensity[i-9] = constrain(binIntensity[i-9],0,100);
      if(binIntensity[i-9]<10){
       binIntensity[i-9]=0; 
      }
      }
    
    updateColor();
    for (int ribIndex = 0; ribIndex < sceneLength; ++ribIndex) {
      for (int strandIndex = 0; strandIndex < sceneWidth; ++strandIndex) {
        for (int pcbIndex = 0; pcbIndex < sceneHeights[ribIndex]; ++pcbIndex) {
          SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, color((ribIndex/(float)sceneLength)*360,80,binIntensity[ribIndex]));
          binIntensity[ribIndex]*=.994;
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
