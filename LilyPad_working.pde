BDIM flow;

NACA foil1;
NACA foil2;
EllipseD D;
BodyUnion union;

FloodPlot flood;
ParticlePlot plot;
//FoilTest test;

SaveData dat;

int resolution = (int)pow(2,4), xLengths=12, yLengths=5, zoom = 6;    // choose the number of grid points per chord, the size of the domain in chord units and the zoom of the display/

int n=resolution*xLengths;   // number of grid points x
int m=resolution*yLengths;   // number of grid points y
  
int chord = n/10;
float heaveAmp = chord/2;
float pitch = PI/100;
float pitchAmp = PI/1000000;//pitch/(2*PI);//PI/1000000; //whaaaaaaaaattt...?
float t=0;
int Re=20000;
float St = 0.2;
float k = 2;
float f = k/(chord*2*PI);
//float omega = 2*PI*0.01;
float omega = 2*PI*f;
//float omega = 2*PI*St*chord; 
  
void settings(){
  size(zoom*xLengths*resolution, zoom*yLengths*resolution); //display window size (used to be size(600,600); in setup. Setup only takes integers, not variables).
}

void setup(){
  //float L = n/4.;        // length-scale in grid units
  Window view = new Window(n,m);

  D = new EllipseD(2*n/10,m/2,chord/2,1,view); //////D
  D.rotate(-PI/2);

  foil1 = new NACA(3*n/10,m/2,chord,0.12,view); //foil1
  foil1.rotate(0);
  foil1.translate(0,-chord/2);
  foil2 = new NACA(7*n/10,m/2,chord,0.12,view); //foil2
  foil2.rotate(pitchAmp);
  
  
  //union = new BodyUnion(D, new BodyUnion(foil1,foil2));
  union = new BodyUnion(foil1,foil2); 
  
  println("nu = ",(float) chord/Re);
  println("chord = ",(float) chord);
  println("pitchAmp = ",(float) pitchAmp);
  //flow = new BDIM(n,n,1.5,union);             // solve for flow using BDIM
//  flow = new BDIM(n,n,0.1.,union,L/200,true);   // BDIM+QUICK
  flow = new BDIM(n,m,0,union,(float) chord/Re,false); // QUICK with adaptive time step
  
  flood = new FloodPlot(view);               // intialize...
  flood = new FloodPlot(view);               // intialize...
  flood.setLegend("vorticity",-.5,.5);       // and label a flood plot
  flood.setColorMode(4);
  
  plot = new ParticlePlot( view, 10000 );
  plot.setColorMode(4);
  plot.setLegend("Vorticity",-0.5,0.5);
  
  //dat = new SaveData("pressuretest1.txt",test.foil1.fcoords,resolution,xLengths,yLengths,zoom);
}
void draw(){
  float velo1 = heaveAmp*omega*sin(omega*t);
  foil1.translate(0,velo1*flow.dt);
  float velo2 = heaveAmp*omega*sin(omega*t-PI/2);
  foil2.translate(0,velo2*flow.dt);
  //float spin1 = atan2(velo1,1.)-foil1.phi;//-pitchAmp*sin(omega*t+PI/2); //I added external omega - purely sinusoidal
  float spin1 = pitchAmp*sin(omega*t)-foil1.phi-atan2(velo1,1.);
  foil1.rotate(spin1);
  float spin2 = pitchAmp*sin(omega*t-PI/2)-foil2.phi-atan2(velo2,1.);
  foil2.rotate(spin2);
  union.update();  // update the foil
  flow.update(union); flow.update2();         // 2-step fluid update
  
  flood.display(flow.u.vorticity());          // compute and display vorticity flow.p flow.u.vorticity()
  
  plot.update(flow); // !NOTE!
  plot.display(flow.u.vorticity());
  
  union.display();   // display the foil
  
  

  
  //dat.addData(flood.t, flood.flow.p);
  //dat.finish();
  
  t += flow.dt;
}
void mousePressed(){union.mousePressed();}    // user mouse...
void mouseReleased(){union.mouseReleased();}  // interaction methods