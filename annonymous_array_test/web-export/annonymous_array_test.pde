void setup(){
  doSomething(new int[]{
    map(0,100,0,1024),
    map(30,100,0,1024),
  });
}
void draw(){}
void doSomething(int[] data){
  println(data);
}

