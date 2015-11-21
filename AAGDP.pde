/*
FreeBody test;
Body body;

//INPUT PARAMETEdge1RS_______________________________________________________________________
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
/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
class FreeBody {
  BDIM flow;
  boolean QUICK = true, order2 = true;
  int n, m, resolution;
  ReactNACA body1;
  ReactNACA body2;
  Body EllipseD;
  BodyUnion union;
  ParticlePlot plot;
  FloodPlot flood;
  float t=0, dt=1, dto=1, chord, mr, pivot=0.3;
  
  PVector Top_limit1, Bottom_limit1, LEdge1, TEdge1; //Top_limit1 = point of downward force, Bottom_limit1 is upward
  PVector Top_limit2, Bottom_limit2, LEdge2, TEdge2; //Top_limit1 = point of downward force, Bottom_limit1 is upward
  float pitch1, too_high1, too_low1, pivotx1;
  float pitch2, too_high2, too_low2, pivotx2;
  boolean limit_broken1=false; //set to false in setup
  boolean limit_broken2=false;
  float hold_vel1, hold_AOA1;
  float hold_vel2, hold_AOA2;
  float omega=0.07, t1, t2; //omega set dep dxc.y??
  
  PVector force1, force2; 
  float moment1, moment2;
/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
  FreeBody(int resolution, int Re, int xLengths, int yLengths, float mr) {
    this.resolution = resolution;
    this.mr = mr;
    n=xLengths*resolution;
    m=yLengths*resolution;
    Window view = new Window( n, m);
    chord = resolution;
    
    body1 = new ReactNACA(2.5*n/10,m/2,chord,0.12,pivot,view);
    body2 = new ReactNACA(5*n/10,m/2,chord,0.12,pivot,view);
    union = new BodyUnion(body1,body2);
    
    //EllipseD = new EllipseD(n/10,m/2,n/20,1,view);
    //EllipseD.rotate(-PI/2); 
    //union = new BodyUnion(EllipseD, new BodyUnion( body1, body2));
    
    flow = new BDIM(n,m,0,union,(float)chord/Re,QUICK);
    body1.xfree = false;
    body2.xfree = false;
  
    flood = new FloodPlot(view); 
    flood.range = new Scale(-.5, .5);
    flood.setLegend("vorticity");
    
    plot = new ParticlePlot( view, 10000 );
    plot.setColorMode(4);
    plot.setLegend("Vorticity",-0.5,0.5);
    
  }
/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
  void update() {
    dto = dt;t+=dt;//save previous
    if (QUICK) {dt = flow.checkCFL();flow.dt = dt;}//calculate next
    union.update();flow.update(union);
    if (order2) {flow.update2();}//how to find out?
  }
  
  void testcase(){
    force1 = body1.pressForce(flow.p);
    moment1 = body1.pressMoment(flow.p);
    body1.react(force1, moment1, dto, dt); 
    //body1.translate(-0.5,-0.5);
    //body1.rotate(0.1);
  }
    /////////////*BODY1 CONTROL*//////////////NEED 2 TO PLUNGE MORE THAN 1, AND TO COUPLE HEAVE OF 1 WITH PITCH OF 2 - GREATER AOA FOR 2 MAYBE?
  void control1() {
    LEdge1 = test.body1.coords.get(0); //Leading Edge coords
    TEdge1 = test.body1.coords.get(100); //Trailing Edge coords
    pitch1 = atan((TEdge1.y-LEdge1.y)/(TEdge1.x-LEdge1.x));
    
    pivotx1=LEdge1.x+(TEdge1.x-LEdge1.x)*pivot;
    
    Top_limit1 = new PVector(pivotx1,m/2-chord/6,0);                                                        //Neutral is (34.0,64.0,0) for initial setup. Smaller is up, larger is down. chord/3 to keep Amplitude down
    Bottom_limit1 = new PVector(pivotx1,m/2+chord/6,0);                                                    //Neutral is (34.0,64.0,0) for initial setup. Smaller is up, larger is down. chord/3 to keep Amplitude down
    too_high1 = (TEdge1.x-LEdge1.x)*(Top_limit1.y-LEdge1.y)-(TEdge1.y-LEdge1.y)*(Top_limit1.x-LEdge1.x);     //Technique from http://www.gamedev.net/topic/542870-determine-which-side-of-a-line-a-point-is/
    too_low1 = (TEdge1.x-LEdge1.x)*(Bottom_limit1.y-LEdge1.y)-(TEdge1.y-LEdge1.y)*(Bottom_limit1.x-LEdge1.x);//Finds out which side of the foil the turning point is on. Top: -ve is under. Bottom: +ve is over.
    
    if(((too_high1 >= 1) && (pitch1 > -hold_AOA1/1.5)) || ((too_low1 <= 1) && (pitch1 < abs(hold_AOA1)/1.5))){ //Need to optimise bite points
      if(limit_broken1){
        t1=t1+dt;
//      body1.rotate(-hold_AOA1*omega*sin(omega*t1)); //Pitch sinusoidally
        body1.rotate(-hold_AOA1/50);
        force1 = body1.pressForce(flow.p);        //Only controlling pitch - work out force on body
        body1.react(force1, dto, dt);             //translate vertically according to force
      }
      else {
        t1=0;
        //hold_vel1=body1.dxc.y;
        hold_AOA1=pitch1;
        //body1.translate(0,hold_vel1*cos(omega*t));
//      body1.rotate(-hold_AOA1*omega*sin(omega*t1)); //Pitch sinusoidally
        body1.rotate(-hold_AOA1/50);              //SPIN ARBITRARY
        force1 = body1.pressForce(flow.p);        //Only controlling pitch - work out force on body
        body1.react(force1, dto, dt);             //translate vertically according to force
        limit_broken1=true;
      }
    } 
    else{
      /*if(pitch1>=PI/3){body1.rotate(0);}
      else if(pitch1<=-PI/3){body1.rotate(0);}
      else{*/
      force1 = body1.pressForce(flow.p);
      moment1 = body1.pressMoment(flow.p);
      body1.react(force1, moment1, dto, dt); // Translate bodes according to pressure force, previous dt, current dt
      limit_broken1=false;
    }
  }
    
  void control2() {
    LEdge2 = test.body2.coords.get(0);     //Leading Edge coords
    TEdge2 = test.body2.coords.get(100);   //Trailing Edge coords
    pitch2 = atan((TEdge2.y-LEdge2.y)/(TEdge2.x-LEdge2.x));
    
    pivotx2=LEdge2.x+(TEdge2.x-LEdge2.x)*pivot;
    
    Top_limit2 = new PVector(pivotx2,m/2-chord/6,0);                                                                                   //Neutral is (34.0,64.0,0) for initial setup. Smaller is up, larger is down. chord/3 to keep Amplitude down
    Bottom_limit2 = new PVector(pivotx2,m/2+chord/6,0);                                                                                //Neutral is (34.0,64.0,0) for initial setup. Smaller is up, larger is down. chord/3 to keep Amplitude down
    too_high2 = (TEdge2.x-LEdge2.x)*(Top_limit2.y-LEdge2.y)-(TEdge2.y-LEdge2.y)*(Top_limit2.x-LEdge2.x);                                //Technique from http://www.gamedev.net/topic/542870-determine-which-side-of-a-line-a-point-is/
    too_low2 = (TEdge2.x-LEdge2.x)*(Bottom_limit2.y-LEdge2.y)-(TEdge2.y-LEdge2.y)*(Bottom_limit2.x-LEdge2.x);                           //Finds out which side of the foil the turning point is on. Top: -ve is under. Bottom: +ve is over.
    
    if(((too_high2 >= 1) && (pitch2 > -hold_AOA2/1.5)) || ((too_low2 <= 1) && (pitch2 < abs(hold_AOA2)/1.5))){ //Need to optimise bite points
      if(limit_broken2){
        t2=t2+dt;
        body2.rotate(-hold_AOA2/50);              //SPIN ARBITRARY
        force2 = body2.pressForce(flow.p);        //Only controlling pitch - work out force on body
        body2.react(force2, dto, dt);             //translate vertically according to force
      }
      else {
        t2=0;
        hold_AOA2=pitch2;
        body2.rotate(-hold_AOA2/50);              //SPIN ARBITRARY
        force2 = body2.pressForce(flow.p);        //Only controlling pitch - work out force on body
        body2.react(force2, dto, dt);             //translate vertically according to force
        limit_broken2=true;
      }
    }
    else{
      /*if(pitch1>=PI/3){body1.rotate(0);}
      else if(pitch1<=-PI/3){body1.rotate(0);}
      else{*/
      force2 = body2.pressForce(flow.p);
      moment2 = body2.pressMoment(flow.p);
      body2.react(force2, moment2, dto, dt); // Translate bodes according to pressure force, previous dt, current dt
      limit_broken2=false;
      }
    }
    //}
   
    /////////////*BODY2 CONTROL*//////////////Commented sections can be uncommented to give independent motion (remember to take out combined body 2 sections)
    
