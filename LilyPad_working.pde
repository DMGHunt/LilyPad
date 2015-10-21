BDIM flow;

NACA foil1;
NACA foil2;
EllipseD D;
BodyUnion union;

FloodPlot flood;
FoilTest test;

void setup(){
  size(800,800);         // display window size
  int n=(int)pow(2,7);   // number of grid points
  float L = n/4.;        // length-scale in grid units
  Window view = new Window(n,n);

  foil1 = new NACA(5*n/8,n/2,n/4,0.12,view);     // define geom
  foil1.rotate(PI/4);
  foil2 = new NACA(7*n/8,n/2,n/4,0.12,view);     // define geom
  foil2.rotate(-PI/4);
  D = new EllipseD(n/4,n/2,n/5,1,view);
  D.rotate(-PI/2);
  union = new BodyUnion(D, new BodyUnion(foil1,foil2));
  
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