class GraphDNN extends Graph2D {
  
  GraphDNN (PApplet parent) {
    super(parent);
  }
  
  
  
  void update (int counterToNbOfTests, int correctOutput) {
    if (counterToNbOfTests > 0) {
      addLine(counterToNbOfTests - 1, correctOutput - 1, counterToNbOfTests, correctOutput);
    }
  }
  
  
  
  @Override
  void show () {
    super.show();
  }
  
}
