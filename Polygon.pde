class Polygon {
  Point head, tail;
  int num;
  Polygon() {
    num=0;  //count starts after head is assigned.
  }
  //add point p and divide the indexed segment
  void addPoint(int index, Point newPoint) {
    if (newPoint.insidePoly || isPolyNode(newPoint)) return;
    //first insert
    newPoint.inside();    //going to be inserted anyway.

    if (this.head==null) {
      this.head=newPoint;
      num++;
      return;
    }
    //renew head point
    if (index==0) {
      newPoint.next=this.head;
      this.head=newPoint;
      num++;
      return;
    }

    Point prevPoint=this.getPoint((index-1)%num);

    //insert in between
    newPoint.next=prevPoint.next;
    prevPoint.next=newPoint;
    num++;
  }
  boolean isPolyNode(Point p) {
    for (int i=0; i<num; i++)
      if (p.insidePoly || ((p.x==getPoint(i).x && p.y==getPoint(i).y))) {
        p.inside(); //if found using second condition  
        return true;
      }
    return false;
  }
  Point getPoint(int index) {
    Point p=this.head;
    int n=index;

    while (n>0) {
      if (p.next==null) {
        println("Polygon-getPoint;next point null"); 
        break;
      }//error-handling
      if (n>num) {
        println("Polygon-getPoint;out of range"); 
        break;
      }//error-handling

      p=p.next;
      n--;
    }//while

    return p;
  }
  //create and return an edge.
  //index 1: edge(1,2) etc...
  Edge getEdge(int index) {
    Edge e;
    e=new Edge(this.getPoint(index), this.getPoint((index+1)%num));
    return e;
  }
  boolean isPolyEdge(Edge e) {
    for (int i=0; i<=num; i++) {
      Point p1=getPoint(i%(num));
      Point p2=getPoint((i+1)%(num));
      Edge polyEdge = new Edge(p1, p2);
      if (polyEdge.equals(e)) return true;
    }
    return false;
  }
  Edge getInnerEdge() {
    Edge retedge=null;
    int r1=(int)random(0, num);
    int r2=(r1+1)%num;  
    int r3=(r2+1)%num;
    Point p1=poly.getPoint(r1);
    Point p2=poly.getPoint(r2);
    Point p3=poly.getPoint(r3);

    if (num==2) {
      return (new Edge(p1, p2));
    } else if (num==3) {
      Edge triEdge = new Edge(p1, p2);
      return (new Edge(triEdge.mid, p3));
    }
    Edge triEdge = new Edge(p1, p2);
    retedge=new Edge(triEdge.mid, p3);
    while (poly.isPolyEdge(retedge)) {
      r2 = r1+(int)random(0, num-1);
      r3 = r2+(int)random(0, num-1);
      while (abs(r2-r3)<2) r3=(int)random(0, num-1);  //prevent for selecting a single point
      p2=poly.getPoint(r2);
      p3=poly.getPoint(r3);
      println(p2, p3);
      //temp=new Edge(p2, p3);
      //Point pt = temp.calcMidPoint();
      retedge = new Edge(p2, p3);
    }

    return retedge;
  }

  //Returns an array of vectors: (x,y,index of edge)
  ArrayList<PVector> getIntersections(Edge oe) {
    ArrayList<PVector> inter = new ArrayList<PVector>();
    for (int i=0; i<num; i++) {
      Edge pe = this.getEdge(i);
      if (pe==oe) continue; 
      Point poi=pe.intersection(oe);
      if (poi!=null) {
        PVector p=new PVector(poi.x, poi.y, i);    //point of intersection

        inter.add(p);
      }
    }
    return inter;
  }
}

