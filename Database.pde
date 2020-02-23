Table table;

void savePoints() {  
  table = new Table();

  table.addColumn("x");
  table.addColumn("y");

  for (int i=0; i<points.size(); i++) {
    Point p = points.get(i);
    TableRow newRow = table.addRow();
    newRow.setInt("x", (int)p.x);
    newRow.setInt("y", (int)p.y);
  }
  int fileNum=1;
  String fileName="data/";
  fileName+=fileNum+".csv";
  saveTable(table, fileName);

  println(fileName+" has been saved");
}
void loadPoints() {
  noLoop();
  resetSteps();
  mid=null;
  points.clear();

  table = loadTable("1.csv", "header");

  for (TableRow row : table.rows()) {

    int x = row.getInt("x");
    int y=row.getInt("y");
    points.add(new Point(x, y));
  }

  poly=new Polygon();
  poly.addPoint(poly.num, minY());
  poly.addPoint(poly.num, maxY());
  resetSteps();
  loop();

  println("1.csv has been loaded");
}