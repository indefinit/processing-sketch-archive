void brushPointist(){
  stroke(color(100), int(random(10,60)));
  fill(color(100), int(random(20,40)));
  rectMode(CENTER);
  rect(mouseX, mouseY, 10, 10);
  //line(mouseX, mouseY, memMouse[0], memMouse[1]);
  rectMode(CORNER);
   
}
 /*
void brushedSquares(){
    stroke(colorFromPalette(), random(1, 10));
    fill(colorFromPalette(), int(random(1,24)));
    //rectMode(CENTER);
    //translate(mouseX, mouseY);
    //translate(width/2, height/2);
    //rotate(PI/random(1.0,360.0));
    ellipse(mouseX, mouseY, int(random(16,24)), int(random(16,24)));
    line(mouseX, mouseY, memMouse[0], memMouse[1]);
    smooth();
    rectMode(CORNER);
}
 
void bezTang(){
  
  color baseColor = colorFromPalette();
   
  noFill();
  stroke(baseColor, 30);
  bezier(mouseX, mouseY, mouseX1, mouseY1, mouseX2, mouseY2, pmouseX, pmouseY);
  int steps = 6;
  fill(255);
  for (int i = 0; i <= steps; i++) {
    float t = i / float(steps);
    // Get the location of the point
    float x = bezierPoint(mouseX, mouseX1, mouseX2, pmouseX, t);
    float y = bezierPoint(mouseY, mouseY1, mouseY2, pmouseY, t);
    // Get the tangent points
    float tx = bezierTangent(85, 10, 90, 15, t);
    float ty = bezierTangent(20, 10, 90, 80, t);
    // Calculate an angle from the tangent points
    float a = atan2(ty, tx);
    a += PI;
    stroke(baseColor, 25);
    line(x, y, cos(a)*30 + x, sin(a)*30 + y);
    // This follwing line of code makes a line
    // inverse of the above line
    //line(x, y, cos(a)*-30 + x, sin(a)*-30 + y);
    stroke(baseColor, 50);
    fill(colorFromPalette(), 25);
    ellipse(x, y, 5, 5);
  }
}
*/