/*
FreeBody test;
Body body;

//INPUT PARAMETERS_______________________________________________________________________
int resolution = (int)pow(2,4);              // number of grid points spanning radius of vortex
int xLengths = 12;                // (streamwise length of computational domain)/(resolution)
int yLengths = 8;                 // (transverse length of computational domain)/(resolution)
int zoom=5;
int area = 600000;                // window view area
int Re = 100000;                   // Reynolds number
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
  
}

void draw() {
  test.update(); 
  test.display();
}

void keyPressed(){exit();}
*/

class FreeBody {
  BDIM flow;
  boolean QUICK = true, order2 = true;
  int n, m, resolution;
  Body body1;
  Body body2;
  Body EllipseD;
  BodyUnion union;
  ParticlePlot plot;
  FloodPlot flood;
  float dt=1, dto=1, D, mr;
  PVector force;

  FreeBody(int resolution, int Re, int xLengths, int yLengths, float mr) {
    this.resolution = resolution;
    this.mr = mr;
    n=xLengths*resolution;
    m=yLengths*resolution;
    Window view = new Window( n, m);
    D = resolution;
    
    body1 = new NACA(2*n/10, m/2, D, 0.12, view);
    body1.mass = mr*body1.area;
    //body.rotate(PI/8);
    
    body2 = new NACA(5*n/10, m/2, D, 0.12, view);
    body2.mass = mr*body2.area;
    //body.rotate(PI/8);
    
    EllipseD = new EllipseD(n/10,m/2,n/20,1,view);
    EllipseD.rotate(-PI/2);
    
    union = new BodyUnion(EllipseD, new BodyUnion( body1, body2));
    
    flow = new BDIM(n, m, 0, union, (float)D/Re, QUICK);

    flood = new FloodPlot(view); 
    flood.range = new Scale(-.5, .5);
    flood.setLegend("vorticity");
    
    plot = new ParticlePlot( view, 10000 );
    plot.setColorMode(4);
    plot.setLegend("Vorticity",-0.5,0.5);
  }

  void update() {
    //body.translate(0,0.1);
    // save previous time step duration
    dto = dt;
    // calculate next time step duration
    if (QUICK) {
      dt = flow.checkCFL();
      flow.dt = dt;
    }
    
    // translate body according to pressure force, previous dt, current dt
    PVector force1 = body1.pressForce(flow.p);
    float moment1 = body1.pressMoment(flow.p);
    body1.react(force1, moment1, dto, dt);
    
    PVector force2 = body2.pressForce(flow.p);
    float moment2 = body2.pressMoment(flow.p);
    body2.react(force2, moment2, dto, dt);
    
    union.update();
    flow.update(union);
    if (order2) {
      flow.update2();
    }
  }

  void display() {
    flood.display(flow.u.vorticity());
    union.display();
    plot.update(flow); // !NOTE!
    plot.display(flow.u.vorticity());
  }
}

/********************************
EllipseD
 ********************************/
class EllipseD extends Body {
  float h, a; // height and aspect ratio of ellipse
  int m = 1000;

  EllipseD( float x, float y, float _h, float _a, Window window) {
    super(x, y, window);
    h = _h; 
    a = _a;
    float dx = 0.5*h*a, dy = 0.5*h;
    for ( int i=0; i<m; i++ ) {
      float theta = -TWO_PI*i/((float)m);
      add(xc.x+dx*cos(theta/2), xc.y+dy*sin(theta/2));
    }
    end(); // finalize shape
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*************************
 FreeNACA class
 
 This is an example class for simulating the interaction between the flow and a free
 NACA foil.
 
 Example code:
 
FreeNACA test;

//INPUT PARAMETERS_______________________________________________________________________
int resolution = 16;               // number of grid points spanning radius of vortex
int xLengths = 12;                // (streamwise length of computational domain)/(resolution)
int yLengths = 8;                 // (transverse length of computational domain)/(resolution)
int area = 300000;                // window view area
int Re = 100;                     // Reynolds number
float mr = 2;                     // mass ratio = (body mass)/(mass of displaced fluid)
//_______________________________________________________________________________________

void settings(){
  // set window view area 
  float s = sqrt(area*xLengths/yLengths);
  size((int)s, (int)s*yLengths/xLengths);
}
void setup() {
  // create FreeCylinder object
  test = new FreeNACA(resolution, Re, xLengths, yLengths, mr);
}

void draw() {
  test.update(); 
  test.display();
}

void keyPressed(){exit();}
***********************/


class FreeNACA {
  BDIM flow;
  boolean QUICK = true, order2 = true;
  int n, m, resolution;
  NACA body;
  FloodPlot flood;
  float dt=1, dto=1, D, mr;
  PVector force;

  FreeNACA(int resolution, int Re, int xLengths, int yLengths, float mr) {
    this.resolution = resolution;
    this.mr = mr;
    n=xLengths*resolution;
    m=yLengths*resolution;
    Window view = new Window(0, 0, n, m);
    D = resolution;
    
    body = new NACA(n/2,n/2,n/6,0.12,view);
    body.rotate(PI/2);
    body.mass = mr*body.area;
    
    flow = new BDIM(n, m, 0, body, (float)D/Re, QUICK);

    flood = new FloodPlot(view); 
    flood.range = new Scale(-.5, .5);
    flood.setLegend("vorticity");
  }

  void update() {
    // save previous time step duration
    dto = dt;
    // calculate next time step duration
    if (QUICK) {
      dt = flow.checkCFL();
      flow.dt = dt;
    }
    
    // translate body according to pressure force, previous dt, current dt
    PVector forceP = body.pressForce(flow.p);
    body.react(forceP, dto, dt);
    
    body.update();
    flow.update(body);
    if (order2) {
      flow.update2();
    }
  }

  void display() {
    flood.display(flow.u.vorticity());
    body.display();
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////