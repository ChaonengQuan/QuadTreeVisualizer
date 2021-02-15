/*----------------------------------------------------------------------
 |>>> Class Region
 +-----------------------------------------------------------------------
 | Purpose: Representation of QuadTree node's region specified by 
 |          two Pvector, LL and UR. LL represents the lower left point, 
 |          UR represents the upper right point of the quadrant.
 +---------------------------------------------------------------------*/
class Region {
  PVector UL;
  PVector LR;
  public Region(PVector UL, PVector LR) {
    this.UL = UL;
    this.LR = LR;
  }
}

/*----------------------------------------------------------------------
 |>>> Class Point
 +-----------------------------------------------------------------------
 | Purpose: Basic Point representation of which effectively encapsulates
 |          a PVector as to provide additional support for console log,
 |          selection flag, value equality, and 'within rect?' queries.
 +---------------------------------------------------------------------*/
class Point {
  PVector pt;
  boolean isSelected = false; // is this point selected?
  float   ptSize = 10;        // size of the ellipse drawn for this point
  color   sCol;               // color is selected
  color   uCol;               // color if unselected

  public Point(PVector p) {
    pt = p;    
    sCol = color(255, 120, 0);
    uCol = color(0, 120, 255);
  }

  void toConsole() {
    println("("+int(pt.x)+","+int(pt.y)+")");
  }
  String toString() {
    return "("+int(pt.x)+","+int(pt.y)+")";
  }

  // Sets the point to selected, which means it's colored differently. One way to ID certain points!
  void setSelected(boolean val) {
    isSelected = val;
  }

  // Is this point within bounds defined as: b[0=x1 , 1=y1 , 2=x2 , 3=y2]
  boolean isWithin(int[] b) {
    return (pt.x>=b[0] && pt.x<b[2] && pt.y>=b[1] && pt.y<b[3]) ? true : false;
  }

  void render() {
    stroke(60);
    strokeWeight(1);
    if (isSelected) {
      fill(sCol);
    } else {
      fill(uCol);
    }
    ellipse(pt.x, pt.y, ptSize, ptSize);
  }
}


/*----------------------------------------------------------------------
 |>>> Function execInputCommandsDFrame
 +-----------------------------------------------------------------------
 | Purpose: Executes command parsed from the input every specified number
 |          of frames, until all input commands were processed. Control
 |          is then provided to the user for manual mouse-pressed based
 |          insertion of points.
 +---------------------------------------------------------------------*/
boolean cmdsDone = false;
int curCmd = 0;        // current input command that has been processed
float frameSpeed = 15; // run new input command on each frame specified here
float frameDelay = 0;  // frames to wait before starting the animation
void execInputCommandsDFrame() {
  if (!cmdsDone && curCmd == commands.length) {
    cmdsDone=true;
    enableUserInsert=true;
    println("> All Input Commands have been processed!");
    writer.println("> All Input Commands have been processed!");
    println("\n============================Now entering user control mode===========================");
    writer.println("\n============================Now entering user control mode===========================");
    println("Press 'i' to turn on/off Insert Mode, 'r' to turn on/off Report Mode, 'c' to turn on/off Count Mode");
    writer.println("Press 'i' to turn on/off Insert Mode, 'r' to turn on/off Report Mode, 'c' to turn on/off Count Mode");
    println(">You are in the Insert Mode now.\n");
    writer.println(">You are in the Insert Mode now.\n");
  } else if (!cmdsDone && (curCmd != commands.length) && (frameCount>=frameDelay) && (frameCount%frameSpeed==0)) {
    executeCommand(commands[curCmd]);
    curCmd++;
  }
}


/*----------------------------------------------------------------------
 |>>> Function executeCommand
 +-----------------------------------------------------------------------
 | Purpose: Runs command specified by input Command object via calling
 |          the corresponding 'Command Handler' via switch statement on
 |          the command's char ID. Pretty slick, eh?
 +---------------------------------------------------------------------*/
void executeCommand(Command cmd) {
  switch(cmd.id) {
  case '#':
    cmd_Comment(cmd.comment);
    break;
  case 'Q': 
    cmd_SetRange(cmd.args); 
    break;
  case 'i': 
    cmd_Insert(cmd.args); 
    break;
  case 'r': 
    cmd_Report(cmd.args); 
    break;
  case 'c': 
    cmd_Count(cmd.args); 
    break;
  case 'e': 
    cmd_Empty(cmd.args); 
    break;
  }
}


/*----------------------------------------------------------------------
 |>>> Command Handler Functions
 +-----------------------------------------------------------------------
 | Purpose: These functions are mostly defined WRT the demo application
 |          of points on the canvas; but some of them might be useful for
 |          the Quadtree-based versions you will implement (e.g. Report,
 |          Count, Empty, and OutputPts). As these definitions are mostly
 |          trivial or effectively stubs, there's no need to thoroughly
 |          comment on them, though you're welcome to ask questions.
 +---------------------------------------------------------------------*/
void cmd_Comment(String cmt) {
  println(cmt);
  writer.println(cmt);
}

void cmd_SetRange(int[] args) {
  pointsRange = args[0];
  root = new QuadTreeNode(new PVector(0, 0), new PVector(args[0], args[0]));
  println("Q " + args[0]);
  writer.println("Q " + args[0]);
}

