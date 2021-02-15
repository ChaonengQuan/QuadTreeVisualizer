/*----------------------------------------------------------------------
 |>>> Class RectBlinkerManager
 +-----------------------------------------------------------------------
 | Purpose:  Self-Contained module which implements the ability to make a
 |           rect(angle) graphics primitive 'strobe-blink' in and out on
 |           the canvas via calling a request function. The request takes
 |           the corner coordinates of the rect and a duration in seconds
 |           that it should animate for: and then animates it as such on
 |           the canvas in a frame-rate-dependent but close approximation 
 |           of the specified time period. 
 | OBJ Pool: This class utilizes a simple Object Pool of 'BlinkInstance'
 |           objects set at a fixed number on initialization from which 
 |           to service requests; such that when a 'stale' object thereof
 |           is by the request function: its values are reset according
 |           to the request and its status is set to 'active' (actually,
 |           it is set to !expired). When the time period for an active
 |           BlinkInstance object elapses, its status is reset back to 
 |           'stale' (i.e. expired) and becomes available for use when
 |           the request function next asks if it's expired.
 +-----------------------------------------------------------------------
 | Class Variables and Structs:
 | > int defFramePer      : Default Frames/Second for Strobe Phase. This 
 |                          value is used as an argument when [re]setting
 |                          a BlinkInstance to tell it 'how quickly' it
 |                          should blink in-and-out; such that the higher
 |                          the value, the slower the blinking animation.
 | > BlinkInstance[] pool : BlinkInstance Object Pool of which instances
 |                          are [re]used to service rect blink requests.
 +---------------------------------------------------------------------*/
class RectBlinkerManager {
  int defFramePer = 60;
  BlinkInstance[] pool;

  // Default Constructor: will create pool of default size as per below
  public RectBlinkerManager() {
    this(32); // Default Pool Size.
  }

  // This constructor allows user to specify the size of the object pool
  public RectBlinkerManager(int poolPop) {
    pool = new BlinkInstance[poolPop];
    for (int i=0; i<pool.length; i++) {
      pool[i] = new BlinkInstance(new PVector(), new PVector(), -1, -1, 1);
    }
  }

  // 'Dispatcher' used to update the pool each frame (i.e. determine if expired)
  void updatePool() {
    for (int i=0; i<pool.length; i++) {
      pool[i].update();
    }
  }

  // 'Dispatcher' used to render the pool each frame
  void renderPool() {
    for (int i=0; i<pool.length; i++) {
      pool[i].render();
    }
  }

  /*----------------------------------------------------------------------
   |>>> Function request 
   +-----------------------------------------------------------------------
   | Purpose:  Interface with the RBM instance from which requests can be
   |           made. If a stale entry is found, its values are reset bassed
   |           on the contents of the request; else a message is printed to
   |           the console warning that no stale object was found.
   | Inputs:   x1,y1 - one corner of a rectangle to draw+blink (i.e. UL/LL)
   |           x2,y2 - the other corner of such a rectangle to (i.e. LR/UR)
   |           span  - how long (in approx. seconds) to draw+blink it for
   +---------------------------------------------------------------------*/
  void request(float x1, float y1, float x2, float y2, float span) { 
    boolean gotAndUsedStaleEntry = false;
    int numFrames = int(span*60);   
    for (int i=0; i<pool.length; i++) {
      if (pool[i].isExpired()) {
        gotAndUsedStaleEntry = true;
        pool[i].reset(new PVector(x1, y1), new PVector(x2, y2), frameCount, frameCount+numFrames, defFramePer);
        break;
      }
    } 
    if (!gotAndUsedStaleEntry) {
      println("Warning! Could not find stale entry, did you add too many requests too quickly?");
    }
  }

