FreeBody test;
Body body;
SaveData dat;
SaveData phi1Save;

//INPUT PARAMETERS_______________________________________________________________________
int resolution = (int)pow(2,4);              // number of grid points spanning radius of vortex
int xLengths = 12;                // (streamwise length of computational domain)/(resolution)
int yLengths = 8;                 // (transverse length of computational domain)/(resolution)
int zoom=5;
int area = 600000;                // window view area
int Re = 100000;                   // Reynolds number
//////float St = 0.2;
float mr = 2;                     // mass ratio = (body mass)/(mass of displaced fluid)
//_______________________________________________________________________________________

void settings(){
  // set window view area 
  float s = sqrt(area*xLengths/yLengths);
  size((int)s, (int)s*yLengths/xLengths);
  size(zoom*xLengths*resolution, zoom*yLengths*resolution); //display window size (used to be size(600,600); in setup. Setup only takes integers, not variables).
}

void setup() {
  // create FreeCylinder object
  test = new FreeBody(resolution, Re, xLengths, yLengths, mr);
  //body.rotate(PI/4);
  dat = new SaveData("pressuretest1.txt",test.body1.coords,resolution,xLengths,yLengths,zoom);
  phi1Save = new SaveData("phi1.txt",test.body1.coords,resolution,xLengths,yLengths,zoom);
}

void draw() {
  test.update(); 
  test.display();
  phi1Save.saveFloat(test.body1.phi);
  dat.addData(test.t, test.flow.p);
  dat.finish();
}

void keyPressed(){exit();}