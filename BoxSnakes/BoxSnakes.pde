class Level {
  //our fields
  int numBoxes;
  ArrayList<PVector>boxPositions;
  ArrayList<Box> myBoxes;
  
  Level(int numBoxes, float startPointX){
  
    myBoxes = new ArrayList<Box>(numBoxes);
    
  }
  
  void sizeBox(int boxID, PVector boxSize){
    myBoxes.get(boxID).setSize(boxSize);
  }
  
  
  void sizeBoxes(PVector boxSize){
    for(int i = 0; i < numBoxes; i++){
      myBoxes.get(i).setSize(boxSize);
    }
  }
  
}

class SimpleLevel extends Level {
  
SimpleLevel(){
  super(12, 12.0);
}

}

ArrayList<Level> levels;
Level currentLevel;
int curLevelNumber;
boolean hasWon = false;

void setup(){
  levels = new ArrayList<Level>();
  
  for(int i =0; i < 10; i++){
    levels.add(new SimpleLevel(4+i));
  }
  
  currentLevel = levels.get(curLevelNumber);
  
}

void draw(){
  if(hasWon){
    currentLevel = levels.get(curLevelNumber++);
  }
}
