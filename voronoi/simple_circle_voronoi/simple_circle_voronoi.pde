/*This example generates a single circle inscribed by a set of points*/


void setup() {
 size(600,600,P3D); //size of your intended pattern
 noLoop(); // don't need to use the draw loop
 
 /*unique name for your file. if left unchanged,
 will simply save file with current milisecond*/
 String fileName= "voronoi"+millis()+".pdf";
  
  beginRaw(PDF, fileName); //enables you to save your design to a pdf
  
   
   setupVoronoi(); // create your voronoi generator
    
    
   // =========GENERATE CIRCLE=============== //
   
    int diameter = 150; //diameter of your circles
    
   
   voronoi.addPoint(new Vec2D(width/2, height/2)); // adds a new point to your voronoi at the center of the screen
  
    int drawLimit = 20; // we will define the circles by a set of evenly spaced points. This variable controls the number of points in your circles 

    for(int i=0;i<drawLimit;i++){ //loop over the number of points in the circle
   
       float _alpha = (float)Math.PI*2/drawLimit; // determines the degree position of your current point
  
       float cirtheta = i*_alpha; //current position on circle for your intended point
 
      drawPoint(width/2, height/2,cirtheta,diameter); //this will generate the center circle

   }
   
  
  
   drawVoronoi(); //renders your voronoi
   endRaw(); //ends the recording
 

}

void drawPoint(float orgX, float orgY, float theta, float diameter) { //function that generates and adds circular points
 
  float xPos = sin(theta)*diameter+orgX;
  float yPos = cos(theta)*diameter+orgY;
  
  voronoi.addPoint(new Vec2D(xPos, yPos));
}






