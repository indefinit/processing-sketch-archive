/*This example illustrates a simple method to generate a set of deliberately placed
points to control the structure of a voronoi diagram. This particular example
combines spiral and circle structures to produce the overall design.*/


void setup() {
 size(600,600,P3D); //size of your intended pattern
 noLoop(); // don't need to use the draw loop
 
 /*unique name for your file. if left unchanged,
 will simply save file with current milisecond*/
 String fileName= "voronoi"+millis()+".pdf";
  
  beginRaw(PDF, fileName); //enables you to save your design to a pdf
  
   
   setupVoronoi(); // create your voronoi generator
    
    
   // =========GENERATE CIRCLES=============== //
    int outerCircle_center=7; // variable to set the center positions of the outer circle
    int diameter = 150; //diameter of your circles
    
   /*generates 5 evenly spaced points, one in the center of your stage and 4 in the outside corners
  as set by the outerCircle_center value. These points will be the center of the 5 circles in the final design */ 
   voronoi.addPoint(new Vec2D(width/2, height/2)); // adds a new point to your voronoi generator
   voronoi.addPoint(new Vec2D(width/outerCircle_center, height/outerCircle_center)); 
   voronoi.addPoint(new Vec2D(width-width/outerCircle_center, height/outerCircle_center));
   voronoi.addPoint(new Vec2D(width-width/outerCircle_center, height-height/outerCircle_center));
   voronoi.addPoint(new Vec2D(width/outerCircle_center, height-height/outerCircle_center));
 
         
  
    int drawLimit = 20; // we will define the circles by a set of evenly spaced points. This variable controls the number of points in your circles 

    for(int i=0;i<drawLimit;i++){ //loop over the number of points in the circle
   
       float _alpha = (float)Math.PI*2/drawLimit; // determines the degree position of your current point
  
       
       float cirtheta = i*_alpha; //current position on circle for your intended point
  
    
      drawPoint(width/2, height/2,cirtheta,diameter); //this will generate the center circle
    
      /*these calls will generate 4 outer circles with diameteriuses that are one half that of your center circle*/
      drawPoint(width/outerCircle_center, height/outerCircle_center,cirtheta,diameter/2);
      drawPoint(width-width/outerCircle_center, height/outerCircle_center,cirtheta,diameter/2);
      drawPoint(width-width/outerCircle_center, height-height/outerCircle_center,cirtheta,diameter/2);
      drawPoint(width/outerCircle_center, height-height/outerCircle_center,cirtheta,diameter/2);
    
 
   }
   
   // =========GENERATE SPIRALS=============== //
   
   
  int centerLimit = 150; // variable to control the diameter of the spiral
  int theta = 0; //increases with every point in your spiral, producing the spiral effect.

  //this will draw the four smaller spirals 
  
   theta=0; //reset theta 
  //this will draw the four larger spirals 
  for(int k=0;k<centerLimit;k++){     
       theta +=1;
        drawPoint(width/2,height/8,theta/2,theta/2);
        drawPoint(width/2,height-height/8,theta/2,theta/2);
         drawPoint(width/8,height/2,theta/2,theta/2);
       drawPoint(width-width/8,height/2 ,theta/2,theta/2);   
      } 
     
 
  
   drawVoronoi(); //renders your voronoi
   endRaw(); //ends the recording
 

}

void drawPoint(float orgX, float orgY, float theta, float diameter) { //function that generates and adds circular points
 
  float xPos = sin(theta)*diameter+orgX;
  float yPos = cos(theta)*diameter+orgY;
  
  voronoi.addPoint(new Vec2D(xPos, yPos));
}






