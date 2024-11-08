// global variables
FloatTable data;

// for plotting
float dataMin, dataMax;
float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

int rowCount;
int columnCount;
int currentColumn = 0;


int yearMin, yearMax;
int[] years;
int yearInterval = 1;
int volumeInterval = 200;
int volumeIntervalMinor = 5;

// tabs
float[] tabLeft, tabRight;
float tabTop, tabBottom;
float tabPad = 10;

// style
Integrator[] interpolators;
PFont plotFont;
boolean gridLines = false;

Float[][] vertexes;

void setup( ) {
  size(1600, 900);
  
  // load data
  data = new FloatTable("crime.tsv");
  rowCount = data.getRowCount( );
  columnCount = data.getColumnCount( );
  years = int(data.getRowNames( ));
  yearMin = years[0];
  yearMax = years[years.length - 1];
  dataMin = 0;
  dataMax = ceil(data.getTableMax( ) / volumeInterval) * volumeInterval;
  interpolators = new Integrator[rowCount];
  for (int row = 0; row < rowCount; row++) {
    float initialValue = data.getFloat(row, 0);
    interpolators[row] = new Integrator(initialValue);
    interpolators[row].attraction = 0.1; // Set lower than the default
  }

  plotX1 = 160;
  plotX2 = width - 100;
  labelX = 60;
  plotY1 = 225;
  plotY2 = height - 120;
  labelY = height - 40;
  plotFont = createFont("Avenir-Medium",20);
  textFont(plotFont);
  smooth( );
  
  vertexes = new Float[rowCount+1][2];
}

void draw( ) {
   
  background(#eeeeee);
  // Show the plot area as a white box
  fill(255);
  rectMode(CORNERS);
  noStroke( );
  rect(plotX1, plotY1, plotX2, plotY2);
  drawTitleTabs( );
  drawAxisLabels( );
  for (int row = 0; row < rowCount; row++) {
    interpolators[row].update( );

  }
  drawYearLabels( );
  drawVolumeLabels( );
  noStroke( );
  fill(#a1cdea);
  drawDataArea(currentColumn);
   
//Mouse Hovering
  for (int i = 0; i < rowCount; i++) {
    float x = vertexes[i][0];
    float y = vertexes[i][1];      
      if((mouseX > plotX1) && (mouseX < plotX2)) {
        fill(#eeeeee);
        strokeWeight(2);
        stroke(#d4284a);
        line(mouseX, plotY1+34, mouseX, plotY2-1);
          if (mouseX >= x - 39 && mouseX <= x + 39) {
            if (mouseY >= y - height && mouseY <= y + height) {   
              int value = floor(interpolators[i].value);             
              String text = str(value);
              fill(#d4284a, 20);
              fill(#d4284a);
              textSize(32);
              text(text, mouseX+73, plotY1+62);
            }
          }                    
      }
  }
}

void drawTitleTabs( ) {
  rectMode(CORNERS);
  stroke(#ffffff);
  strokeWeight(1);
  //noStroke( );
  textSize(30);
  textAlign(LEFT);
  // On first use of this method, allocate space for an array
  // to store the values for the left and right edges of the tabs.
  if (tabLeft == null) {
    tabLeft = new float[columnCount];
    tabRight = new float[columnCount];
  }
  float runningX = plotX1;
  tabTop = plotY1 - textAscent( ) - 15;
  tabBottom = plotY1;
  for (int col = 0; col < columnCount; col++) {
    String title = data.getColumnName(col);
    tabLeft[col] = runningX;
    float titleWidth = textWidth(title);
    tabRight[col] = tabLeft[col] + tabPad + titleWidth + tabPad;
    // If the current tab, set its background white; otherwise use pale gray.
    fill(col == currentColumn ? 255 : 224);
    rect(tabLeft[col], tabTop, tabRight[col], tabBottom);
    // If the current tab, use black for the text; otherwise use dark gray.
    fill(col == currentColumn ? 0 : 64);
    text(title, runningX + tabPad, plotY1 - 10);
    runningX = tabRight[col];
    
  }
  fill(#000000);
  textSize(45);
  textAlign(CENTER, CENTER);
  textFont(plotFont);
  textSize(40);
  text("Crime Rate in Chicago", width*0.5, height*0.05);
  textSize(30);
  text("From 2001 through 2018", width*0.5, height*0.12); 
  
}

void keyPressed() {
  if (key == ' ') {
    gridLines = !gridLines; 
  }
}

void mousePressed( ) {
  if (mouseY > tabTop && mouseY < tabBottom) {
    for (int col = 0; col < columnCount; col++) {
      if (mouseX > tabLeft[col] && mouseX < tabRight[col]) {
        setCurrent(col);
      }
    }
  }
}

void setCurrent(int col) {
  currentColumn = col;
  for (int row = 0; row < rowCount; row++) {
    interpolators[row].target(data.getFloat(row, col));
  }
}

void drawAxisLabels( ) {
  fill(0);
  textSize(25);
  textLeading(15);
  textAlign(CENTER, CENTER);
  text("Cases", labelX, (plotY1+plotY2)/2);
  textAlign(CENTER);
  text("Year", (plotX1+plotX2)/2, labelY);
  
    fill(0);
  textSize(22);
  text("* Please press spacebar to show/hide gridlines.", width*0.80, height*0.96);
}

void drawYearLabels( ) {
  fill(0);
  textSize(20);
  textAlign(CENTER);
  // Use thin, gray lines to draw the grid
  stroke(200);
  strokeWeight(1);
  for (int row = 0; row < rowCount; row++) {
    if (years[row] % yearInterval == 0) {
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      text(years[row], x, plotY2 + textAscent( ) + 10);
      
      if (gridLines) {
        line(x, plotY1, x, plotY2);
      }
    }
  }
}

void drawVolumeLabels( ) {
  fill(0);
  textSize(20);
  textAlign(RIGHT);
  stroke(128);
  strokeWeight(1);
  for (float v = dataMin; v <= dataMax; v += volumeIntervalMinor) {
    if (v % volumeIntervalMinor == 0) { // If a tick mark
      float y = map(v, dataMin, dataMax, plotY2, plotY1);
        if (v % volumeInterval == 0) { // If a major tick mark
        float textOffset = textAscent( )/2; // Center vertically
        if (v == dataMin) {
          textOffset = 0; // Align by the bottom
        } else if (v == dataMax) {
          textOffset = textAscent( ); // Align by the top
        }
        text(floor(v), plotX1 - 10, y + textOffset);
        line(plotX1 - 4, y, plotX1, y); // Draw major tick
        
        if (gridLines) {
          line(plotX1, y, plotX2, y); 
        }
        
      } else {
        //line(plotX1 - 2, y, plotX1, y); // Draw minor tick
      }
    }
  }
}

void drawDataArea(int col) {
  beginShape( );
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = interpolators[row].value;
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      vertex(x, y);
      
      vertexes[row][0] = x;
      vertexes[row][1] = y;
    }
  }
  vertex(plotX2, plotY2);
  vertex(plotX1, plotY2);
  endShape(CLOSE);
}
