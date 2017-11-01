/**
 * Swarm; a potential scene to be played on the Antfood light sculpture
 * @author: Kevin Siwoff
 * @date: 1-27-15
 */
class Swarm extends Scene{
  Pattern pattern;
  Gradient gradient;

  ////////////////////////////
  //// FLOCK
  ///////////////////////////
  ArrayList<Boid> boids;
  
  int colorPos = 0;
  float colorOffset = 0.0;
  float lastTime = 0;
  float radius = 20.0;

  public Swarm (Parameters params, int _length, int _width, int[] _height) {
    super( params, _length, _width, _height);
    this.name = "Swarm";
    this.pattern = new Pattern();
    boids = new ArrayList<Boid>();
  }

  public void setup(){
    //inspired by Adobe Kuler
    color[] duskColors = { color(219, 44, 49), 
      color(286, 24, 55), 
      color(325, 21, 64), 
      color(281, 13, 68), 
      color(243, 23, 76)};
    pattern.setPaletteColors(duskColors);
    gradient = pattern.makeGradient(pattern.getColorPalette(), 100, true);
    
    //create 5 boids
    for (int i = 0; i < 10; i++) {
      createBoid(radius);
    }
  }

  public void updateScene(float t){
    //wow this is bad practice
    for (Boid boid : boids) {
      boid.run(boids);
    }

    float dt = t - lastTime;
    float val = 0.0;//brightness value
    for (int ribIndex = 0; ribIndex < sceneLength; ++ribIndex) {
      for (int strandIndex = 0; strandIndex < sceneWidth; ++strandIndex) {
        for (int pcbIndex = 0; pcbIndex < sceneHeights[ribIndex]; ++pcbIndex) {
          
          //loop through all boids and check distance to given fixture
          for(Boid b : boids){
            float distance = b.getPos().dist( new PVector(float(ribIndex), float(strandIndex), float(pcbIndex)));
            distance /= radius;
            if (distance < 1.0){

              val = 1.0 - distance;
            }
            float bright = max(brightness(gradient.getColor(0)), val * 100.0);
            color colAdjusted = color(hue(gradient.getColor(0)), saturation(gradient.getColor(0)), bright);
            SculptureManager.getInstance().setFixtureColor(ribIndex , strandIndex, pcbIndex, colAdjusted);
          }
        }
      }
    }
    lastTime = t;
    if(dt % 2 == 0){
      colorOffset+=0.3;      
    }
  }

  private void createBoid(float radius){
    boids.add(new Boid(0,0,0,radius));

    // boids.add(new Boid(( -sceneLength/2 ) * 50, ( -sceneWidth/2 ) * 50, 0, radius));
  }

};


//based on Dan Shiffman's
// Boid class
// Methods for Separation, Cohesion, Alignment added

class Boid {

  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

  Boid(float x, float y, float z, float rad) {
    acceleration = new PVector(0,0,0);
    velocity = PVector.random3D();
    location = new PVector(x,y,z);
    r = rad;
    maxspeed = 3;
    maxforce = 0.05;
  }

  public PVector getPos(){
    return location;
  }

  void run(ArrayList<Boid> boids) {
    flock(boids);
    update();
    borders();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }


  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  // Method to update location
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target,location);  // A vector pointing from the location to the target
    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);
    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }
  
  void render() {
    // Draw a triangle rotated in the direction of velocity
    //float theta = velocity.heading2D() + radians(90);
    fill(175);
    stroke(0);
    pushMatrix();
    translate(location.x,location.y, location.z);
    //rotate(theta);
    sphere(r);
    // beginShape(TRIANGLES);
    // vertex(0, -r*2);
    // vertex(-r, r*2);
    // vertex(r, r*2);
    // endShape();
    popMatrix();
  }

  // Wraparound
  void borders() {
    if (location.x < -r) location.x = width+r;
    if (location.y < -r) location.y = height+r;
    if (location.z < -r) location.z = 0;
    if (location.x > width+r) location.x = -r;
    if (location.y > height+r) location.y = -r;
    if (location.z > 0) location.z = -r;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 50.0f;
    PVector steer = new PVector(0,0,0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(location,other.location);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(location,other.location);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0,0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location,other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum,velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0,0);
    }
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0,0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location,other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.location); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the location
    } else {
      return new PVector(0,0);
    }
  }
}
