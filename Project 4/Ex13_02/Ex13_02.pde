// Ex11_03

color[] dessert = {#9F9694, #791F33, #BA3D49, #F1E6D4, #E2E1DC};
color[] palette = dessert;
PFont titleFont, labelFont;

Table artData;
int rowCount;
float mx = 29; // mouseX

void setup() {
  size(600, 200);
  artData = new Table("braque.tsv");
  rowCount = artData.getRowCount();
  println("rowCount = " + rowCount);
  titleFont = loadFont("GillSans-Bold-18.vlw");
  labelFont = loadFont("GillSans-12.vlw");
  smooth();
}

void draw() {
  noCursor();
  background(palette[0]);
  textFont(titleFont);
  stroke(palette[3]);
  fill(palette[3]);
  textAlign(CENTER);
  text("Google Searches for Georges Braque", width/2, 20);
  
  textFont(labelFont);
  textAlign(LEFT);

  // Read popularity
  for (int row = 0; row < rowCount; row++) {
    
    // Braque's popularity data
    String dates = artData.getString(row, 0);
    float popularity = artData.getFloat(row, 1);
    float x = map(row, 0, 104, 30, 575);
    float y = map(popularity, -2, 4, 150, 20);
//    println(nfp(popularity, 1, 3) + " : " + nf(y, 3, 2));
//    noLoop();
    
    // Slicing interaction for dates and values
    // Placed here so it goes behind the data lines
    strokeWeight(1);
    if((mx > 30) && (mx < 575)) {
      line(mx, 30, mx, 150);
//      if(mx == x) {
      if(abs(mx - x) < 2) {
        fill(palette[1]);
        text(dates, mx + 6, 40);
//        text(popularity, mx + 6, 55);
        text(nfp(popularity, 1, 3), mx + 6, 55);
      }
    }  
    
    // Lines and dots
    stroke(palette[1]);
    line(x, y, x, 150);
    noStroke();
    fill(palette[1]);
    int d = 3;
    ellipse(x, y, d, d);
  }
  
  // Read dates
  for (int row = 0; row < rowCount; row += 12) {
    String dates = artData.getString(row, 0);
    float popularity = artData.getFloat(row, 1);
    float x = map(row, 0, 104, 30, 575);
    float y = map(popularity, -2, 4, 150, 20);
    
    // Dates
    text(dates, x, 170);
//    println(dates);
//    noLoop();
      
    // Lines and dots for January
    stroke(palette[1]);
    strokeWeight(3);
    strokeCap(SQUARE);
    line(x, y, x, 150);
    noStroke();
  }
}

void keyPressed() {
  if(key == CODED) {
    if(keyCode == LEFT) {
      mx -= 2;
    } else if (keyCode == RIGHT) {
      mx += 2;
    }
  }
}

void mouseMoved() {
  mx = mouseX;
}

