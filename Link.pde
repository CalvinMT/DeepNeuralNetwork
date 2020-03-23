class Link {
  
  float weight;
  float newWeight;
  
  float gradientX;
  float gradientY;
  float gradientZ;
  
  
  
  Link () {
    weight = random(-1.0, 1.0);
    newWeight = 0.0;
    setGradients(0.0, 0.0, 0.0);
  }
  
  
  
  void setGradients (float x, float y, float z) {
    gradientX = x;
    gradientY = y;
    gradientZ = z;
  }
  
  
  
  void updateWeight () {
    weight = newWeight;
  }
  
}
