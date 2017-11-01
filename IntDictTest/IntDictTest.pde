IntDict universeMap;

void setup() {
  size(200, 200);
  
  universeMap = new IntDict();
  String[] lines = loadStrings("universe-map.csv");
  for(int i = 0; i < lines.length; i++){
    String[] cols = split(lines[i], ",");
    if(cols.length > 0){
      universeMap.set(cols[0], Integer.parseInt(cols[1]));
    }
  }
  
  println(universeMap);

}

