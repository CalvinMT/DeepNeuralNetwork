class GraphDNN extends Graph {
  
  GraphDNN (float x, float y, float w, float h) {
    super(x, y, w, h);
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
