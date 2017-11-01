class Off extends Scene{

  public Off (Parameters params, int _length, int _width, int[] _height) {
    super( params, _length, _width, _height);
    this.name = "Off";
  }

  public void setup(){

  }

  public void updateScene(float t){
    for (int ribIndex = 0; ribIndex < sceneLength; ++ribIndex) {
      for (int strandIndex = 0; strandIndex < sceneWidth; ++strandIndex) {
        for (int pcbIndex = 0; pcbIndex < sceneHeights[ribIndex]; ++pcbIndex) {
          SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, color(0,0,0));
        }
      }
    }
  }
}
