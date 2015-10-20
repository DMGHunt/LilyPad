//THIS IS THE FILE UNDER GIT VERSION CONTROL
//Commit test
//Commit test 2
//Commit test 3
//Commit test 4
//Commit test 5

BDIM flow;

NACA foil;
EllipseBody ellipse;
BodyUnion union;

FloodPlot flood;

void setup(){
  size(600,600);         // display window size
  int n=(int)pow(2,6);   // number of grid points
  float L = n/4.;        // length-scale in grid units
  Window view = new Window(n,n);

  foil = new NACA(3*n/4,n/2,n/4,0.12,view);     // define geom
  foil.rotate(PI/4);
  ellipse = new EllipseBody(n/4,n/2,n/5,1,view);
  ellipse.rotate(-PI/2);
  union = new BodyUnion(ellipse,foil);
  
  flow = new BDIM(n,n,1.5,union);             // solve for flow using BDIM
//  flow = new BDIM(n,n,0.,foil,L/200,true);   // BDIM+QUICK
  flood = new FloodPlot(view);               // intialize...
  flood.setLegend("vorticity",-.5,.5);       // and label a flood plot
}
void draw(){
  union.update();                             // update the foil
  flow.update(union); flow.update2();         // 2-step fluid update
  flood.display(flow.u.vorticity());          // compute and display vorticity
  union.display();                            // display the foil
}
void mousePressed(){union.mousePressed();}    // user mouse...
void mouseReleased(){union.mouseReleased();}  // interaction methods