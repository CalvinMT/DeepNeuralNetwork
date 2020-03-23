class Structure {
  
  Layer inputLayer;
  Layer hiddenLayers[];
  Layer outputLayer;
  
  final float MAX_WIDTH = 0.5; // in percentage (0.0 -> 1.0)
  final float MAX_HEIGHT = 0.5; // in percentage (0.0 -> 1.0)
  float neuronSize;
  float inputTab;
  float hiddenTabs[];
  float outputTab;
  float horizontalTab;
  
  final boolean LINK_COLOUR = true;
  final boolean LINK_ALPHA = true;
  
  
  
  Structure (int nbNeuronsInput, int nbNeuronsOutput) {
    inputLayer = new Layer(nbNeuronsInput);
    hiddenLayers = new Layer[0];
    outputLayer = new Layer(nbNeuronsOutput);
    
    inputLayer.linkTo(outputLayer);
    
    initGraphics();
  }
  
  Structure (int nbNeuronsInput, int nbNeuronsHidden[], int nbNeuronsOutput) {
    inputLayer = new Layer(nbNeuronsInput);
    hiddenLayers = new Layer[nbNeuronsHidden.length];
    for (int i=0; i<nbNeuronsHidden.length; i++) {
      hiddenLayers[i] = new Layer(nbNeuronsHidden[i]);
    }
    outputLayer = new Layer(nbNeuronsOutput);
    
    inputLayer.linkTo(hiddenLayers[0]);
    for (int i=0; i<nbNeuronsHidden.length-1; i++) {
      hiddenLayers[i].linkTo(hiddenLayers[i+1]);
    }
    hiddenLayers[hiddenLayers.length-1].linkTo(outputLayer);
    
    initGraphics();
  }
  
  
  
  void initGraphics () {
    // GRAPHICS SIZE
    float graphMaxWidth = width * MAX_WIDTH;
    float graphMaxHeight = height * MAX_HEIGHT;
    float graphWidth;
    float graphHeight = graphMaxHeight;
    
    // NEURON SIZE
    int maxNeurons = 0;
    for (int i=0; i<hiddenLayers.length; i++) {
      if (hiddenLayers[i].neurons.length > maxNeurons) {
        maxNeurons = hiddenLayers[i].neurons.length;
      }
    }
    if (inputLayer.neurons.length > maxNeurons) {
      maxNeurons = inputLayer.neurons.length;
    }
    if (outputLayer.neurons.length > maxNeurons) {
      maxNeurons = outputLayer.neurons.length;
    }
    neuronSize = graphMaxHeight / maxNeurons;
    graphWidth = neuronSize * ((hiddenLayers.length * 2 + 1) + 2);
    if (graphWidth > graphMaxWidth) {
      neuronSize -= ((graphWidth - graphMaxWidth) / ((hiddenLayers.length * 2 + 1) + 2));
      graphHeight = graphMaxHeight - ((graphWidth - graphMaxWidth) * graphMaxHeight / graphWidth);
      graphWidth = graphMaxWidth;
    }
    
    // TABS
    inputTab = (graphMaxHeight - (inputLayer.neurons.length * neuronSize)) / 2;
    hiddenTabs = new float[hiddenLayers.length];
    for (int i=0; i<hiddenTabs.length; i++) {
      hiddenTabs[i] = (graphMaxHeight - (hiddenLayers[i].neurons.length * neuronSize)) / 2;
    }
    outputTab = (graphMaxHeight - (outputLayer.neurons.length * neuronSize)) / 2;
    horizontalTab = (graphMaxWidth - graphWidth) / 2;
  }
  
  
  
  void setLinkColour (Link link) {
    if (LINK_COLOUR) {
      float red = 255.0 - (link.weight * 255.0);
      float green = link.weight * 255.0;
      if (LINK_ALPHA) {
        stroke(red, green, 0, 255.0 - (red / 1.2));
      }
      else {
        stroke(red, green, 0);
      }
    }
    else if (LINK_ALPHA) {
      float alpha = 255.0 - (link.weight * 255.0);
      stroke(0, 0, 0, alpha);
    }
    else {
      stroke(0);
    }
  }
  
  void show () {
    // LINKS
    strokeWeight(1);
    for (int i=0; i<inputLayer.neurons.length; i++) {
      for (int j=0; j<inputLayer.nextLayer.neurons.length; j++) {
        setLinkColour(inputLayer.neurons[i].links[j]);
        if (hiddenLayers.length != 0) {
          line(horizontalTab + neuronSize, neuronSize * i + inputTab + (neuronSize/2), horizontalTab + neuronSize * 2, neuronSize * j + hiddenTabs[0] + (neuronSize/2));
        }
        else {
          line(horizontalTab + neuronSize, neuronSize * i + inputTab + (neuronSize/2), horizontalTab + neuronSize * 2, neuronSize * j + outputTab + (neuronSize/2));
        }
      }
    }
    for (int i=0; i<hiddenLayers.length; i++) {
      for (int j=0; j<hiddenLayers[i].neurons.length; j++) {
        for (int k=0; k<hiddenLayers[i].nextLayer.neurons.length; k++) {
          setLinkColour(hiddenLayers[i].neurons[j].links[k]);
          if (i == (hiddenLayers.length - 1)) {
            line(horizontalTab + neuronSize * 2 * (i+1) + neuronSize, neuronSize * j + hiddenTabs[i] + (neuronSize/2), horizontalTab + neuronSize * 2 * (i+2), neuronSize * k + outputTab + (neuronSize/2));
          }
          else {
            line(horizontalTab + neuronSize * 2 * (i+1) + neuronSize, neuronSize * j + hiddenTabs[i] + (neuronSize/2), horizontalTab + neuronSize * 2 * (i+2), neuronSize * k + hiddenTabs[i+1] + (neuronSize/2));
          }
        }
      }
    }
    
    // NEURONS
    fill(255);
    stroke(0);
    ellipseMode(CORNER);
    for (int i=0; i<inputLayer.neurons.length; i++) {
      ellipse(horizontalTab, neuronSize * i + inputTab, neuronSize, neuronSize);
    }
    for (int i=0; i<hiddenLayers.length; i++) {
      for (int j=0; j<hiddenLayers[i].neurons.length; j++) {
        ellipse(horizontalTab + neuronSize * 2 * (i+1), neuronSize * j + hiddenTabs[i], neuronSize, neuronSize);
      }
    }
    for (int i=0; i<outputLayer.neurons.length; i++) {
      ellipse(horizontalTab + neuronSize * 2 * (hiddenLayers.length+1), neuronSize * i + outputTab, neuronSize, neuronSize);
    }
  
    // VALUES
    fill(0);
    textSize(9);
    textAlign(CENTER, CENTER);
    for (int i=0; i<inputLayer.neurons.length; i++) {
      text(String.format("%.2f", inputLayer.neurons[i].value), horizontalTab + neuronSize / 2, neuronSize * i + inputTab + (neuronSize / 2));
    }
    for (int i=0; i<hiddenLayers.length; i++) {
      for (int j=0; j<hiddenLayers[i].neurons.length; j++) {
        text(String.format("%.2f", hiddenLayers[i].neurons[j].value), horizontalTab + neuronSize * 2 * (i+1) + (neuronSize / 2), neuronSize * j + hiddenTabs[i] + (neuronSize / 2));
      }
    }
    for (int i=0; i<outputLayer.neurons.length; i++) {
      text(String.format("%.2f", outputLayer.neurons[i].value), horizontalTab + neuronSize * 2 * (hiddenLayers.length+1) + (neuronSize / 2), neuronSize * i + outputTab + (neuronSize / 2));
    }
  }
  
}
