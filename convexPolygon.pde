//    *Constructing a Convex Polygon from random points*
//    Equations:
//          
//          y-y1=m(x-x1) ;Given slope m and a point (x1,y1)
//          m=(y2-y1)/(x2-x1) ;Given two points
//  
//    Classes:
//            Polygon - creates the polygon from given points
//            Point - represents a node with (x,y) values and a Point.next for poligon creation
//            Edge - connect an edge between two points, provide slope, y(x) and b calc functions
//
//  
//    Problems:
//            -Sometimes it adds an inner point (ideas: inner edge selected is an edge of the polygon, intersection==the point from the edge...)
//            -Point is selected on an edge or a very close to an edge (epsilon)
//            (FIXED)-Poly is not convexial, point is selected outside of the polygon
//            (FIXED)-Not all points are being classified (sometimes 1-2 pts remain grey) 
//            -Poly is not convexial, points are being selected to create 'outer spikes'
//
color RED = color(240, 40, 40);
color GREEN = color(40, 240, 40);
color BLUE = color(40, 40, 240);
color ORANGE = #FFD00F;
ArrayList<Point> points;  //AL of points
Polygon poly;            //Main polygon        
int epsilon=5;          //epsilon for distance
int numberOfPoints=20;

void setup() {
  size(600, 600);

  init();
}

//Clear current polygon and points on field; fill with new points.
void init() {
  points=new ArrayList<Point>();
  poly=new Polygon();
  mid=null;      //First middle blue edge
  for (int i=0; i<numberOfPoints; i++) {
    int x=(int)random(50, 550);
    int y=(int)random(50, 550);
    points.add(new Point(x, y));
  }


  //set the first points of the polygon by min/max X/Y coords
  poly.addPoint(poly.num, minY());
  //if (dist(poly.getPoint(0).x, poly.getPoint(0).y, temp.x, temp.y)>epsilon)
  poly.addPoint(poly.num, maxY());
  //if (dist(poly.getPoint(1).x, poly.getPoint(1).y, maxY().x, maxY().y)>epsilon)
  //poly.addPoint(poly.num, maxY());
  //if (dist(poly.getPoint(2).x, poly.getPoint(2).y, minX().x, minY().y)>epsilon)
  //poly.addPoint(poly.num, minX());
}


boolean autoStep=false;
void draw() {
  background(0);

  translate(x0 + width/2, y0 + height/2);
  scale(zoom);
  translate(-x0 - width/2, -y0 - height/2);



  showPoints();
  showEdges();
  showExtra();
  testModeBtn();
  if (autoStep && !done) step++;
  steps();
}


//Function for extra graphical displays on screen
//CURRENT: 
void showExtra() {
  if (midmid==null) return;
  for (Point p : points) p.hover();
}

void testModeBtn() {
  strokeWeight(1);
  stroke(235, 235, 255);
  fill(0);
  String str = "Normal Mode";
  if (testMode) {
    fill(255);
    str = "Test Mode";
  }
  int rad=30;
  ellipse(40, height-40-5, rad, rad);
  if (dist(mouseX, mouseY, 40, height-40)<rad/2 +1) {
    textSize(10);
    textAlign(LEFT);
    rectMode(CORNER);
    stroke(255, 100);
    fill(255, 50);
    rect(60, height-55, 100, 20);
    fill(255);
    text(str, 70, height-40);
  }
}

int step=0;
int numOfSteps=8;
Edge mid=null;
boolean done=false, noInter=false, testMode=false;
boolean firstTime=true;
boolean once[]=new boolean[5];

void resetSteps() {
  step=0;
  numOfSteps=8;
  once[0]=false;
  midmid=null;
  if (done) mid=null;
  done=false;
}

