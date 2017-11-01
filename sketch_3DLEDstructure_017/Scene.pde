/**
 * Scene Builder
 * @author Gabe Liberti, Kevin Siwoff
 * @version 1.0
 * @date 1-15-15
 * @description A generic Scene class.  To create your own scene, subclass this.
 * See Dusk.pde for more info.
 */
import java.util.Observer;
import java.util.Observable;

class Scene implements Observer{

  private Parameters params;
  color[] scenePalette;
  int sceneLength;
  int sceneWidth;
  int[] sceneHeights;
  protected String name;
  boolean doTransition;

  Scene(Parameters params, int _length, int _width, int[] _height){
     sceneLength = _length;
     sceneWidth = _width;
     sceneHeights = _height;
     this.params = params;
     doTransition = false;
  }

  //@TODO
  public void setup(){}
  
  /**
   * [update description]
   * @param  {[type]} Observable obs           [description]
   * @param  {[type]} Object     obj           [description]
   * @param  {[type]} float      t             [description]
   * @return {[type]}            [description]
   */
  public void update(Observable obs, Object obj){
    if(obs == params){
      println("Ive got some values: " + params.getValues());
    }
  }

  public void updateScene(float t){}

  public void setDoTransition(boolean bool){
    doTransition = bool;
  }

  public String getSceneName(){
      if (name == null) return "";
      else return name;
  }
}
