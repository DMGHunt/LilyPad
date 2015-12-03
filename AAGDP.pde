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
 
/*ATTEMPT AT GENERALISED CONTROL------------------------------------ATTEMPT AT GENERALISED CONTROL-----------------------------------ATTEMPT AT GENERALISED CONTROL---------------------
  PVector Top_limit,Bottom_limit,LEdge,TEdge,force;
  float time=0,pitch,too_high,too_low,pivotx,hold_vel,hold_AOA,moment;
  boolean limit_broken;
--ATTEMPT AT GENERALISED CONTROL------------------------------------ATTEMPT AT GENERALISED CONTROL-----------------------------------ATTEMPT AT GENERALISED CONTROL-------------------*/
  float chord, mr, pivot=0.5, x_body1, limit_spin=-0.00000001;
  
  float t=0, dt=1, dto=1;
  
  PVector Top_limit1, Bottom_limit1, LEdge1, TEdge1; //Top_limit1 = point of downward force, Bottom_limit1 is upward
  PVector Top_limit2, Bottom_limit2, LEdge2, TEdge2; //Top_limit1 = point of downward force, Bottom_limit1 is upward
  float pitch1=0, too_high1, too_low1, pivotx1;
  float pitch2=0, too_high2, too_low2, pivotx2;
  
  boolean limit_broken1=false;
  boolean limit_broken2=false;
  
  float hold_vel1=0, hold_AOA1=0;
  float hold_vel2=0, hold_AOA2=0;
  float omega1, omega2, spin1, spin2, translate1, translate2, t1, t2;
  float s1, a1;
  float s2, a2;
  
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
    
    body1 = new ReactNACA(x_body1=2.5*n/10,m/2,chord,0.12,pivot,view);
    body2 = new ReactNACA(x_body1+5*chord,m/2,chord,0.12,pivot,view);
    union = new BodyUnion(body1,body2);
    
    //EllipseD = new EllipseD(n/10,m/2,n/20,1,view);
    //EllipseD.rotate(-PI/2); 
    //union = new BodyUnion(EllipseD, new BodyUnion( body1, body2));
    
    flow = new BDIM(n,m,0,union,(float)chord/Re,QUICK);
    body1.xfree = false; body2.xfree = false;
  
    flood = new FloodPlot(view); 
    flood.range = new Scale(-.5, .5);
    flood.setLegend("vorticity");
    
    plot = new ParticlePlot( view, 10000 );
    plot.setColorMode(4);
    plot.setLegend("Vorticity",-0.5,0.5);   
  }