Point midmid;
void steps() {
  boolean pointAdded=false, gotFarthestPoint=false;  
  String str="";
  Point farthestPoint=null;
  Edge edgeToFarthest=null;
  ArrayList<PVector> por=new ArrayList<PVector>();
  textSize(20);
  textAlign(CENTER);


  if (done) {
    if (midmid==null) midmid=mid.mid;
    str = "DONE! Press r to reset";
    fill(255);
    text(str, width/2, 30);
    fill(BLUE, 100);
    ellipse(midmid.x, midmid.y, 20/zoom, 20/zoom);
    fill(255, 100);
    ellipse(midmid.x, midmid.y, 10/zoom, 10/zoom);

    return;
  }
  if (!firstTime) {
    if (mid!=null) {   
      fill(BLUE);
      ellipse(mid.mid.x, mid.mid.y, 20/zoom, 20/zoom);
      fill(255);
      ellipse(mid.mid.x, mid.mid.y, 10/zoom, 10/zoom);
    }
  }


  if (step==0) {
    if (!noInter) {
      str = "Press n to apply the next step";
      fill(255);
      text(str, width/2, 30);
      farthestPoint=new Point(0, 0);
      return;
    } else {  //need to check that we still have points outside, else stop
      str = "There are no intersection points, point is inside the polygon";
      if (poly.num==3) str="There are no intersection points, farthest point was added";
      textAlign(CENTER);
      fill(140, 140, 255);
      text(str, width/2, 30);
      fill(BLUE);
      ellipse(mid.mid.x, mid.mid.y, 20/zoom, 20/zoom);
      fill(255);
      ellipse(mid.mid.x, mid.mid.y, 10/zoom, 10/zoom);
    }
  }
  if (step>=1) {
    if (step==1 && (poly.num<=3)) {
      str = "Selecting a random inner edge";
      if (poly.num==3) str+=" (will remain)";
      fill(140, 140, 255);
      text(str, width/2, 30);
    }
    if (poly.num==3 && !once[0]) {
      mid = poly.getInnerEdge(); 
      once[0]=true;
    }
    if (mid==null)mid = poly.getInnerEdge();
    if (poly.num<=3) mid.show(BLUE);
  }


  if (step>=2) {
    if (step==2 && firstTime) {
      str = "Finding the mid-point of the selected edge";
      fill(200, 200, 255);
      text(str, width/2, 30);
    }
    fill(BLUE);
    ellipse(mid.mid.x, mid.mid.y, 20/zoom, 20/zoom);
    fill(255);
    ellipse(mid.mid.x, mid.mid.y, 10/zoom, 10/zoom);
  }

  if (step>=3) {
    firstTime=false;

    if (step==3) {
      str = "Finding the farthest point from selected mid-point";
      fill(200, 140, 255);
      text(str, width/2, 30);
    }
    if (!gotFarthestPoint) {
      float max=0;
      farthestPoint=new Point(0, 0);
      for (int i=0; i<points.size(); i++) {
        Point op = points.get(i);  //selected point
        if (!op.insidePoly && !(poly.isPolyNode(op)) && (!(mid.pointOnEdge(op)) || poly.num<3) ) {  //if not part of poly
          if (dist(mid.mid.x, mid.mid.y, op.x, op.y)>max) {
            max=dist(mid.mid.x, mid.mid.y, op.x, op.y);
            farthestPoint=op;
            gotFarthestPoint=true;
          }
        }
      }
    }
    if (farthestPoint.x==0 && farthestPoint.y==0) {
      Point temp = greyPoint();
      if (temp==null) done=true;
      else {
        farthestPoint=temp;
        gotFarthestPoint=true;
      }
    }
    fill(RED, 200);
    ellipse(farthestPoint.x, farthestPoint.y, 25/zoom, 25/zoom);
    fill(255, 200);
    ellipse(farthestPoint.x, farthestPoint.y, 10/zoom, 10/zoom);
  }
  if (step>=4) {
    if (step==4) {
      str = "Connect the two points with an edge";
      fill(255, 40, 40);
      text(str, width/2, 30);
    }
    if (edgeToFarthest==null)edgeToFarthest = new Edge(mid.calcMidPoint(), farthestPoint);
    edgeToFarthest.show(RED);
  }
  PVector inter=null;
  if (step>=5) {
    if (poly.num<=2) {
      poly.addPoint(3, farthestPoint);
      pointAdded=true;
      farthestPoint.inside();
      noInter=true;
      resetSteps();
      return;
    }
    if (step==5) {
      str = "Find the intersection point";
      fill(GREEN);
      text(str, width/2, 30);
    }
    if (inter==null) {
      por = poly.getIntersections(edgeToFarthest);
      for (PVector pv : por) {
        Point p=new Point(pv.x, pv.y);
        if (!poly.isPolyNode(p)) {
          inter=pv;
          fill(GREEN, 150);
          ellipse(p.x, p.y, 40/zoom, 40/zoom);
          break;  //there is only one intersection point.
        }
      }
    }
  }

  if (step>=6) {
    if (inter!=null) {//divide the current edge into two//add point
      if (step==6) {
        str = "There is an intersection point";
        textAlign(CENTER);
        fill(140, 140, 255);
        text(str, width/2, 30);
        noInter=false;
      }
    } else {  //need to check that we stiil have points outside, else stop
      //step=0;      //to continue with current midline
      resetSteps();  //to select a new midline
      farthestPoint.inside();
      noInter=true;
      return;
    }
  }
  //if there was an intersection point -> find the intersecting edge.
  Edge interEdge=null;
  if (inter!=null && step>=7) {
    if (step==7) {
      str = "Notice the polygon line which was intersected";
      str+=" ("+(int)inter.z+")";
      textAlign(CENTER);
      fill(ORANGE, 220);
      text(str, width/2, 30);
    }
    if (interEdge==null) interEdge=poly.getEdge((int)inter.z);
    strokeWeight(5);
    interEdge.show(ORANGE, 7);
  }

  if (step>=8) {
    if (step==8) {
      str = "Add the point to poly and divide the edge";
      textAlign(CENTER);
      fill(255, 220);
      text(str, width/2, 30);
    }

    if (!pointAdded)
      poly.addPoint((int)inter.z+1, farthestPoint);
    resetSteps();
    pointAdded=true;
  }
}