void cmd_Insert(int[] args) {
  println("i " +args[0]+" "+args[1]);
  writer.println("i " +args[0]+" "+args[1]);
  //code for animation
  for (Point p : points) {
    p.setSelected(false);
  }

  if (root.isPointInRegion(new PVector(args[0], args[1]), root.region) == false) {
    println(">Error: Point is outside of QuadTree!\n");
    writer.println(">Error: Point is outside of QuadTree!\n");
    return;
  }

  for (Point p : points) {
    if (p.pt.x == args[0] && p.pt.y == args[1]) {
      println(">Error: Point exists!\n");
      writer.println(">Error: Point exists!\n");
      return;
    }
  }
  points.add(new Point(new PVector(args[0], args[1])));
  points.get(points.size()-1).setSelected(true);

  //code for Quad Tree
  ArrayList<QuadTreeNode> nodePath= root.insert(root, points.get(points.size()-1));


  String animationStatus;
  if (isAnimationOn == true) {
    animationStatus = "ON";
    for (QuadTreeNode node : nodePath) {
      rbm.request(node.region.UL.x, node.region.UL.y, node.region.LR.x, node.region.LR.y, 1.5);
    }
  } else {
    animationStatus = "OFF";
  }
  println(">>>Status Line: Animation Status mode = "+animationStatus+", Total Number of Points = "+root.size+", Total Number of Nodes(includes root) = "+root.countNodes(root)+"<<<\n");
  writer.println(">>>Status Line: Animation Status mode = "+animationStatus+", Total Number of Points = "+root.size+", Total Number of Nodes(includes root) = "+root.countNodes(root)+"<<<\n");
}

void cmd_Report(int[] args) {  
  //code for animation
  for (Point p : points) {
    p.setSelected(false);
  }

  for (Point p : points) {
    if (p.isWithin(args)) {
      p.setSelected(true);
      p.render();
    }
  }

  println("r " + args[0]+" "+args[1]+" "+args[2]+" "+args[3]);
  writer.println("r " + args[0]+" "+args[1]+" "+args[2]+" "+args[3]);
  ArrayList<QuadTreeNode> nodePath = root.report(root, new PVector(args[0], args[1]), new PVector(args[2], args[3]));
  if (isAnimationOn == true) {  //turn on animation if true
    for (QuadTreeNode node : nodePath) {
      rbm.request(node.region.UL.x, node.region.UL.y, node.region.LR.x, node.region.LR.y, 3);
    }
  }
  String animationStatus;
  if (isAnimationOn == true) {
    animationStatus = "ON";
    rbm.request(args[0], args[1], args[2], args[3], 2);
  } else {
    animationStatus = "OFF";
  }
  println(">>>Status Line: Animation Status mode = "+animationStatus+", Total Number of Points = "+root.size+", Total Number of Nodes(includes root) = "+root.countNodes(root)+"<<<\n");
  writer.println(">>>Status Line: Animation Status mode = "+animationStatus+", Total Number of Points = "+root.size+", Total Number of Nodes(includes root) = "+root.countNodes(root)+"<<<\n");
}

void cmd_Count(int[] args) {
  //code for animation
  for (Point p : points) {
    p.setSelected(false);
  }
  for (Point p : points) {
    if (p.isWithin(args)) {
      p.setSelected(true);
    }
  }

  //code for quad tree
  println("c " + args[0]+" "+args[1]+" "+args[2]+" "+args[3]);
  writer.println("c " + args[0]+" "+args[1]+" "+args[2]+" "+args[3]);
  int count = root.count(root, new PVector(args[0], args[1]), new PVector(args[2], args[3]));
  println("\tNumber of points in the query region is: "+count);
  writer.println("\tNumber of points in the query region is: "+count);
  String animationStatus;
  if (isAnimationOn == true) {
    animationStatus = "ON";
    rbm.request(args[0], args[1], args[2], args[3], 2);
  } else {
    animationStatus = "OFF";
  }
  println(">>>Status Line: Animation Status mode = "+animationStatus+", Total Number of Points = "+root.size+", Total Number of Nodes(includes root) = "+root.countNodes(root)+"<<<\n");
  writer.println(">>>Status Line: Animation Status mode = "+animationStatus+", Total Number of Points = "+root.size+", Total Number of Nodes(includes root) = "+root.countNodes(root)+"<<<\n");
}

void cmd_Empty(int[] args) {  
  //code for animation
  for (Point p : points) {
    p.setSelected(false);
  }
  if (isAnimationOn == true) {  //turn on animation if true
    for (Point p : points) {
      if (p.isWithin(args)) {
        p.setSelected(true);
      }
    }
  }
  //code for quadtree
  println("e " + args[0]+" "+args[1]+" "+args[2]+" "+args[3]);
  writer.println("e " + args[0]+" "+args[1]+" "+args[2]+" "+args[3]);
  int numPoints = root.empty(root, new PVector(args[0], args[1]), new PVector(args[2], args[3]));
  if (numPoints > 0) {
    println("\tNO. This region is not empty.\n");
    writer.println("\tNO. This region is not empty.\n");
    ;
  } else {
    println("\tYES. This region is empty.\n");
    writer.println("\tYES. This region is empty.\n");
  }
  String animationStatus;
  if (isAnimationOn == true) {
    animationStatus = "ON";
    rbm.request(args[0], args[1], args[2], args[3], 2);
  } else {
    animationStatus = "OFF";
  }
  println(">>>Status Line: Animation Status mode = "+animationStatus+", Total Number of Points = "+root.size+", Total Number of Nodes(includes root) = "+root.countNodes(root)+"<<<\n");
  writer.println(">>>Status Line: Animation Status mode = "+animationStatus+", Total Number of Points = "+root.size+", Total Number of Nodes(includes root) = "+root.countNodes(root)+"<<<\n");
}

void cmd_OutputPts() {
  println("> This simulates end-of-program reporting of all points within QT to output (see output.txt!)");
  toOutput(">>> Hi There! Here are all the points!");
  for (Point p : points) {
    toOutput("  o Reporting Data Point: "+p.toString());
  }
}
