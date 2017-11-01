import java.util.Observable;

public class Parameters extends Observable{

  private int[] vals;
  public Parameters (int[] vals) {
    this.vals = vals;
  }
  public void setValues(int[] vals){
    this.vals = vals;
    setChanged();
    notifyObservers();
  }
  public int[] getValues(){
    return vals;
  }
}
