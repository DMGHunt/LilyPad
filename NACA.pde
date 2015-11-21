/********************************
NACA airfoil class

example code:

NACA foil;
void setup(){
  size(400,400);
  foil = new NACA(1,1,0.5,0.20,new Window(3,3));
}
void draw(){
  background(0);
  foil.display();
  foil.rotate(0.01);
}
********************************/
class NACA extends Body{
  int m = 100;
  float c, FoilArea;
  float pivot;
  
  NACA( float x, float y, float c, float t, float pivot, Window window ){
    super(x,y,window);
    add(xc.x-c*pivot,xc.y);
    for( int i=1; i<m; i++ ){
      float xx = pow(i/(float)m,2);
      add(xc.x+c*(xx-pivot),xc.y+t*c*offset(xx));      
    }
    add(xc.x+c*(1-pivot),xc.y);
    for( int i=m-1; i>0; i-- ){
      float xx = pow(i/(float)m,2);
      add(xc.x+c*(xx-pivot),xc.y-t*c*offset(xx));
    }
    end(); // finalizes shape
    this.c = c;
     FoilArea = t*c*0.685084;    //crossectional area of NACA foil
  }
  
  NACA( float x, float y, float c, float t, Window window ){
    this(x,y,c,t,.25,window);
  }
  
  float[][] interp( Field a ){
    float[][] b = new float[2][m+1];

    PVector x = coords.get(0);
    b[0][0] = a.interp(x.x,x.y); b[1][0] = b[0][0];
    for ( int i = 1; i<m; i++ ){
      x = coords.get(i);
      b[0][i] = a.interp(x.x,x.y);
      x = coords.get(n-i);
      b[1][i] = a.interp(x.x,x.y);
    }
    x = coords.get(m);
    b[0][m] = a.interp(x.x,x.y); b[1][m] = b[0][m];
    return b;
  }

  float offset( float x ){
    return 5*(0.2969*sqrt(x)-0.1260*x-0.3516*pow(x,2)+0.2843*pow(x,3)-0.1015*pow(x,4));
  }

//  PVector pressForce ( Field p ){
//    PVector pv = super.pressForce(p);
//    return PVector.div(pv,c);
//  }
}

class ReactNACA extends NACA{
  float Ia, Ma, dp0 = 0;
  PVector dxc0 = new PVector(0,0);
  
  ReactNACA( float x, float y, float c, float t, float pivot, float mr, Window window ){
    super( x, y, c, t, pivot, window );                // Init NACA
    mass *= mr; I0 *= mr;                              // Adjust mass ratio
    Ma = PI*mr*sq(c/2);                                // Linear added-mass
    Ia = 0.125*mr*PI*pow(c/2,4)+Ma*sq(pivot*(c-0.5));  // Angular added-mass
    println("Added-mass ratio = "+Ma/mass);
    println("Added-moment ratio = "+Ia/I0);
  }
  ReactNACA( float x, float y, float c, float t, float pivot, Window window){
    this( x, y, c, t, pivot, 1, window );
  }

  void react (PVector force, float moment, float dt1, float dt2) {

// added mass vectorization
    float nx = sq(sin(phi)), ny = sq(cos(phi));
    
// old accelerations
    float ax = (dxc.x-dxc0.x)/sq(dt1), ay = (dxc.y-dxc0.y)/sq(dt1);
    float alpha = (dphi-dp0)/sq(dt1);

// added-mass corrected integration
    float dx = dt2*(dt1+dt2)/2*(-force.x+nx*Ma*ax)/(mass+nx*Ma) + dt2/dt1*dxc.x;
    float dy = dt2*(dt1+dt2)/2*(-force.y+ny*Ma*ay)/(mass+ny*Ma) + dt2/dt1*dxc.y; 
    float dp = dt2*(dt1+dt2)/2*(-moment+Ia*alpha)/(I0+Ia) + dt2/dt1*dphi;

// save old values
    dxc0 = dxc; dp0 = dphi;

// move the body
    translate(xfree?dx:0, yfree?dy:0); 
    rotate(dp);
  }
}