/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
  float realTime = 0;
  float realTime(){
    realTime=t*0.28/chord;
    return realTime;
  }
  float realForce;
  float realForce(float force_component){
    realForce = force_component*1000*0.28/chord;
    return realForce;
  }
  void update() {
    dto = dt;t+=dt;
    if (QUICK) {dt = flow.checkCFL();flow.dt = dt;}
    union.update();flow.update(union);
    if (order2) {flow.update2();}
    //real_time=t*0.28/resolution;
    //println(real_time);
  }
  float ts=0;
  void testcase(){
    ts=ts+dt;
    println(ts);
    if(ts<20){
      body1.translate(0,-0.1);
      body1.rotate(0.01);
    }
    else{
      force1 = body1.pressForce(flow.p);
      moment1 = body1.pressMoment(flow.p);
      body1.react(force1, moment1, dto, dt); 
    }
  }
  float PITCH(ReactNACA foil){
    PVector LEdge = foil.coords.get(0); //Leading Edge coords
    PVector TEdge = foil.coords.get(100); //Trailing Edge coords
    float pitch = atan((TEdge.y-LEdge.y)/(TEdge.x-LEdge.x));
    return pitch;
  }
  
  boolean __LIMITS__(ReactNACA foil, float pivot, float chord, float ylim){//returns true if outsede set limits. Also contrains pitch
    PVector LE = foil.coords.get(0);
    PVector TE = foil.coords.get(100);
    float pivotx=LE.x+(TE.x-LE.x)*pivot;                                      //PHSICAL X POSITION OF PIVOT
    PVector _TOP_ = new PVector(pivotx,m/2-ylim,0);                                                     
    PVector _BOTTOM_ = new PVector(pivotx,m/2+ylim,0);                        //Smaller is up, larger is down. chord/3 to keep Amplitude down
    float _HIGH_ = (TE.x-LE.x)*(_TOP_.y-LE.y)-(TE.y-LE.y)*(_TOP_.x-LE.x);     //Technique from http://www.gamedev.net/topic/542870-determine-which-side-of-a-line-a-point-is/
    float _LOW_ = (TE.x-LE.x)*(_BOTTOM_.y-LE.y)-(TE.y-LE.y)*(_BOTTOM_.x-LE.x);    
    if(_HIGH_ >= 1 || _LOW_ <= 1){return true;}
    else {return false;}
  }
    
  void control1(){ 
    println("---------------------------------------------");
    println("Velocity = "+body1.dxc.y);
    println("pitch = "+PITCH(test.body1));
    println("free start = "+(-hold_AOA1/1.5));
    if(__LIMITS__(test.body1,test.pivot,test.chord,test.chord/2)){
/*      if (((PITCH(test.body1) > -hold_AOA1/1.5) && (spin1>0))      //if pitch beyond top break-even lift point. NEEDS OPTIMISATION
      ||((PITCH(test.body1) < abs(hold_AOA1)/1.5) && (spin1<0))){  //OR if pitch beyond bottom break-even lift point. NEEDS OPTIMISATION
*/      if(limit_broken1==false){
          println("AAAAAAAAAAAAAA");
          t1=0;                               //set iterative time to 0
          hold_vel1=body1.dxc.y;              //hold initial velocity
          s1 = test.chord/10;          //set vertical distance at limits
          if(hold_vel1<0){a1 = pow(hold_vel1,2)/(2*s1);} //suvat to find required translational acceleration
          else{a1 = -pow(hold_vel1,2)/(2*s1);}  //suvat to find required translational acceleration
          hold_AOA1 = PITCH(test.body1);      //hold initial angle
          //if(hold_AOA>0
          spin1 = 0.5*hold_AOA1*a1/hold_vel1; //Required rotational velocity based on suvat. 0.5 constant is guess to sync trans and rot (theoretically should be 1).
          translate1=hold_vel1+a1*t1;         //suvat to set iterative translation based on iterative time
          body1.translate(0,translate1);      //do translation
          body1.rotate(spin1);                //do rotation
          limit_broken1=true;                 //set switch ON
          //force1 = body1.pressForce(flow.p);body1.react(force1, dto, dt); //FREE HEAVE
        }
        else if(limit_broken1==true){
          if((body1.dxc.y/hold_vel1)<0){
            println("REACT REACT REACT REACT REACT");
            force1 = body1.pressForce(flow.p);
            moment1 = body1.pressMoment(flow.p);
            body1.react(force1, 0, dto, dt); //FREE PITCH AND HEAVE
            body1.rotate(spin1);
          }
          else{
            println("BBBBBBBBBBBBBB");
            t1=t1+dt;                           //iterate time according to the flow
            translate1=hold_vel1+a1*t1;         //suvat to find translation depending on acceleration and time
            body1.translate(0,translate1);      //do the translation
            body1.rotate(spin1);                //do the rotation based on constant spin
          //force1 = body1.pressForce(flow.p);body1.react(force1, dto, dt); //FREE HEAVE
        }
      }
    }
/*    else{
        println("CCCCCCCCCCCCCCC");
        force1 = body1.pressForce(flow.p);body1.react(force1, dto, dt); //FREE HEAVE
        body1.rotate(spin1);
      }
  }
*/  else{//if not in limits
      limit_broken1=false;
      println("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFUUUUUUUUUUUUUUUUU");
/*      if(limit_broken1==true){//if first iteration out of limits
        println("OUT ITER 1. OUT ITER 1.");
        body1.translate(0,translate1);
        //moment1 = body1.pressMoment(flow.p);body1.react(force1, moment1, dto, dt);
        body1.rotate(0);
        limit_broken1=false;
      }
      else if(limit_broken1==false){//if not first iteration out of limits
*/      if(PITCH(test.body1)>PI/6){//max pitch
          println("CCCCCCCCCCCCCCCCCCCCCCCKKKKKKKKKKKKKKKKKKKKKKKKK");
          //body1.rotate(limit_spin);                                        //ROTATE INWARDS
          force1 = body1.pressForce(flow.p);body1.react(force1, 0, dto, dt); //FREE HEAVE
          body1.rotate(0);
        }
        else if(PITCH(test.body1)<-PI/6){//min pitch
          println("CCCCCCCCCCCCCCCCCCCCCCCCKKKKKKKKKKKKKKKKKKKKKKKKK");
          //body1.rotate(-limit_spin);                                       //ROTATE INWARDS
          force1 = body1.pressForce(flow.p);body1.react(force1, 0, dto, dt); //FREE HEAVE
          body1.rotate(0);
        }
        else{//purely free movement
          force1 = body1.pressForce(flow.p);moment1 = body1.pressMoment(flow.p);body1.react(force1, moment1, dto, dt); //FREE PITCH AND HEAVE
          println("force: "+force1.y);println("moment: "+moment1);
          float AOA0 = PITCH(test.body1);
          println("ANGULAR ACCELERATION = "+(PITCH(test.body1)-AOA0)/dt);
        }
    //}
    }
  }
