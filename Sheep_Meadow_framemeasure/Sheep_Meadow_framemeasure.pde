boolean widthInside = true;

float mHeight = 2.75;//our module height in inches
float mWidth = 3.875;//our module width in inches
float mDepth = 0.625;// our module depth in inches
float mSpacing = 0.5; // spacing between modules
float totalModuleWidth = mWidth + (2.0 * mSpacing);

float innerDiaWidth = 179.52;//width of painting
float innerDiaHeight = 107.2;//height of painting
int numModulesWide;
int numModulesTall;

float outerDiaWidth, outerDiaHeight;
void setup(){
  
  if(widthInside){
    numModulesWide = ceil(innerDiaWidth / totalModuleWidth );
    numModulesTall = ceil((innerDiaHeight + (2.0 * mHeight)) / totalModuleWidth);
    
    outerDiaWidth = (numModulesWide * totalModuleWidth) + (2.0 * mHeight);
    outerDiaHeight = numModulesTall * totalModuleWidth; 
  }
  else {
    numModulesWide = ceil((innerDiaWidth + (2.0 * mHeight)) / totalModuleWidth );
    numModulesTall = ceil(innerDiaHeight/ totalModuleWidth);
    
    outerDiaWidth = numModulesWide * totalModuleWidth;
    outerDiaHeight = (numModulesTall * totalModuleWidth) + (2.0 * mHeight);
  }
  
  println("width inside mode ", widthInside);
  println("total module width ", totalModuleWidth);
  println("we need at minimum " + numModulesWide + " modules across");
  println("we need at minimum " + numModulesTall + " modules vertical");
  

  println("outer width is " + outerDiaWidth + 
  ", outer height is " + 
  outerDiaHeight);  

    
}
