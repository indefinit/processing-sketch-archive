void setup(){
  doSomething(new int[]{
    int(map(0,0,100,0,1024)),
    int(map(3,0,100,0,1024)),
  });
}
void draw(){}
void doSomething(int[] data){
  println(data);
}