  /*----------------------------------------------------------------------
   |>>> Sub-Class BlinkInstance
   +-----------------------------------------------------------------------
   | Purpose:  Implements the servicing of requests made to the instance of
   |           a RectangleBlinkManager's as an instance of its Object Pool.
   |           Given a start frame, end frame, animation period (i.e. how
   |           quickly the rect should strobe in-and-out), and an active
   |           status (i.e. expired==false): an instance of this class will
   |           animate an alpha-value-based stobing blinking in-and-out of
   |           a rectangle specified by the corner endpoints.
   | Notes:    > Definition of Ending Frame i.e. expiration: As seen in the
   |             constructor and reset functions, the end frame is defined
   |             as the closest multiple of blinking speed period to the
   |             specified duration. This was designed for 'cosmetic' i.e.
   |             VFX purposes such that the object will become stale thus
   |             its animation stop only when fully blinked out; which is
   |             prettier than making it disappear out of nowhere!
   +---------------------------------------------------------------------*/
  class BlinkInstance {
    int sFrame;             // starting frame
    int eFrame;             // ending frame (i.e. when request expires)
    int myPer;              // strobe period (i.e. speed of blink in-out)
    PVector p1, p2;         // Corner points of the rect to draw
    boolean expired = true; // Has the request's time period expired?

    PVector myColor;        // Default to blue in constructor, but can modify as needed!
    int myStrokeWeight = 2; // Thickness of lines to draw rect with

    public BlinkInstance(PVector pi1, PVector pi2, int sFr, int eFr, int per) {
      p1 = pi1;
      p2 = pi2;
      myPer = per;
      sFrame = sFr;
      eFrame = eFr+(eFr%per);
      myColor = new PVector(0, 0, 255); // Again, feel free to change this i.e. 'setColor' function!
    }

    boolean isExpired() {
      return expired;
    }

    // Note: reset is analogous to the constructor. I could [should] have wrote a separate 'Init(...)'
    // function s.t. constructor and reset call same code ergo have 1 definition of [re]set, but #YOLO
    void reset(PVector pi1, PVector pi2, int sFr, int eFr, int per) {
      p1 = pi1;
      p2 = pi2;
      myPer = per;
      sFrame = sFr;
      eFrame = eFr+(eFr%per);
      expired=false;
      this.update();
    }

    void update() {
      if (frameCount>=eFrame) {
        expired=true;
      }
    }

    /*----------------------------------------------------------------------
     |>>> Function render 
     +-----------------------------------------------------------------------
     | Note: "Hey Steve, how the heck did you get them to strobe in and out
     |       like that?" Sine FTW. We first take the difference between the
     |       current and starting frames, and mod that by the speed of which
     |       the strobe effect occurs. This gives us the 'period offset' i.e.
     |       "where in the strobe in-out animation am I WRT this frame?". We
     |       then divide this number by the strobe period to produce the same
     |       info except WRT the animation i.e. "i'm 52% of the way through".
     |       We then take the Sine of this offset multiplied by PI. Why? Sine
     |       of (PI*0)=0, (PI*0.5)=1, and (PI*1.0)=0, thus giving us a smooth
     |       circular sine wave between 0 and 1 repeating, beautiful! We then
     |       multiply this value in oscilating range [~0,~1] by 255, set that
     |       as the new period offset value, and pass it as the alpha color
     |       of the stroke for the rect we're about to draw. The total effect
     |       is thus an alpha (i.e. transparency) value that circularly moves
     |       between 0-255-0-255-etc. for a neat blinking effect as a smooth
     |       strobing in and out of transparency. Special thanks to Unity3D
     |       where I learned this, as I wanted to implement Aircraft lights
     |       for my AV-14 Hornet (Halo) realistic model and Flight Simulator!
     +---------------------------------------------------------------------*/
    void render() {   
      if (!expired) {     
        float perOff = (frameCount-sFrame)%myPer;
        perOff = sin((perOff/myPer)*PI)*255;           
        noFill();
        strokeWeight(myStrokeWeight);
        stroke(myColor.x, myColor.y, myColor.z, perOff);
        rect(p1.x, p1.y, p2.x-p1.x, p2.y-p1.y);
      }
    }
  } // Ends Class BlinkInstance
} // Ends Class RectBlinkerManager