/*  
  void control2() {
    LEdge2 = test.body2.coords.get(0);     //Leading Edge coords
    TEdge2 = test.body2.coords.get(100);   //Trailing Edge coords
    pitch2 = atan((TEdge2.y-LEdge2.y)/(TEdge2.x-LEdge2.x));
    
    println("Difference = "+(PI/5-pitch2));
    println("Difference = "+(PI/5-pitch2));
    println("Difference = "+(PI/5-pitch2));
    println("Difference = "+(PI/5-pitch2));
   
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
      if(pitch2>PI/5){
        body2.rotate(limit_spin);                                        //ROTATE INWARDS
        force2 = body2.pressForce(flow.p);body2.react(force2, dto, dt);  //FEEE HEAVE
      } 
      else if(pitch2<-PI/5){
        body2.rotate(-limit_spin);                                       //ROTATE INWARDS
        force2 = body2.pressForce(flow.p);body2.react(force2, dto, dt);  //FEEE HEAVE
      } 
      else{
        force2 = body2.pressForce(flow.p);
        moment2 = body2.pressMoment(flow.p);
        body2.react(force2, moment2, dto, dt); // Translate bodes according to pressure force, previous dt, current dt
        limit_broken2=false;
      }
    }
  }
*/
  void display() {
    flood.display(flow.u.vorticity());
    union.display();
    plot.update(flow); // !NOTEdge1!
    plot.display(flow.u.vorticity());
  }
  
/*ATTEMPT AT GENERALISED CONTROL------------------------------ATTEMPT AT GENERALISED CONTROL---------------------------------ATTEMPT AT GENERALISED CONTROL---------------------------
  void control(ReactNACA body) {
    LEdge = test.body.coords.get(0);     //Leading Edge coords
    TEdge = test.body.coords.get(100);   //Trailing Edge coords
    pitch = atan((TEdge.y-LEdge.y)/(TEdge.x-LEdge.x));
    
    pivotx=LEdge.x+(TEdge.x-LEdge.x)*pivot;
    
    Top_limit = new PVector(pivotx,m/2-chord/6,0);                                                                                   //Neutral is (34.0,64.0,0) for initial setup. Smaller is up, larger is down. chord/3 to keep Amplitude down
    Bottom_limit = new PVector(pivotx,m/2+chord/6,0);                                                                                //Neutral is (34.0,64.0,0) for initial setup. Smaller is up, larger is down. chord/3 to keep Amplitude down
    too_high = (TEdge.x-LEdge.x)*(Top_limit.y-LEdge.y)-(TEdge.y-LEdge.y)*(Top_limit.x-LEdge.x);                                //Technique from http://www.gamedev.net/topic/542870-determine-which-side-of-a-line-a-point-is/
    too_low = (TEdge.x-LEdge.x)*(Bottom_limit.y-LEdge.y)-(TEdge.y-LEdge.y)*(Bottom_limit.x-LEdge.x);                           //Finds out which side of the foil the turning point is on. Top: -ve is under. Bottom: +ve is over.
    
    if(((too_high >= 1) && (pitch > -hold_AOA/1.5)) || ((too_low <= 1) && (pitch < abs(hold_AOA)/1.5))){ //Need to optimise bite points
      if(limit_broken){
        time=time+dt;
        body.rotate(-hold_AOA/50);  //SPIN ARBITRARY
        force = body.pressForce(flow.p);        //Only controlling pitch - work out force on body
        body.react(force, dto, dt);             //translate vertically according to force
      }
      else {
        time=0;
        hold_AOA=pitch;
        body.rotate(-hold_AOA/50);              //SPIN ARBITRARY
        force = body.pressForce(flow.p);        //Only controlling pitch - work out force on body
        body.react(force, dto, dt);             //translate vertically according to force
        limit_broken=true;
      }
    }
    else{
      if(pitch>PI/3){body.rotate(-limit_spin);}
      else if(pitch<-PI/3){body.rotate(limit_spin);}
      else{
        force = body.pressForce(flow.p);
        moment = body.pressMoment(flow.p);
        body.react(force, moment, dto, dt); // Translate bodes according to pressure force, previous dt, current dt
        limit_broken=false;
      }
    }
  }
ATTEMPT AT GENERALISED CONTROL-------------------------------------ATTEMPT AT GENERALISED CONTROL----------------------------------------ATTEMPT AT GENERALISED CONTROL--------------*/
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