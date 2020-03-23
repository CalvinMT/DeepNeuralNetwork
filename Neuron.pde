class Neuron {
  
  float value;
  float expectedValue;
  float errorIndex;
  
  Link links[];
  
  
  
  Neuron () {
    value = 0.0;
    expectedValue = 0.0;
    errorIndex = 0.0;
  }
  
}