//add a point to our currently constructed polygon
//input: index of point, point to input
//output:
void showEdges() {
  int count=0;
  for (int i=0; i<poly.num; i++) {
    Point p1=poly.getPoint(i);
    Point p2=poly.getPoint((i+1)%poly.num);
    if (p1!=p2) {
      strokeWeight(2/zoom);
      stroke(40, 230, 40);
      textSize(22);
      fill(255, 130, 130);
      text(count, (p2.x+p1.x)/2 +10, (p2.y+p1.y)/2 +10);
      count++;
      line(p1.x, p1.y, p2.x, p2.y);
    }
  }
}

void showPoints() {
  int cntr=1;
  for (int i=0; i<points.size(); i++) {
    noStroke();
    Point p=points.get(i);
    for (int j=0; j<poly.num; j++) {
      if (p.insidePoly) fill(0, 255, 0, 180);  
      else fill(255, 150);
    }
    ellipse(p.x, p.y, 13, 13);
    fill(255, 180);
    textSize(12);
    text(cntr, p.x, p.y+18);
    cntr++;
  }
}

float x0=0, y0=0;
float zoom=1, scl;

void mouseDragged() {
  x0=x0-(mouseX-pmouseX)/zoom;
  y0=y0-(mouseY-pmouseY)/zoom;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e > 0) {
    scl = 0.97;
  } else {
    scl = 1.02;
  }

  zoom *= scl;
}


void mousePressed() {
  if ( (dist(mouseX, mouseY, 40, height-40)<15)) testMode=!testMode;
}

void keyPressed() {
  if (key == CODED) {
    float move=40;
    if (keyCode == UP) {
      y0-=move/zoom;
    } else if (keyCode == DOWN) {
      y0+=move/zoom;
    } else if (keyCode == LEFT) {
      x0-=move/zoom;
    }
    else if (keyCode == RIGHT) {
      x0+=move/zoom;
    }
  } 
  if (key=='r' || key=='R') {
    zoom=1;
    x0=y0=0;
    noInter=false;
    firstTime=true;
    resetSteps();
    println("\n");
    init();
  } else if (key=='c') {
    x0=y0=0;
    zoom=1;
  } else if ((key=='q' || key=='Q')) {
    autoStep=!autoStep;
  } else if ((key=='n' || key=='N') && !done) {
    step++;
    if (step>numOfSteps) resetSteps();
  } else if (key=='s' || key=='S') {
    savePoints();
  } else if (key=='=') {
        scl = 1.2;
    zoom *= scl;    
  } else if (key=='-') {
        scl = 0.7;
    zoom *= scl;
  } else if (key=='1') {
    noLoop();
    noInter=false;
    firstTime=true;
    loadPoints();
  }
}