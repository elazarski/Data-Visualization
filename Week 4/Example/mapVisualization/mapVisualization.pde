// Global Variables

PFont font; 
PImage mapImage;

Table locationTable;
Table dataTable;

float[] mins = {MIN_FLOAT, MIN_FLOAT, MIN_FLOAT};
float[] maxs = {MAX_FLOAT, MAX_FLOAT, MAX_FLOAT};

float min14 = 0;
float max14 = 0;
float min15 = 0;
float max15 = 0;
float min16 = 0;
float max16 = 0;

float dataMin;
float dataMax;

int rowCount;

int currentYear = 14;

float easing = 0.5;

void setup() {
//   font = loadFont("Univers-Bold-12.vlw");
//   textFont(font);
   size(650,400);
  
   dataTable = loadTable("oncampuscrime141516.csv", "header");
   mapImage = loadImage("map.png"); 
   locationTable = loadTable("locations.tsv", "header"); 
   rowCount = locationTable.getRowCount();
   
   // add new columns and initialize
   locationTable.addColumn("Crime 14", Table.FLOAT);
   locationTable.addColumn("Crime 15", Table.FLOAT);
   locationTable.addColumn("Crime 16", Table.FLOAT);
   for (TableRow row : locationTable.rows()) {
     row.setFloat("Crime 14", 0);
     row.setFloat("Crime 15", 0);
     row.setFloat("Crime 16", 0);
   }
   
   for (TableRow row : dataTable.rows()) {
    String state = row.getString(5);
    
    // find row in locationTable
    TableRow stateRow = locationTable.findRow(state, 0);
   
    // modify row in locationTable
    float[] crimeTotals = {stateRow.getFloat("Crime 14"), stateRow.getFloat("Crime 15"), stateRow.getFloat("Crime 16")};
    for (int i = 0; i < 3; i++) {
     int indexModifier = i * 11;
     
     // get data
     float murder = row.getFloat(12 + indexModifier);
     float negM = row.getFloat(13 + indexModifier);
     float rape = row.getFloat(14 + indexModifier);
     float fondling = row.getFloat(15 + indexModifier);
     float incest = row.getFloat(16 + indexModifier);
     float statutory = row.getFloat(17 + indexModifier);
     float robbery = row.getFloat(18 + indexModifier);
     float assault = row.getFloat(19 + indexModifier);
     float burglary = row.getFloat(20 + indexModifier);
     float motorT = row.getFloat(21 + indexModifier);
     float arson = row.getFloat(22 + indexModifier);
     
     if (Float.isNaN(murder)) { murder = 0; }
     if (Float.isNaN(negM)) { negM = 0; }
     if (Float.isNaN(rape)) { rape = 0; }
     if (Float.isNaN(fondling)) { fondling = 0; }
     if (Float.isNaN(incest)) { incest = 0; }
     if (Float.isNaN(statutory)) { statutory = 0; }
     if (Float.isNaN(robbery)) { robbery = 0; }
     if (Float.isNaN(assault)) { assault = 0; }
     if (Float.isNaN(burglary)) { burglary = 0; }
     if (Float.isNaN(motorT)) { motorT = 0; }
     if (Float.isNaN(arson)) { arson = 0; }
     
     
     float totalCrime = murder + negM + rape + fondling + incest + statutory + robbery + assault + burglary + motorT + arson;
     
     crimeTotals[i] += totalCrime;
    }
    
    stateRow.setFloat("Crime 14", crimeTotals[0]);
    stateRow.setFloat("Crime 15", crimeTotals[1]);
    stateRow.setFloat("Crime 16", crimeTotals[2]);
   }

  // get mins and maxs
   for (TableRow row : locationTable.rows()) {
      float crime14 = row.getFloat("Crime 14");
      float crime15 = row.getFloat("Crime 15");
      float crime16 = row.getFloat("Crime 16");
      
      if (crime14 < min14) {
        min14 = crime14;
      }
      if (crime14 > max14) {
        max14 = crime14;
      }
      
      if (crime15 < min15) {
        min15 = crime15;
      }
      if (crime15 > max15) {
        max15 = crime15;
      }
      
      if (crime16 < min16) {
        min16 = crime16;
      }
      if (crime16 > max16) {
        max16 = crime16;
      }
   }
   
   mins[0] = min14;
   mins[1] = min15;
   mins[2] = min16;
   dataMin = mins[0];
   
   maxs[0] = max14;
   maxs[1] = max15;
   maxs[2] = max16;
   dataMax = maxs[0];
}

void keyPressed() {
  // listen for space
   if (keyPressed && key == ' ') {
     if (currentYear >= 16) {
       currentYear = 14;
       dataMin = mins[0];
       dataMax = maxs[0];
     } else {
       currentYear++;
       dataMin = mins[currentYear-14];
       dataMax = maxs[currentYear-14];
     }
   }
}

void draw() {
   background(255); 
   image(mapImage, 0, 0);
   smooth( ); 
   fill(192, 0, 0); 
   noStroke( );   
   
   // set title
   String title = "Crime by state";
   surface.setTitle(title);
   
   // set subtitle
   String subtitle = "Crime for year 20" + currentYear;
   text(subtitle, 267, 20);
   
   // draw data
   for (TableRow row : locationTable.rows()) {
    float x = row.getFloat("x");
    float y = row.getFloat("y");
    
    String columnHeader = "Crime ";
    columnHeader += currentYear;
    
    float crime = row.getFloat(columnHeader);
    drawColorData(x,y,crime);
   }
}

void drawColorData(float x, float y, float value) {
   float percent = norm(value, dataMin, dataMax);
   color between = lerpColor(#FF4422, #4422CC, percent);  // red to blue
   fill(between);
   float radius = percent * 20;
   ellipse(x, y, radius, radius);
 }
