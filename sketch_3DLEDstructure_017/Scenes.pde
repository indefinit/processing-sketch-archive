/**
 * Scenes class
 * @description: a generic scene manager.  Made for read-only operations.
 * Usage: create a new instance of this in your main app class.
 */
import java.util.Arrays;
import processing.core.*;

public class Scenes {
  private ArrayList<Scene> _scenes; //polymorphic ArrayList of scenes
  
  //THIS SHOULD NOT BE HERE BUT I'M BEING LAZY RIGHT NOW
  int ribLength = 28;
  int strandWidth = 5;
  int[] pcbHeights =
    {1,1,2,3,3,
    4,3,3,4,6,
    7,6,5,4,4,
    6,7,8,8,7,
    6,5,4,5,3,
    2,1,1};

  public Scenes (Parameters params) {

    _scenes = new ArrayList<Scene>(Arrays.asList(
        //... list our scenes here
        //comma separated like this:
        //new AwesomeSceneClass(), new AnotherAwesomeSceneClass()...
        new Off(params, ribLength, strandWidth, pcbHeights)
        ,new Boxball(params, ribLength, strandWidth, pcbHeights)
        ,new SoundRibs(params, ribLength, strandWidth, pcbHeights)
        ,new SoundGlow(params, ribLength, strandWidth, pcbHeights)
        ,new Wave(params, ribLength, strandWidth, pcbHeights)
        ,new Rain(params, ribLength, strandWidth, pcbHeights)
        ,new Dusk(params, ribLength, strandWidth, pcbHeights)
        ,new Swarm(params, ribLength, strandWidth, pcbHeights)
        ,new Flash(params, ribLength, strandWidth, pcbHeights)
        ,new Dips(params, ribLength, strandWidth, pcbHeights)
        ,new Dots(params, ribLength, strandWidth, pcbHeights)
        ,new SingleColor(params, ribLength, strandWidth, pcbHeights)
      ));
    for (Scene scene : _scenes) {
      params.addObserver(scene);      
    }

  }


  public Scene getScene(int index){
    return _scenes.get(index);
  }

  /**
   * gets scene name from given scene
   * @param  {int} int index         scene number starting at 0 index
   * @return {String}                Name
   */
  public String getSceneName(int index){
    return (String) _scenes.get(index).getSceneName();
  }

  public int getTotalSceneCount(){
    return _scenes.size();
  }

  public ArrayList<Scene> getScenes(){
    return _scenes;
  }
}
