int padding = 20;

void setup(){
  size(500,500);
}
void draw(){
  background(255);


  pushMatrix(); 
  translate(padding,padding);
  
  //x-axis
  line(0, height- (2* padding), width, height- (2* padding));
  
  //y-axis
  line(0, 0, 0 , height- (2* padding));
  
  createTicks(5);
  
  ellipseMode(CENTER);
  for(int i = 0; i < 5; i++){
    
    ellipse((i * width / 5) , height - (i * width / 5), 10,10);
  }
  
  popMatrix();
}

void createTicks(int numTicks){
  
  for(int i=0; i < numTicks; i++){ 
    //algorithm: countNumber * (whole / numberOfParts)
    
    line((i * width / 5) , height - 40, (i * width / 5) , height-30 );
      
  }

}
