class Layer {
  
  Neuron neurons[];
  
  Layer previousLayer;
  Layer nextLayer;
  
  
  
  Layer (int size) {
    neurons = new Neuron[size];
    for (int i=0; i<size; i++) {
      neurons[i] = new Neuron();
    }
  }
  
  
  
  void linkTo (Layer layer) {
    for (int i=0; i<neurons.length; i++) {
      neurons[i].links = new Link[layer.neurons.length];
      for (int j=0; j<layer.neurons.length; j++) {
        neurons[i].links[j] = new Link();
      }
    }
    layer.previousLayer = this;
    nextLayer = layer;
  }
  
  
  
  void setNeurons (float values[]) {
    for (int i=0; i<neurons.length; i++) {
      neurons[i].value = values[i];
    }
  }
  
}
