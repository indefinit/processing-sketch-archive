/**
 * SculptureManager
 * @author Kevin Siwoff
 * @version 1.0
 * @date 1-12-15
 * @description Singleton class for handling our Light management.
 * For more info see: http://en.wikipedia.org/wiki/Singleton_pattern
 * Note: This class is intentionally Java-y so I don't need to rely on
 * Processing deps
 */
import java.util.*;
import java.io.Serializable;

public class SculptureManager implements Serializable{

  //eventually provides setters and getters
  public int lightCount = 0;
   
  private int[] strandHeights;//using list for math utils
  private int[][][] sculptureColors;//color becomes int in .java
  
  //@TODO remove these.unnecessary
  public int[][][] addressIndexes;
  public int totalFixtureCount = 0;
  public int boxSize;

  //------------

  private static SculptureManager instance = null;
  protected SculptureManager(){}

  /**
   * thread-safe, lazy instantiation
   * @return {SculptureManager} the singleton instance
   * @TODO this could be optimized a bit since each call will need to synchronize
   * shouldn't be a big deal for now.
   */
  public synchronized static SculptureManager getInstance(){
    if(instance==null){
       instance = new SculptureManager();
      }
      return instance;
  }

  /**
   * initialize our sculpture. 
   * This is only done once!
   * @param {int} sculptureLength    [description]
   * @param {int} sculptureWidth     [description]
   * @param {int[]} _strandHeights   [description]
   */
  void initSculpture(int sculptureLength, int sculptureWidth, int[] _strandHeights){
    //if we've already created our sculptureColors array, get out of here!
    if (sculptureColors != null ) return;
    else {
      int max = 0;
      strandHeights = _strandHeights;
      for ( int i = 0; i < _strandHeights.length; i++) {
        if ( _strandHeights[i] > max) {
          max = _strandHeights[i];
        }
      }
      sculptureColors = new int[sculptureLength][sculptureWidth][max];
      
    }
  }

  /**
   * gets individual fixture color
   * @param {int} x coord
   * @param {int} y coord
   * @param {int} z coord
   * @return {int} color; hsv
   */
  public int getFixtureColor(int x, int y, int z){
    if(sculptureColors == null) return 0;
    else {
      return sculptureColors[x][y][z];
    }
  }
  /**
   * sets an individual fixture color
   * @param {int} x   x coord
   * @param {int} y   y coord
   * @param {int} z   z coord
   * @param {int} col color to set
   */
  public void setFixtureColor(int x, int y, int z, int col){
    if(sculptureColors == null) return;
    else {
      sculptureColors[x][y][z] = col;
    }
  }
}
