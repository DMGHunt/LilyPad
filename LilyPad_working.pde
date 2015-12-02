import hypermedia.net.*;
FreeBody test;

int resolution = (int)pow(2,5);   // number of grid points spanning radius of vortex
int xLengths = 10;                // (streamwise length of computational domain)/(resolution)
int yLengths = 6;                 // (transverse length of computational domain)/(resolution)
int zoom=3;
int Re = 242718;                  // Reynolds number from Excel
//float St = 0.2;
float mr = 1;                     // mass ratio = (body mass)/(mass of displaced fluid)

void settings(){
  size(zoom*xLengths*resolution, zoom*yLengths*resolution); //display window size (used to be size(600,600); in setup. Setup only takes integers, not variables).
}
void setup() {
  test = new FreeBody(resolution, Re, xLengths, yLengths, mr);
  test.body1.rotate(PI/8);test.body1.updatePositionOnly();
  test.body2.rotate(-PI/8);test.body2.updatePositionOnly();
}
void draw() {
  test.update();
  test.display();
  //test.control2();
  test.control1();
  //test.testcase();
}
void keyPressed(){exit();}



/*UDP;declarations()
int PORT_RX_A = 58432;//This port
int PORT_OUT_A = 58431;//Target port (sending data)
int PORT_RX_B = 40000;
int PORT_OUT_B = 40001;
String HOST_IP = "234.5.6.7";//This IP (host)
String TARGET_IP = "234.5.6.7";//This IP (target)
UDP udpA;
UDP udpB;
*/
/*SAVEDATA;declarations()
SaveData dat;
SaveData phi1Save;
SaveData saveForce_1x;
SaveData saveForce_1y;
SaveData saveForce_1xy;
SaveData saveMoment_1;
*/
/*SAVEDATA;setup()
  dat = new SaveData("pressuretest1.txt",test.body1.coords,resolution,xLengths,yLengths,zoom);
  phi1Save = new SaveData("phi1.txt",test.body1.coords,resolution,xLengths,yLengths,zoom);
  saveForce_1x = new SaveData("saveForce_1x.txt", test.body1.coords,resolution,xLengths,yLengths,zoom);
  saveForce_1y = new SaveData("saveForce_1y.txt", test.body1.coords,resolution,xLengths,yLengths,zoom);
  saveForce_1xy = new SaveData("saveForce_1xy.txt", test.body1.coords,resolution,xLengths,yLengths,zoom);
  saveMoment_1 = new SaveData("saveMoment_1.txt", test.body1.coords,resolution,xLengths,yLengths,zoom);
*/
/*UDP
  udpA = new UDP(this, PORT_RX_A, HOST_IP);
  udpA.log(true);
  //udpA.listen(true);
  
  udpB = new UDP(this, PORT_RX_B, HOST_IP);
  udpB.log(true);
  //udpB.listen(true);
*/
/*SAVEDATA;draw()
  phi1Save.saveFloat(test.pure_AOA1);
  dat.addData(test.t, test.flow.p);
  saveForce_1x.saveFloat(test.force1.x);
  saveForce_1y.saveFloat(test.force1.y);
  saveForce_1xy.savePVector(test.force1);
  saveMoment_1.saveFloat(test.moment1);
*/
/*UDP
  udpA.send(test.force1.y + "," + test.pure_AOA1,TARGET_IP,PORT_OUT_A);
  udpB.send("angle = " + test.pure_AOA1,TARGET_IP,PORT_OUT_B);
*/
  //println(VectorField flow.rhoi);
  
  //dat.finish();