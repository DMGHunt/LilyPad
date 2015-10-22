BDIM flow;

NACA foil1;
NACA foil2;
EllipseD D;
BodyUnion union;

FloodPlot flood;
FoilTest test;

  int n=(int)pow(2,7);   // number of grid points
  float heaveAmp = n/4;
  float pitchAmp = PI/4;
  float omega = 2*PI*0.01;
  float t=0;

void setup(){
  size(600,600);         // display window size
  float L = n/4.;        // length-scale in grid units
  Window view = new Window(n,n);

  D = new EllipseD(n/4,n/2,n/5,1,view); //////D
  D.rotate(-PI/2);

  foil1 = new NACA(5*n/10,n/2,n/5,0.12,view); //foil1
  foil1.rotate(0);
  foil1.translate(0,-n/4);
  foil2 = new NACA(8*n/10,n/2,n/5,0.12,view); //foil2
  foil2.rotate(PI/4);
  
  
  union = new BodyUnion(D, new BodyUnion(foil1,foil2));
  
  //flow = new BDIM(n,n,1.5,union);             // solve for flow using BDIM
//  flow = new BDIM(n,n,0.,union,L/200,true);   // BDIM+QUICK
  flow = new BDIM(n,n,0,union,0.001,false); // QUICK with adaptive time step
  flood = new FloodPlot(view);               // intialize...
  flood.setLegend("vorticity",-.5,.5);       // and label a flood plot
}
void draw(){
  float velo1 = heaveAmp*omega*sin(omega*t);
  foil1.translate(0,velo1*flow.dt);
  float velo2 = heaveAmp*omega*sin(omega*t-PI/2);
  foil2.translate(0,velo2*flow.dt);
  float spin1 = /*atan2(velo,1.)-foil1.phi*/-pitchAmp*omega*sin(omega*t+PI/2); //I added external omega - purely sinusoidal
  foil1.rotate(spin1);
  float spin2 = /*atan2(velo,1.)-foil1.phi*/-pitchAmp*omega*sin(omega*t); //I added external omega - purely sinusoidal
  foil2.rotate(spin2);
  union.update();  // update the foil
  flow.update(union); flow.update2();         // 2-step fluid update
  flood.display(flow.u.vorticity());          // compute and display vorticity
  union.display();   // display the foil
  t += flow.dt;
}
void mousePressed(){union.mousePressed();}    // user mouse...
void mouseReleased(){union.mouseReleased();}  // interaction methods