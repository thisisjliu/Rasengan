import org.openkinect.processing.*;//import library

int minimumDepthRange = 250;//setting minimum depth range to 250
int maximumDepthRange = 750;//setting maximum depth range to 750
int num = 3000; // number of particles
float[] x = new float[num];//its an array of x coordinate for the particle 
float[] y = new float[num];//its an array of y coordinate for the particle
float[] velx = new float[num];//an array of horizontal velocity values for the particles
float[] vely = new float[num];//an array of vertical velocity values for the particles
float[] accx = new float[num];//an array of horizontal acceleration values for the particles
float[] accy = new float[num];//an array of vertical acceleration values for the particles
float baseSaturation = 100;
float baseBrightness = 40;

String mode = "blue"; // mode of the particles
float mag = 45.0; //magnetism value for the attraction to the hand
int radius = 2; //radius of ellipses 
float momentum = 0.95; //momentum magnitude for the bound back
Kinect2 kinect2;//kinect2 device object

void setup() {
  kinect2 = new Kinect2 (this); //initialise kinect2 object
  kinect2.initVideo();//initialise video
  kinect2.initDepth();//initialise depth measurement
  kinect2.initDevice();//initialise kincet2 device

  size (512, 424, P3D);//setting frame size (maximum resolution)
  noStroke(); 
  fill(0);
  colorMode(HSB, 100);
  ellipseMode(RADIUS);
  background(255);
  blendMode(ADD);
  
  for(int i = 0; i < num; i++){//to initalise all arrays to 0
    x[i] = Math.round(random(width));//give it a random x position
    y[i] = Math.round(random(height));//give it a random y position
    velx[i] = 0;
    vely[i] = 0;
    accx[i] = 0;
    accy[i] = 0;
  }
}


void draw() {
  int[] rawDepth = kinect2.getRawDepth();//to get an array of depth values ranging from 0 - 4500
  PImage videoImage = kinect2.getVideoImage();//get to video image
  PImage depthImage = kinect2.getDepthImage();//get depth image
  background(0,0,0);
  image(videoImage, 0, 0, 512, 424);
  
  float closest = 4500;//initalise closet depth value the maximum depth value so we can loop through and check
  int closestX = 0;//the x coordinate of the image pixel with the closest of depth within the preset range
  int closestY = 0;//the y coordinate of the image pixel with the closest of depth within the preset range
  
  for (int x = 0; x < depthImage.width; x ++) {//double loop to loop through the pixels of the image
    for (int y = 0; y < depthImage.height; y ++) {
      int offset = x + y * kinect2.depthWidth;//to calculate the index offset of the depth array
      float d = rawDepth[offset];//get the depth value from the depth array using the depth index offset
      
      if (d > minimumDepthRange && d < maximumDepthRange) {//check if depth is within range
        if (d < closest) {//check if depth is closer than the closest
          closest = d;//override the closest depth value
          closestX = x;//override the closest x coordinate 
          closestY = y;//override the closest y coordinate 
        }
      }
    }
  }
  
  for(int i = 0; i < num; i++){//loop through all the particles
    float distance = dist(closestX, closestY, x[i], y[i]); //calculate the distance between the particle and the closest pixel
    
    if(distance > 3) { //if distance is bigger than 3, 
      accx[i] = mag * (closestX - x[i]) / (distance * distance); //then calcute the horixontal acceleration towards the closer point 
      accy[i] = mag * (closestY - y[i]) / (distance * distance);//then calcute the vertical acceleration towards the closer point 
    }
    velx[i] += accx[i]; //apply the acceleration to velocity
    vely[i] += accy[i]; 
    
    velx[i] = velx[i] * momentum;//apply momentum to velocity
    vely[i] = vely[i] * momentum;
    
    x[i] += velx[i];//calculte the next position of the x coordinate using the velocity
    y[i] += vely[i];
    
    float hueValue = getHueValue(distance); // calculate hue value according to distance
    
    fill(hueValue, baseSaturation, baseBrightness);//changing particle colour base on time
    ellipse(x[i],y[i],radius,radius);//draw the particles
  }
}

float getHueValue(float distance) {
  if (mode == "blue") { // if mode is blue
    return random(0, 100); // get a random float from 0 - 100
  }
  if (mode == "red") { // if mode is red
    return random(300, 359); // get a random float from 300 - 359
  }
  if (mode == "rainbow") { // if mode is rainbow
    return (distance * 359) / 664.0; // get a hue value from the distance
  }
  return 0.0;
}

void keyPressed() { // Change mode with different key press
  if (key == 'b'){
    mode = "blue";
  }
  
  if (key == 'r'){
    mode = "red";
  }
  
  if (key == 'p') {
      mode = "rainbow";
  }
}