class Point {
  float x, y;
  Point next;
  boolean insidePoly=false;
  Point(float ox, float oy) {
    x=ox;
    y=oy;
    next=null;
  }
  Point(PVector op) {
    x=op.x;
    y=op.y;
    next=null;
  }
  void inside() {
    insidePoly=true;
  }
  //function to print coords when hovering above a point
  //bug-printing with no stop
  boolean once=true;
  void hover() {
    if (dist(mouseX, mouseY, this.x, this.y)<10)
    {
      if (once) {
        println(this); 
        once=false;
      }
    } else once=true;
  }
  String toString() {
    //String str = '('+Integer.toString(int(x))+','+Integer.toString(int(y))+')';
    String str = Float.toString(dist(this.x, this.y, midmid.x, midmid.y));
    return str;
  }
}

class Edge {
  Point p1, p2;
  float m;  //slope
  Point mid;
  Edge(Point _p1, Point _p2) {
    this.p1=_p1;
    this.p2=_p2;
    this.m=calcSlope();
    mid=calcMidPoint();
  }
  void show(color c) {
    strokeWeight(2/zoom);
    stroke(c);
    line(p1.x, p1.y, p2.x, p2.y);
  }
  void show(color c, float weight) {
    strokeWeight(weight/zoom);
    stroke(c);
    line(p1.x, p1.y, p2.x, p2.y);
  }
  Point calcMidPoint() {
    float midx=(p1.x+p2.x)/2;
    float midy=(p1.y+p2.y)/2;
    return new Point(midx, midy);
  }
  float calcSlope() {
    float slp = p2.y-p1.y;
    slp/=(p2.x-p1.x);
    return slp;
  }
  //function returns y(x)
  float getY(float x) {
    //y=mx-mx1+y1
    float y=m*x+getB();
    return y;
  }
  //function returns  b=-mx1+y1
  float getB() {
    return -m*p1.x+p1.y;
  }
  boolean pointOnEdge(Point p) {
    if (abs(this.getY(p.x)-p.y)<2)return true;
    return false;
  }
  //returns intersection points between two lines, null otherwise
  Point intersection(Edge e2) {
    Point retp = null;
    float x=((e2.getB()-this.getB())/(this.m-e2.m));
    if ( (x>min(p1.x, p2.x) && x<max(p1.x, p2.x)) && (x>min(e2.p1.x, e2.p2.x) && x<max(e2.p1.x, e2.p2.x)) )
      if (int(this.getY(x)-e2.getY(x)) <= 0.5)
        retp=new Point(x, this.getY(x));
    return retp;
  }
  boolean equals(Edge oe) {
    if (this.p1.x==oe.p1.x && this.p1.y==oe.p1.y &&
      this.p2.x==oe.p2.x && this.p2.y==oe.p2.y)
      return true;
    return false;
  }
}

Point minX() {
  Point min=new Point(width, height);
  for (Point p : points)
    if (p.x<min.x) min=p;
  return min;
}

Point minY() {
  Point min = new Point(width, height);
  for (Point p : points)
    if (p.y<min.y) min=p;
  return min;
}

Point maxX() {
  Point max = new Point(0, 0);
  for (Point p : points)
    if (p.x>max.x) max=p;
  return max;
}

Point maxY() {
  Point max = new Point(0, 0);
  for (Point p : points)
    if (p.y>max.y) max=p;
  return max;
}

//returns distance of a given poin p from edge e
//-1 if distance<epsilon
float distLine(Edge e, Point p) {
  //inverse equation -> y=-(1/m)x+b
  //Find closest point on the line
  //y=-(1/m)*x+b -> b=y+(1/m)*x
  float b = p.y+(1/e.m)*p.x;
  float y=-(1/e.m)*p.x+b;
  float x=(-e.m)*(y-b);
  float d=dist(p.x, p.y, x, y);
  if (d<epsilon) return -1;
  return d;
}

void addToPoly(int index, Point newpt) {
  Point p1=poly.getPoint((index-1)%poly.num);
  Point p2=poly.getPoint(index); 
  //here we need to remove an edge
  poly.addPoint(index, newpt);
}

//Returns null if all points are classified as inside, else returns the point
Point greyPoint() {
  for (int i=0; i<points.size(); i++) {
    if (!points.get(i).insidePoly) return points.get(i);
  }
  return null;
}