/*    LEdge2 = LEdge2; //Leading Edge coords
    TEdge2 = TEdge2; //Trailing Edge coords
    
    pivotx2=LEdge2.x+(TEdge2.x-LEdge2.x)*pivot;
    
    Top_limit2 = new PVector(pivotx2,64.0-chord/6,0); //Neutral is (34.0,64.0,0) for initial setup. Smaller is up, larger is down. chord/3 to keep Amplitude down
    Bottom_limit2 = new PVector(pivotx2,64.0+chord/6,0); //Neutral is (34.0,64.0,0) for initial setup. Smaller is up, larger is down. chord/3 to keep Amplitude down
    
    too_high2 = (TEdge2.x-LEdge2.x)*(Top_limit2.y-LEdge2.y)-(TEdge2.y-LEdge2.y)*(Top_limit2.x-LEdge2.x); //Technique from http://www.gamedev.net/topic/542870-determine-which-side-of-a-line-a-point-is/
    too_low2 = (TEdge2.x-LEdge2.x)*(Bottom_limit2.y-LEdge2.y)-(TEdge2.y-LEdge2.y)*(Bottom_limit2.x-LEdge2.x); //Finds out which side of the foil the turning point is on. Top: -ve is under. Bottom: +ve is over.
    
    pitch2 = atan((TEdge2.y-LEdge2.y)/(TEdge2.x-LEdge2.x));
   
    if(((too_high2 >= 1) && (pitch2 > -hold_AOA2/1.5))|| ((too_low2 <= 1) && (pitch2 < abs(hold_AOA2)/1.5))){ //Need to optimise bite points
      if(limit_broken2){
        t2=t2+dt;
//      body2.rotate(-hold_AOA2*omega*sin(omega*t2)); //Pitch sinusoidally
        body2.rotate(-hold_AOA2/50);              //SPIN ARBITRARY
        force2 = body2.pressForce(flow.p);        //Only controlling pitch - work out force on body
        body2.react(force2, dto, dt);             //translate vertically according to force
      }
      else {
        t2=0;
        //hold_vel2=body2.dxc.y;
        hold_AOA2=pitch2;
        //body2.translate(0,hold_vel2*cos(omega*t2));
//      body2.rotate(-hold_AOA1*omega*sin(omega*t2)); //Pitch sinusoidally
        body2.rotate(-hold_AOA2/50);              //SPIN ARBITRARY
        force2 = body2.pressForce(flow.p);        //Only controlling pitch - work out force on body
        body2.react(force2, dto, dt);             //translate vertically according to force
        limit_broken2=true;
      }
    }
    else{
      limit_broken2=false;
/*    if(pitch2>=PI/3){ //NEEDS ADJUSTING
        body2.rotate(0);
      }
      else if(pitch2<=-PI/3){ //NEEDS ADJUSTING
        body2.rotate(0);
      }
      else{
*/
/*      force2 = body2.pressForce(flow.p);
      moment2 = body2.pressMoment(flow.p);
      body2.react(force2, moment2, dto, dt); // Translate bodes according to pressure force, previous dt, current dt
      }
    //}
*/    
    
//--------------------------------------------------------------------------------
    
    //println("pitch1 = ",pitch1);
    //println("PHI = ",body1.phi);
    //println("Velo = ",body1.dxc.y); //vertical velocity of body
    //println("Spin = ",body1.dphi); //rotational velocity of body
    //println(LEdge1); //Get PVector 1 of coordinates arraylist (x1,y1,z1) ie leading edge coords
    //println(LEdge1.x); //Get x component of PVector
    //println(TEdge1); //There are 200 points total (counted from saved file see SaveData)
    //println(TEdge1.x);

  void display() {
    flood.display(flow.u.vorticity());
    union.display();
    plot.update(flow); // !NOTEdge1!
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

//INPUT PARAMETEdge1RS_______________________________________________________________________
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