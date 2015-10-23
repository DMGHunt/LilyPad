/*

class ActiveSystem {
  BDIM flow;
  
  NACA foil1;
  NACA foil2;
  EllipseD D;
  BodyUnion union;
  
  FloodPlot flood;
  
  int chord = n/8;
  float heaveAmp = chord/2;
  float pitchAmp = PI/4;
  float omega = 2*PI*0.01;
  float t=0;

  //SaveData dat;
  
  ActiveSystem(int resolution, int xLengths, int yLengths, int zoom, int Re, float omega){
  
    int n=resolution*xLengths;   // number of grid points x
    int m=resolution*yLengths;   // number of grid points y
    
    Window view = new Window(n,m); //window

    D = new EllipseD(2*n/10,m/2,n/10,1,view); //////D
    D.rotate(-PI/2);
    foil1 = new NACA(5*n/10,m/2,chord,0.12,view); //foil1
    foil1.rotate(0);
    foil1.translate(0,-chord/2);
    foil2 = new NACA(8*n/10,m/2,chord,0.12,view); //foil2
    foil2.rotate(PI/4);
    union = new BodyUnion(D, new BodyUnion(foil1,foil2));
    //union = new BodyUnion(foil1,foil2);
  
  //flow = new BDIM(n,n,1.5,union);             // solve for flow using BDIM
//  flow = new BDIM(n,n,0.1.,union,L/200,true);   // BDIM+QUICK
    flow = new BDIM(n,m,0,union,1/10000,false); // QUICK with adaptive time step
    flood = new FloodPlot(view);               // intialize...
    flood.setLegend("vorticity",-.5,.5);       // and label a flood plot
    
  }
}
/*
int resolution = (int)pow(2,5), xLengths=8, yLengths=4, zoom = 3;    // choose the number of grid points per chord, the size of the domain in chord units and the zoom of the display

  int n=resolution*xLengths;   // number of grid points x
  int m=resolution*yLengths;   // number of grid points y
  
  int chord = n/8;
  float heaveAmp = chord/2;
  float pitchAmp = PI/4;
  float omega = 2*PI*0.01;
  float t=0;
  
void settings(){
  size(zoom*xLengths*resolution, zoom*yLengths*resolution); //display window size (used to be size(600,600); in setup. Setup only takes integers, not variables).
}

void setup(){
  //float L = n/4.;        // length-scale in grid units
  Window view = new Window(n,m);

  D = new EllipseD(2*n/10,m/2,n/10,1,view); //////D
  D.rotate(-PI/2);

  foil1 = new NACA(5*n/10,m/2,chord,0.12,view); //foil1
  foil1.rotate(0);
  foil1.translate(0,-chord/2);
  foil2 = new NACA(8*n/10,m/2,chord,0.12,view); //foil2
  foil2.rotate(PI/4);
  
  
  union = new BodyUnion(D, new BodyUnion(foil1,foil2));
  //union = new BodyUnion(foil1,foil2);
  
  //flow = new BDIM(n,n,1.5,union);             // solve for flow using BDIM
//  flow = new BDIM(n,n,0.1.,union,L/200,true);   // BDIM+QUICK
  flow = new BDIM(n,m,0,union,1/10000,false); // QUICK with adaptive time step
  flood = new FloodPlot(view);               // intialize...
  flood.setLegend("vorticity",-.5,.5);       // and label a flood plot
  
  dat = new SaveData("pressuretest1.txt",flood.D.fcoords,resolution,xLengths,yLengths,zoom);
}
void draw(){
  float velo1 = heaveAmp*omega*sin(omega*t);
  foil1.translate(0,velo1*flow.dt);
  float velo2 = heaveAmp*omega*sin(omega*t-PI/2);
  foil2.translate(0,velo2*flow.dt);
  float spin1 = /*atan2(velo,1.)-foil1.phi-pitchAmp*omega*sin(omega*t+PI/2); //I added external omega - purely sinusoidal
  foil1.rotate(spin1);
  float spin2 = /*atan2(velo,1.)-foil1.phi-pitchAmp*omega*sin(omega*t); //I added external omega - purely sinusoidal
  foil2.rotate(spin2);
  union.update();  // update the foil
  flow.update(union); flow.update2();         // 2-step fluid update
  flood.display(flow.u.vorticity());          // compute and display vorticity
  union.display();   // display the foil
  
  dat.addData(flood.t, flood.flow.p);
  dat.finish();
  
  t += flow.dt;
}
void mousePressed(){union.mousePressed();}    // user mouse...
void mouseReleased(){union.mouseReleased();}  // interaction methods 