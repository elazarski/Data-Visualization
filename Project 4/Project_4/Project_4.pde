// Global variables
PFont font;

// all data
Table dataTable;

// visualization data
int currentCrime = 0;
String[] crimes = {"INTERFERENCE WITH PUBLIC OFFICER", "GAMBLING", "LIQUOR LAW VIOLATION"};
Table interferenceTable;
Table gamblingTable;
Table liquorTable;

float crimeMin = MIN_FLOAT;
float crimeMax = MAX_FLOAT;

// location references
float xStart = 80;
float xEnd;
float yStart = 50;
float yEnd;

// tab variables
float[] tabStart;
float[] tabEnd;
float tabTop;
float tabBottom;
float tabPad = 10;
PImage[] tabImageHighlight;

Table initTable() {
  Table retTable = new Table();
  retTable.addColumn("year");
  retTable.addColumn("count");
  
  for (int i = 2001; i <= 2018; i++) {
   TableRow newYear = retTable.addRow();
   newYear.setInt("year", i);
   newYear.setFloat("count", 0);
  }
  
  return retTable;
}

void setup() {
  size(1000, 600);
  
  // load data from preprocessed file
  // original file (https://catalog.data.gov/dataset/crimes-2001-to-present-398a4) cut down to only include three crime types
  // file preprocessed in pandas
  // each year exists from 2001 - 2018
  dataTable = loadTable("data.csv", "header");
  
  // extract information from dataTable and put into visualization tables
  interferenceTable = initTable();
  gamblingTable = initTable();
  liquorTable = initTable();
  
  for (TableRow row : dataTable.rows()) {
   // parse date and get year
   String dateStr = row.getString("Date");
   String year = dateStr.substring(6, 10);
   
   // update visualization tables based on primary type
   String type = row.getString("Primary Type");
   if (type.contains("INTERFERENCE")) {
     TableRow yearRow = interferenceTable.findRow(year, 0);
     float existingCount = yearRow.getFloat("count");
     existingCount++;
     yearRow.setFloat("count", existingCount);
   } else if (type.contains("GAMBLING")) {
     TableRow yearRow = gamblingTable.findRow(year, 0);
     float existingCount = yearRow.getFloat("count");
     existingCount++;
     yearRow.setFloat("count", existingCount);
   } else if (type.contains("LIQUOR")) {
     TableRow yearRow = liquorTable.findRow(year, 0);
     float existingCount = yearRow.getFloat("count");
     existingCount++;
     yearRow.setFloat("count", existingCount);
   } else {
    println("ERROR IN FILE"); 
   }
  }
  
  // set crime minimum and maximum
  for (TableRow row : interferenceTable.rows()) {
    float count = row.getFloat("count");
    int year = row.getInt("year");
    
    if (count < crimeMin || year == 2001) {
      crimeMin = count;
    }
    if (count > crimeMax || year == 2001) {
      crimeMax = count;
    }
  }
  for (TableRow row : gamblingTable.rows()) {
    float count = row.getFloat("count");
    
    if (count < crimeMin) {
      crimeMin = count;
    }
    if (count > crimeMax) {
      crimeMax = count;
    }
  }
  for (TableRow row : liquorTable.rows()) {
    float count = row.getFloat("count");
    
    if (count < crimeMin) {
      crimeMin = count;
    }
    if (count > crimeMax) {
      crimeMax = count;
    }
  }
  
  // set location references=
  xEnd = width - xStart;
  yEnd = height - yStart;
}

void draw() {
  // grey background
  background(224);
  
  // create plot rectangle
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(xStart, yStart, xEnd, yEnd);
  
  // draw visualization parts 
  drawTitle();
  drawAxisLabels();
  drawXLabels();
  drawYLabels();
  drawTabs();
  
  if (currentCrime == 0) {
    drawGraph(interferenceTable);
  } else if (currentCrime == 1) {
    drawGraph(gamblingTable); 
  } else {
    drawGraph(liquorTable);
  }
}

void drawTitle() {
  surface.setTitle(crimes[currentCrime]);
}

void drawAxisLabels() {
  fill(0);
  textSize(13);
  
  // y axis
  text("Number of\ncrimes\ncommited", xStart - 75, (yStart + yEnd)/2);
  
  // x axis
  text("Year", (xStart + xEnd)/2, yEnd + 40);
}

void drawXLabels() {
  fill(0);
  textSize(10);
  textAlign(CENTER, TOP);
  
  for (int i = 0; i < 18; i++) {
     float x = map(i + 2001, 2001, 2018, xStart, xEnd);
     text(i + 2001, x, yEnd + 10);
  }
}

void drawYLabels() {
  for (float yIncrement = crimeMin; yIncrement < crimeMax; yIncrement += 200) {
    float y = map(floor(yIncrement), crimeMin, crimeMax, yEnd, yStart);
    text((int)yIncrement, xStart - 15, y);
  }
}

void drawTabs() {
  rectMode(CORNERS);
  noStroke();
  textSize(20);
  textAlign(LEFT);
  
  if (tabStart == null) {
    tabStart = new float[3];
    tabEnd = new float[3];
  }
  
  float runningX = xStart;
  tabTop = yStart - textAscent() - 15;
  tabBottom = yStart;
  
  // create tabs
  for (int i = 0; i < 3; i++) {
    // get first word for tab title
    String title = crimes[i];
    if (title.contains(" ")) {
      title = title.substring(0, title.indexOf(' '));
    }
    tabStart[i] = runningX;
    float titleWidth = textWidth(title);
    tabEnd[i] = tabStart[i] + tabPad + titleWidth + tabPad;
    fill(i == currentCrime ? 255 : 224);
    rect(tabStart[i], tabTop, tabEnd[i], tabBottom);
    fill(i == currentCrime ? 0 : 64);
    text(title, runningX + tabPad, yStart - 10);
    runningX = tabEnd[i];
  }
  tabStart[0] = runningX;
  float titleWidth = textWidth("Interference");
  tabEnd[0] = tabStart[0] + tabPad + titleWidth + tabPad;
}

void drawGraph(Table data) {
  float barWidth = 10;
  noStroke();
  rectMode(CORNERS);
  
  for (TableRow row : data.rows()) {
    float year = (float)row.getInt("year");
    float count = row.getFloat("count");
    
    float x = map(year, 2001, 2018, xStart, xEnd);
    float y = map(count, crimeMin, crimeMax, yEnd, yStart);
    
    rect(x - (barWidth/2), y, x + (barWidth/2), yEnd);
  }
}

// listen for mouse press
void mousePressed() {
  // is it even in the tab row?
  if (mouseY > tabTop && mouseY < tabBottom) {
    // what column is it?
    for (int i = 0; i < 3; i++) {
       if (mouseX > tabStart[i] && mouseX < tabEnd[i]) {
          currentCrime = i; 
       }
    }
  }
}
