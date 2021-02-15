class QuadTreeNode { //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
  QuadTreeNode[] children;  //0-NE 1-NW 2-SW 3-SE (counter clockwise, same as Cartesian coordinate system)
  Region region;  //The surruonding region of this node
  int size;  //A counter v.size containing the number of data points in the subtree rooted at this node
  boolean isALeaf;  //true if this node is a leaf
  Point point;  //the point this node contains

  public QuadTreeNode(PVector UL, PVector LR) {
    children = new QuadTreeNode[4];  //default null for all children
    region = new Region(UL, LR); 
    size = 0;  //default zero
    isALeaf = true;  //defualt true, new node must be a leaf node
    point = null;
  }

  public ArrayList<QuadTreeNode> insert(QuadTreeNode node, Point newPoint) {
    ArrayList<QuadTreeNode> nodePath = new ArrayList<QuadTreeNode>();
    if (isPointInRegion(newPoint.pt, node.region) == false) {      //if the point is outside the region then do nothing
      return nodePath;
    }
    println("\tVisiting node (LL("+node.region.UL.x+","+node.region.UL.y+"), UR("+node.region.LR.x+","+node.region.LR.y+"))");
    writer.println("\tVisiting node (LL("+node.region.UL.x+","+node.region.UL.y+"), UR("+node.region.LR.x+","+node.region.LR.y+"))"); 
    nodePath.add(node);
    if (node.isALeaf && node.point == null) {            //base case: because only leaft node contains the data point
      node.size++;
      node.point = newPoint;
      return nodePath;
    }
    if (node.children[0] != null) {                      //recursive case: if the node has already been subdivided, just add to corresponding children
      node.size++;
      nodePath.addAll(node.children[0].insert(node.children[0], newPoint));
      nodePath.addAll(node.children[1].insert(node.children[1], newPoint));
      nodePath.addAll(node.children[2].insert(node.children[2], newPoint));
      nodePath.addAll(node.children[3].insert(node.children[3], newPoint));
      return nodePath;
    }                                                     //recursive case: if the node has not been subdivided yet, first subdivide, then add to corresponding children
    Point oldPoint = node.point;
    node.isALeaf = false;  //change node status
    node.point = null;
    node.size++;

    PVector UL = node.region.UL;  //This is the parent region's LL of four chilren below
    PVector LR = node.region.LR;  //This is the parent region's UR of four chilren below
    float xValDiff = LR.x-UL.x;
    float yValDiff = LR.y-UL.y;
    node.children[0]= new QuadTreeNode(new PVector(UL.x+(xValDiff)/2, UL.y), new PVector(LR.x, UL.y+(yValDiff)/2));  //create NE([0]) sub-region
    node.children[1]= new QuadTreeNode(new PVector(UL.x, UL.y), new PVector(UL.x+(xValDiff)/2, UL.y+(yValDiff)/2));  //create NW([1]) sub-region
    node.children[2]= new QuadTreeNode(new PVector(UL.x, UL.y+(yValDiff)/2), new PVector(UL.x+(xValDiff)/2, LR.y));  //create SW([2]) sub-region
    node.children[3]= new QuadTreeNode(new PVector(UL.x+(xValDiff)/2, UL.y+(yValDiff)/2), new PVector(LR.x, LR.y));  //create SE([3]) sub-region
    //insert the new point into each sub region, if the point doesnot belong there(i.e. outside of NE) this will do nothing
    nodePath.addAll(node.children[0].insert(node.children[0], newPoint));
    nodePath.addAll(node.children[1].insert(node.children[1], newPoint));
    nodePath.addAll(node.children[2].insert(node.children[2], newPoint));
    nodePath.addAll(node.children[3].insert(node.children[3], newPoint));
    //println("\t\tNote: Above is steps to insert new point, below is steps to make sure only leaves stores data-points");
    //writer.println("\t\tNote: Above is steps to insert new point, below is steps to make sure only leaves stores data-points");
    //adjust old point's location, because only left contains data point
    nodePath.addAll(node.children[0].insert(node.children[0], oldPoint));
    nodePath.addAll(node.children[1].insert(node.children[1], oldPoint));
    nodePath.addAll(node.children[2].insert(node.children[2], oldPoint));
    nodePath.addAll(node.children[3].insert(node.children[3], oldPoint));
    return nodePath;
  }  

  public ArrayList<QuadTreeNode> report(QuadTreeNode node, PVector queryUL, PVector queryLR) {
    ArrayList<QuadTreeNode> results = new ArrayList<QuadTreeNode>();
    Region queryRegion = new Region(queryUL, queryLR);
    if (node == null) {  
      return results;  //return empty arraylist
    }
    if (isRect1OverlapRect2(queryRegion, node.region) == false) {  //
      return results;  //If they are disjoint then do nothing
    }
    if (node.isALeaf) {
      if (node.point != null && isPointInRegion(node.point.pt, queryRegion)) {  //only add non-null point
        results.add(node);
        println("\tVisiting quadrant (LL("+node.region.UL.x+","+node.region.UL.y+"), UR("+node.region.LR.x+","+node.region.LR.y+"))");
        writer.println("\tVisiting quadrant (LL("+node.region.UL.x+","+node.region.UL.y+"), UR("+node.region.LR.x+","+node.region.LR.y+"))");
        println("\t\tReporting data-point ("+node.point.pt.x+","+node.point.pt.y+")");
        writer.println("\t\tReporting data-point ("+node.point.pt.x+","+node.point.pt.y+")");
      }
      return results;
    }
    results.add(node);
    println("\tVisiting quadrant (LL("+node.region.UL.x+","+node.region.UL.y+"), UR("+node.region.LR.x+","+node.region.LR.y+"))");
    writer.println("\tVisiting quadrant (LL("+node.region.UL.x+","+node.region.UL.y+"), UR("+node.region.LR.x+","+node.region.LR.y+"))");
    results.addAll(report(node.children[0], queryUL, queryLR));  //report node's NE child
    results.addAll(report(node.children[1], queryUL, queryLR));  //report node's NW child
    results.addAll(report(node.children[2], queryUL, queryLR));  //report node's SW child
    results.addAll(report(node.children[3], queryUL, queryLR));  //report node's SE child
    return results;
  }

  public int count(QuadTreeNode node, PVector queryUL, PVector queryLR) {
    int count = 0;
    Region queryRegion = new Region(queryUL, queryLR);
    if (node == null) {
      return 0;
    }
    if (isRect1OverlapRect2(node.region, queryRegion) == false) {  //
      return 0;  //If they are disjoint then do nothing
    }
    if (node.isALeaf) {
      if (node.point != null && isPointInRegion(node.point.pt, queryRegion)) {  //only add non-null point
        count++;
      }
      return count;
    }
    count += count(node.children[0], queryUL, queryLR);
    count += count(node.children[1], queryUL, queryLR);
    count += count(node.children[2], queryUL, queryLR);
    count += count(node.children[3], queryUL, queryLR);
    return count;
  }

  public int empty(QuadTreeNode node, PVector queryUL, PVector queryLR) {
    int count = 0;
    Region queryRegion = new Region(queryUL, queryLR);
    if (node == null) {
      return 0;
    }
    if (isRect1OverlapRect2(node.region, queryRegion) == false) {  //
      return 0;  //If they are disjoint then do nothing
    }
    if (node.isALeaf) {
      if (node.point != null && isPointInRegion(node.point.pt, queryRegion)) {  //only add non-null point
        count++;
      }
      return count;
    }
    count += empty(node.children[0], queryUL, queryLR);
    count += empty(node.children[1], queryUL, queryLR);
    count += empty(node.children[2], queryUL, queryLR);
    count += empty(node.children[3], queryUL, queryLR);
    return count;
  }

  /*-----------------------------------------------------------------------
   |>>> Drawing functions
   +----------------------------------------------------------------------- */
  public void drawQuadTree() {

    stroke(153);
    if (this.isALeaf) {  //draw the leaf
      PVector UL = this.region.UL;  //This is the parent region's LL of four chilren below
      PVector LR = this.region.LR;  //This is the parent region's UR of four chilren below
      float xValDiff = LR.x-UL.x;
      float yValDiff = LR.y-UL.y;
      fill(255);
      rect(UL.x, UL.y, xValDiff, yValDiff);
      if (this.point != null) {
        point.render();
      }
      fill(255);
    } else {  //draw its children
      this.children[0].drawQuadTree();
      this.children[1].drawQuadTree();
      this.children[2].drawQuadTree();
      this.children[3].drawQuadTree();
    }
  }



  /*-----------------------------------------------------------------------
   |>>> Comparsion functions
   +----------------------------------------------------------------------- */
  private boolean isPointInRegion(PVector p, Region region) {
    if ((p.x >= region.UL.x && p.x < region.LR.x) && (p.y >= region.UL.y && p.y < region.LR.y) ) {  //if p's xVal and y Val arebetween range
      return true;
    } else {
      return false;
    }
  }


  private boolean isRect1OverlapRect2(Region rect1, Region rect2) {
    //Conditions for rect1 NOT overlap rect2, if any one of condtion is false, then they are disjoint
    //Cond1. If rect1's left edge is to the right of the rect2's right edge, - then rect1 is Totally to right Of rect2
    //Cond2. If rect1's right edge is to the left of the rect2's left edge, - then rect1 is Totally to left Of rect1
    //Cond3. If rect1's top edge is below rect2's bottom edge, - then rect1 is Totally below rect2
    //Cond4. If rect1's bottom edge is above rect2's top edge, - then rect1 is Totally above rect2
    return rect1.UL.x <= rect2.LR.x && rect1.LR.x >= rect2.UL.x && rect1.UL.y <= rect2.LR.y && rect1.LR.y >= rect2.UL.y;     
    // return true means they are overlaping, false means they are disjoint
  }

  /*-----------------------------------------------------------------------
   |>>> Debuging functions
   +----------------------------------------------------------------------- */
  public int countNodes(QuadTreeNode node) {
    int count = 1;
    if (node.isALeaf) {
      return 1;
    }
    count += node.children[0].countNodes(node.children[0]);
    count += node.children[0].countNodes(node.children[1]);
    count += node.children[0].countNodes(node.children[2]);
    count += node.children[0].countNodes(node.children[3]);
    return count;
  }

  public String toString() {
    String info; 
    if (children[0]==null) {  //all children have same status
      info = "Information of this node: NE: null NW: null SW: null SE: null,";
    } else {
      info = "Information of this node: NE: not null NW: not null SW: not null SE: not null,";
    }
    info += " UL: (" +region.UL.x+", "+ region.UL.y+"), LR: ("+region.LR.x+", "+region.LR.y+"),";
    info += " isALeaf: "+isALeaf+", ";
    if (point == null) {
      info += " point: null,";
    } else {
      info += " point: ("+point.pt.x+", "+point.pt.y+"),";
    }
    info += " size: " + size;
    return info + "\n";
  }

  public void printTopLevel() {
    print("Root: " + this.toString());
    if (this.children[0]==null) {
      println("NE: null");
      println("NW: null");
      println("SW: null");
      println("SE: null\n");
    } else {
      print("NE: "+ this.children[0].toString());
      print("NW: "+ this.children[1].toString());
      print("SW: "+ this.children[2].toString());
      print("SE: "+ this.children[3].toString()+"\n");
    }
  }
}
