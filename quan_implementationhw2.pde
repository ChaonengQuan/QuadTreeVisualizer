// Declarations you will likely need for QT version //<>//
QuadTreeNode root;
PrintWriter writer;
RectBlinkerManager rbm;
static String filename_IN  = "input.txt";
static String filename_OUT = "output.txt"; 
Command[] commands;
boolean enableUserInsert = false; // can't add points until input commands processed
boolean isAnimationOn = true; //start with animation on
boolean enableUserReport = false;
boolean enableUserCount = false;

// Declarations for Demo
ArrayList<Point> points = new ArrayList<Point>();
ArrayList<Point> selectedPts = new ArrayList<Point>();
int pointsRange = -1; // should [must] be set by processing 'Q' command!

//  the PrintWriter, RBM
void setup() {
  size(512, 512);
  writer = createWriter(filename_OUT);
  rbm = new RectBlinkerManager();
  commands = parseCommands(getInput(filename_IN));  
  toOutput(">>> Setup Complete");
}

void draw() {
  //below two lines of code invert the y-axis
  scale(1, -1);
  translate(0, -height);
  
  rbm.updatePool();
  execInputCommandsDFrame();    
  background(255);
  if (root != null) {
    root.drawQuadTree();
  }
  rbm.renderPool();
}


void keyPressed() {
  // Note how I'm using this to do the final output of all points + close the file
  if (keyCode == ESC) {
    cmd_OutputPts();
    closeWriter();
  }
  if (key == 'a') {  //animation button
    if (isAnimationOn == true) {
      isAnimationOn = false;
    } else {
      isAnimationOn = true;
    }
  }

  if (key == 'i') {  //animation button
    if (enableUserInsert== true) {
      enableUserInsert = false;
    } else {
      enableUserReport = false;
      enableUserCount = false;
      enableUserInsert = true;
      println(">You are in the Insert Mode now.\n");
      writer.println(">You are in the Insert Mode now.\n");
    }
  }

  if (key == 'r') {
    if (enableUserReport == true) {
      enableUserReport = false;
    } else {
      enableUserInsert = false;
      enableUserCount = false;
      enableUserReport = true;
      println(">You are in the Report Mode now.\n");
      writer.println(">You are in the Report Mode now.\n");
    }
  }

  if (key == 'c') {
    if (enableUserCount == true) {
      enableUserCount = false;
    } else {
      enableUserInsert = false;
      enableUserReport = false;
      enableUserCount = true;
      println(">You are in the Count Mode now.\n");
      writer.println(">You are in the Count Mode now.\n");
    }
  }
}

PVector reportUL = null;
PVector reportLR = null;
boolean recordingUL = true;

// Note how I'm double-dipping the Insert Command code for manual input too!
void mousePressed() {
  if (enableUserInsert) {    //allow user to insert by clicking one point
    cmd_Insert(new int[]{int(mouseX), height-int(mouseY)});
  }

  if (enableUserReport) {                                    //allow user to report by clicking two points
    if (recordingUL) {
      reportUL = new PVector((int)mouseX, height-(int)mouseY);
      recordingUL = false;
    } else {
      reportLR = new PVector((int)mouseX, height-(int)mouseY);
      //report
      cmd_Report(new int[]{(int)reportUL.x, (int)reportUL.y, (int)reportLR.x, (int)reportLR.y});
      rbm.request((int)reportUL.x, (int)reportUL.y, (int)reportLR.x, (int)reportLR.y, 3);
      //reset
      recordingUL = true;
      reportUL = null;
      reportLR= null;
    }
  }

  if (enableUserCount) {
    if (recordingUL) {
      reportUL = new PVector((int)mouseX, height-(int)mouseY);
      recordingUL = false;
    } else {
      reportLR = new PVector((int)mouseX, height-(int)mouseY);
      //report
      cmd_Count(new int[]{(int)reportUL.x, (int)reportUL.y, (int)reportLR.x, (int)reportLR.y});
      rbm.request((int)reportUL.x, (int)reportUL.y, (int)reportLR.x, (int)reportLR.y, 3);
      //reset
      recordingUL = true;
      reportUL = null;
      reportLR= null;
    }
  }
  //
  //
}
