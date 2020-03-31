class Graph {
  
  final float paddingTop = 10.0;
  final float paddingBottom = 30.0;
  final float paddingLeft = 50.0;
  final float paddingRight = 30.0;
  
  List <List <Float>> points = new ArrayList <List <Float>> ();
  List <List <Float>> lines = new ArrayList <List <Float>> ();
  
  float x, y, w, h;
  
  float valueMaxX = 1;
  float valueMaxY = 1;
  float stepX = 1;
  float stepY = 1;
  
  int graduationMaxX = 1;
  int graduationMaxY = 1;
  float graduationDistanceX = 1;
  float graduationDistanceY = 1;
  
  boolean isGraduationVisible = true;
  boolean isGridVisible = true;
  boolean isPaddingActive = false;
  
  
  
  Graph (float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    
    updatePadding();
  }
  
  
  
  void addPoint (float x, float y) {
    List point = new ArrayList <Float> ();
    point.add(x);
    point.add(y);
    points.add(point);
  }
  
  void addLine (float x1, float y1, float x2, float y2) {
    List line = new ArrayList <Float> ();
    line.add(x1);
    line.add(y1);
    line.add(x2);
    line.add(y2);
    lines.add(line);
  }
  
  
  
  void setValueMaxX (float valueMaxX) {
    this.valueMaxX = valueMaxX;
    updateSteps();
  }
  
  void setValueMaxY (float valueMaxY) {
    this.valueMaxY = valueMaxY;
    updateSteps();
  }
  
  void setGraduationMax (int graduationMaxX, int graduationMaxY) {
    this.graduationMaxX = graduationMaxX;
    this.graduationMaxY = graduationMaxY;
    updateGraduationDistances();
    updateSteps();
  }
  
  void setGraduationMaxX (int graduationMax) {
    setGraduationMax(graduationMax, graduationMaxY);
  }
  
  void setGraduationMaxY (int graduationMax) {
    setGraduationMax(graduationMaxX, graduationMax);
  }
  
  void setGraduationVisible (boolean isVisible) {
    isGraduationVisible = isVisible;
    updatePadding();
  }
  
  void setGridVisible (boolean isVisible) {
    isGridVisible = isVisible;
  }
  
  

  void updateGraduationDistances () {
    graduationDistanceX = w / graduationMaxX;
    graduationDistanceY = h / graduationMaxY;
  }
  
  void updateSteps () {
    stepX = valueMaxX / graduationMaxX;
    stepY = valueMaxY / graduationMaxY;
  }
  
  void updatePadding () {
    if (w > 0  &&  h > 0) {
      if (isGraduationVisible && !isPaddingActive) {
        x += paddingLeft;
        y += paddingTop;
        w -= paddingRight + paddingLeft;
        h -= paddingBottom + paddingTop;
        isPaddingActive = true;
      } else if (!isGraduationVisible && isPaddingActive) {
        x -= paddingLeft;
        y -= paddingTop;
        w += paddingRight + paddingLeft;
        h += paddingBottom + paddingTop;
        isPaddingActive = false;
      }
      updateGraduationDistances();
    }
  }
  
  
  
  void showAxis () {
    stroke(0);
    strokeWeight(2.0);
    line(x, y + h, x + w, y + h);
    line(x, y, x, y + h);
  }
  
  void showGraduation () {
    if (isGraduationVisible) {
      stroke(0);
      strokeWeight(2.0);
      textAlign(CENTER, CENTER);
      for (int i=0; i<=graduationMaxX; i++) {
        line(x + (graduationDistanceX * i), y + h, x + (graduationDistanceX * i), y + h + 5);
        if (stepX == (int) stepX) {
          text(i * (int) stepX, x + (graduationDistanceX * i), y + h + 15);
        }
        else {
          text(String.format("%.2f", i * stepX), x + (graduationDistanceX * i), y + h + 15);
        }
      }
      textAlign(RIGHT, CENTER);
      for (int i=graduationMaxY; i>=0; i--) {
        line(x, y + h - (graduationDistanceY * i), x - 5, y + h - (graduationDistanceY * i));
        if (stepY == (int) stepY) {
          text(i * (int) stepY, x - 12, y + h - (graduationDistanceY * i));
        }
        else {
          text(String.format("%.2f", i * stepY), x - 12, y + h - (graduationDistanceY * i));
        }
      }
    }
  }
  
  void showGrid () {
    if (isGridVisible) {
      stroke(200);
      strokeWeight(1.0);
      for (int i=1; i<=graduationMaxX; i++) {
        line(x + (graduationDistanceX * i), y + h, x + (graduationDistanceX * i), y);
      }
      for (int i=graduationMaxY; i>=1; i--) {
        line(x, y + h - (graduationDistanceY * i), x + w, y + h - (graduationDistanceY * i));
      }
    }
  }
  
  void showPoints () {
    // FIXME - not working
    /*stroke(255, 0, 0);
    strokeWeight(1.5);
    for (int i=0; i<points.size(); i++) {
      x = x + (points.get(i).get(0)) * w / valueMaxX;
      y = y + h - (points.get(i).get(1)) * h / valueMaxY;
      point(x, y);
    }*/
  }
  
  void showLines () {
    float x1, y1, x2, y2;
    stroke(255, 0, 0);
    strokeWeight(1.5);
    for (int i=0; i<lines.size(); i++) {
      x1 = x + (lines.get(i).get(0)) * w / valueMaxX;
      y1 = y + h - (lines.get(i).get(1)) * h / valueMaxY;
      x2 = x + (lines.get(i).get(2)) * w / valueMaxX;
      y2 = y + h - (lines.get(i).get(3)) * h / valueMaxY;
      line(x1, y1, x2, y2);
    }
  }
  
  void show () {
    showGrid();
    showPoints();
    showLines();
    showAxis();
    showGraduation();
  }
  
}
