/*This example generates a single circle inscribed by a set of points*/


void setup() {
 size(600,600,P3D); //size of your intended pattern
 noLoop(); // don't need to use the draw loop
 
 /*unique name for your file. if left unchanged,
 will simply save file with current milisecond*/
 String fileName= "voronoi"+millis()+".pdf";
  
  beginRaw(PDF, fileName); //enables you to save your design to a pdf
  
   
   setupVoronoi(); // create your voronoi generator
    
    
  // =========GENERATE SPIRAL=============== //
   
   
  int centerLimit = 250; // variable to control the maximum diameter of the spiral
  float theta = 0; //like the diameter of your circle, but increases with every point in your spiral, producing the spiral effect.

 
  //this will draw one spiral 
  for(int k=0;k<centerLimit;k++){     
       theta +=1; //change to alter the tightness of your spiral
        drawPoint(width/2,height/2,theta,theta);
        
      } 
     
   
  
  
   drawVoronoi(); //renders your voronoi
   endRaw(); //ends the recording
 

}

void drawPoint(float orgX, float orgY, float theta, float diameter) { //function that generates and adds circular points
 
  float xPos = sin(theta)*diameter+orgX;
  float yPos = cos(theta)*diameter+orgY;
  
  voronoi.addPoint(new Vec2D(xPos, yPos));
}






