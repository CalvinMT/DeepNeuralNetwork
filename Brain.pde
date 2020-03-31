import java.util.Random;

class Brain {
  
  final String FILE_EXTENSION = ".nn";
  final String NETWORKS_DIRECTORY = "networks\\";
  
  final float LEARNING_RATE = 0.05;
  
  Structure structure;
  Output outputs[];
  
  InputType inputType;
  String networkName = "";
  boolean overwriteNN = false;
  
  String pathTrainingSet;
  String pathDataSet;
  String listRoot[];
  
  float rawInputTrainingSet[][];
  
  boolean isTraining = false;
  boolean isAnalysing = false;
  int nbOfTests = 0;
  int counterToNbOfTests = 0;
  int counterTested = 0;
  
  int resultedOutput = 0;
  int expectedOutput = 0;
  int correctOutput = 0;
  float correctRatio = 0;
  
  final float MAX_HEIGHT = 0.5; // in percentage (0.0 -> 1.0)
  int imageHeight;
  float imageX;
  float imageY;
  PImage currentImage = null;
  
  GraphDNN graph;
  
  
  
  Brain (InputType inputType, int nbInputs, int nbOuputs) {
    this(inputType, nbInputs, nbOuputs, "");
  }
  
  Brain (InputType inputType, int nbInputs, int nbOuputs, String networkName) {
    structure = new Structure(nbInputs, nbOuputs);
    this.inputType = inputType;
    this.networkName = networkName;
    if (! networkName.equals("")) {
      overwriteNN = true;
    }
    
    initGraphics();
  }
  
  Brain (InputType inputType, int nbInputs, int nbHiddens[], int nbOuputs) {
    this(inputType, nbInputs, nbHiddens, nbOuputs, "");
  }
  
  Brain (InputType inputType, int nbInputs, int nbHiddens[], int nbOuputs, String networkName) {
    structure = new Structure(nbInputs, nbHiddens, nbOuputs);
    this.inputType = inputType;
    this.networkName = networkName;
    if (! networkName.equals("")) {
      overwriteNN = true;
    }
    
    initGraphics();
  }
  
  Brain (InputType inputType, String networkName, boolean overwriteNN) {
    loadNetwork(networkName);
    this.overwriteNN = overwriteNN;
    this.inputType = inputType;
    
    String tmp[] = split(networkName, "\\");
    if (! overwriteNN) {
      tmp = split(tmp[tmp.length-1], "_");
      for (int i=0; i<tmp.length - 2; i++) {
        networkName = networkName.concat(tmp[i]);
      }
    }
    else {
      networkName = tmp[tmp.length-1];
    }
    
    initGraphics();
  }
  
  
  
  void initGraphics () {
    imageHeight = (int) (height * MAX_HEIGHT);
    imageX = 0.0;
    imageY = height - imageHeight;
    
    graph = new GraphDNN(width / 2, height / 2, width / 2, (height-2) / 2);
    graph.setGraduationMax(10, 10);
  }
  
  
  
  void initTraining (String pathTrainingSet, int nbOfTests) throws Exception {
    if (networkName.equals("")) {
      String tmp[] = split(pathTrainingSet, "\\");
      networkName = tmp[tmp.length-1];
    }
    this.nbOfTests = nbOfTests;
    graph.setValueMaxX(nbOfTests);
    graph.setValueMaxY(nbOfTests);
    counterToNbOfTests = 0;
    counterTested = 0;
    this.pathTrainingSet = pathTrainingSet;
    println("Training Set = " + pathTrainingSet);
    File root = new File(dataPath(pathTrainingSet));
    if (root.isDirectory()) {
      outputs = new Output[NB_OUTPUTS];
      listRoot = root.list();
      Collections.sort(Arrays.asList(listRoot), new NaturalOrderComparator());
      for (int i=0; i<listRoot.length; i++) {
        File dir = new File(dataPath(pathTrainingSet + listRoot[i]));
        if (dir.isDirectory()) {
          outputs[i] = new Output(dir.getName());
        }
      }
      println("Outputs found: " + outputs.length);
      if (outputs.length != NB_OUTPUTS) {
        throw new Exception("Number of outputs don't match. NB_OUTPUTS=" + NB_OUTPUTS);
      }
      isTraining = true;
    }
    else {
      throw new Exception("Path to training set isn't a directory or does not exist. pathTrainingSet=" + pathTrainingSet);
    }
  }
  
  void initTraining (float rawInputTrainingSet[][], String outputNames[], int nbOfTests) {
    this.rawInputTrainingSet = rawInputTrainingSet;
    this.nbOfTests = nbOfTests;
    graph.setValueMaxX(nbOfTests);
    graph.setValueMaxY(nbOfTests);
    counterToNbOfTests = 0;
    counterTested = 0;
    outputs = new Output[NB_OUTPUTS];
    for (int i=0; i<outputNames.length; i++) {
      outputs[i] = new Output(outputNames[i]);
    }
    isTraining = true;
  }
  
  
  
  void initAnalysis (String pathDataSet, String outputNames[]) throws Exception {
    counterToNbOfTests = 0;
    counterTested = 0;
    outputs = new Output[NB_OUTPUTS];
    if (outputs.length != outputNames.length) {
      throw new Exception("Number of outputs don't match. outputNames[]=" + outputNames.length + "    outputs=" + outputs.length);
    }
    for (int i=0; i<outputs.length; i++) {
      outputs[i] = new Output(outputNames[i]);
    }
    this.pathDataSet = pathDataSet;
    println("Data Set = " + pathDataSet);
    File root = new File(dataPath(pathDataSet));
    if (root.isDirectory()) {
      listRoot = root.list();
      nbOfTests = listRoot.length;
      graph.setValueMaxX(nbOfTests);
      graph.setValueMaxY(nbOfTests);
      isAnalysing = true;
    }
    else {
      throw new Exception("Path to data set isn't a directory or does not exist. pathDataSet=" + pathDataSet);
    }
  }
  
  
  
  // aka: cost of the network OR total error
  void calculateErrorIndexes () {
    float outputErrorIndex = 0.0;
    for (int i=0; i<structure.outputLayer.neurons.length; i++) {
      if (i == expectedOutput) {
        structure.outputLayer.neurons[i].expectedValue = 1.0;
        outputErrorIndex += (1 / 2) * Math.pow(1.0 - structure.outputLayer.neurons[i].value, 2);
      }
      else {
        structure.outputLayer.neurons[i].expectedValue = 0.0;
        outputErrorIndex += (1 / 2) * Math.pow(0.0 - structure.outputLayer.neurons[i].value, 2);
      }
    }
    for (int i=0; i<structure.outputLayer.neurons.length; i++) {
      structure.outputLayer.neurons[i].errorIndex = outputErrorIndex;
    }
  }
  
  // aka: delta rule
  float chainRuleOutput (int i, int j) {
    float x, y, z;
    x = structure.outputLayer.neurons[j].value - structure.outputLayer.neurons[j].expectedValue;
    y = sigmoidDerivative(structure.outputLayer.neurons[j].value);
    z = structure.outputLayer.previousLayer.neurons[i].value;
    structure.outputLayer.previousLayer.neurons[i].links[j].setGradients(x, y, z);
    return x * y * z;
  }
  
  // aka: delta rule
  float chainRuleHidden (int i, int j, int k) {
    float x, y, z;
    x = 0;
    for (int l=0; l<structure.hiddenLayers[i].nextLayer.neurons[k].links.length; l++) {
      x += structure.hiddenLayers[i].nextLayer.neurons[k].links[l].gradientX * structure.hiddenLayers[i].nextLayer.neurons[k].links[l].gradientY * structure.hiddenLayers[i].nextLayer.neurons[k].links[l].weight;
    }
    y = sigmoidDerivative(structure.hiddenLayers[i].nextLayer.neurons[k].value);
    z = structure.hiddenLayers[i].neurons[j].value;
    structure.hiddenLayers[i].neurons[j].links[k].setGradients(x, y, z);
    return x * y * z;
  }
  
  // aka: delta rule
  float chainRuleInput (int i, int j) {
    float x, y, z;
    x = 0;
    for (int k=0; k<structure.inputLayer.nextLayer.neurons[j].links.length; k++) {
      x += structure.inputLayer.nextLayer.neurons[j].links[k].gradientX * structure.inputLayer.nextLayer.neurons[j].links[k].gradientY * structure.inputLayer.nextLayer.neurons[j].links[k].weight;
    }
    y = sigmoidDerivative(structure.inputLayer.nextLayer.neurons[j].value);
    z = structure.inputLayer.neurons[i].value;
    structure.inputLayer.neurons[i].links[j].setGradients(x, y, z);
    return x * y * z;
  }
  
  void updateWeights () {
    for (int i=0; i<structure.inputLayer.neurons.length; i++) {
      for (int j=0; j<structure.inputLayer.neurons[i].links.length; j++) {
        structure.inputLayer.neurons[i].links[j].updateWeight();
      }
    }
    for (int i=0; i<structure.hiddenLayers.length; i++) {
      for (int j=0; j<structure.hiddenLayers[i].neurons.length; j++) {
        for (int k=0; k<structure.hiddenLayers[i].neurons[j].links.length; k++) {
          structure.hiddenLayers[i].neurons[j].links[k].updateWeight();
        }
      }
    }
  }
  
  void backpropagation () {
    calculateErrorIndexes();
    for (int i=0; i<structure.outputLayer.previousLayer.neurons.length; i++) {
      for (int j=0; j<structure.outputLayer.previousLayer.neurons[i].links.length; j++) {
          float gradientWithRespect = chainRuleOutput(i, j);
          structure.outputLayer.previousLayer.neurons[i].links[j].newWeight = structure.outputLayer.previousLayer.neurons[i].links[j].weight - (LEARNING_RATE * gradientWithRespect);
      }
    }
    for (int i=structure.hiddenLayers.length-2; i>=0; i--) {
      for (int j=0; j<structure.hiddenLayers[i].neurons.length; j++) {
        for (int k=0; k<structure.hiddenLayers[i].neurons[j].links.length; k++) {
          float gradientWithRespect = chainRuleHidden(i, j, k);
          structure.hiddenLayers[i].neurons[j].links[k].newWeight = structure.hiddenLayers[i].neurons[j].links[k].weight - (LEARNING_RATE * gradientWithRespect);
        }
      }
    }
    if (structure.hiddenLayers.length != 0) {
      for (int i=0; i<structure.inputLayer.neurons.length; i++) {
        for (int j=0; j<structure.inputLayer.neurons[i].links.length; j++) {
            float gradientWithRespect = chainRuleInput(i, j);
            structure.inputLayer.neurons[i].links[j].newWeight = structure.inputLayer.neurons[i].links[j].weight - (LEARNING_RATE * gradientWithRespect);
        }
      }
    }
    updateWeights();
  }
  
  
  
  float[] imageToArray (PImage image) {
    float result[] = new float[image.pixels.length];
    for (int i=0; i<image.pixels.length; i++) {
      result[i] = image.pixels[i] / (-16777216 / 2) - 1;
      /*if (values[i] == 0) {
        values[i] = -1;
      }*/
    }
    return result;
  }
  
  void train (PImage image) {
    if (image != null) {
      currentImage = image;
      train(imageToArray(image));
    }
  }
  
  void train (float values[]) {
    if (values.length > 0) {
      resultedOutput = analyse(values);
      if (resultedOutput == expectedOutput) {
        correctOutput++;
        correctRatio = (float) counterTested / (float) correctOutput;
      }
      backpropagation();
    }
  }
  
  
  
  float sigmoid (float x) {
    return 1 / (1 + (float) Math.exp(-x));
  }
  
  float sigmoidDerivative (float x) {
    return sigmoid(x) * (1 - sigmoid(x));
  }
  
  // aka: forward pass
  void compute () {
    for (int i=0; i<structure.hiddenLayers.length; i++) {
      for (int j=0; j<structure.hiddenLayers[i].neurons.length; j++) {
        float sumWeightedValue = 0;
        for (int k=0; k<structure.hiddenLayers[i].previousLayer.neurons.length; k++) {
          sumWeightedValue += (structure.hiddenLayers[i].previousLayer.neurons[k].links[j].weight * structure.hiddenLayers[i].previousLayer.neurons[k].value);
        }
        structure.hiddenLayers[i].neurons[j].value = sigmoid(sumWeightedValue);
      }
    }
    for (int i=0; i<structure.outputLayer.neurons.length; i++) {
      float sumWeightedValue = 0;
      for (int j=0; j<structure.outputLayer.previousLayer.neurons.length; j++) {
        sumWeightedValue += (structure.outputLayer.previousLayer.neurons[j].links[i].weight * structure.outputLayer.previousLayer.neurons[j].value);
      }
      structure.outputLayer.neurons[i].value = sigmoid(sumWeightedValue);
    }
  }
  
  
  
  int analyse (PImage image) {
    currentImage = image;
    return analyse(imageToArray(image));
  }
  
  int analyse (float values[]) {
    int result = 0;
    structure.inputLayer.setNeurons(values);
    compute();
    for (int i=1; i<structure.outputLayer.neurons.length; i++) {
      if (structure.outputLayer.neurons[i].value > structure.outputLayer.neurons[result].value) {
        result = i;
      }
    }
    counterTested++;
    return result;
  }
  
  
  
  void loadNetwork (String networkName) {
    if (! networkName.endsWith(FILE_EXTENSION)) {
      networkName = networkName.concat(FILE_EXTENSION);
    }
    if (! networkName.startsWith(NETWORKS_DIRECTORY)) {
      networkName = NETWORKS_DIRECTORY.concat(networkName);
    }
    BufferedReader reader = createReader(networkName);
    String line = null;
    try {
      line = reader.readLine();
      String nbNeuronsPerLayers[] = split(line, " ");
      int nbNeuronsInput = Integer.parseInt(nbNeuronsPerLayers[0]);
      int nbNeuronsOutput = Integer.parseInt(nbNeuronsPerLayers[nbNeuronsPerLayers.length - 1]);
      if (nbNeuronsPerLayers.length > 2) {
        int nbNeuronsHiddens[] = new int[nbNeuronsPerLayers.length - 2];
        for (int i=0; i<nbNeuronsHiddens.length; i++) {
          nbNeuronsHiddens[i] = Integer.parseInt(nbNeuronsPerLayers[i+1]);
        }
        structure = new Structure(nbNeuronsInput, nbNeuronsHiddens, nbNeuronsOutput);
      }
      else {
        structure = new Structure(nbNeuronsInput, nbNeuronsOutput);
      }
      line = reader.readLine();
      for (int i=0; i<structure.inputLayer.neurons.length; i++) {
        line = reader.readLine();
        String weights[] = split(line, " ");
        for (int j=0; j<structure.inputLayer.neurons[i].links.length; j++) {
          structure.inputLayer.neurons[i].links[j].weight = Float.parseFloat(weights[j]);
        }
      }
      for (int i=0; i<structure.hiddenLayers.length; i++) {
        line = reader.readLine();
        for (int j=0; j<structure.hiddenLayers[i].neurons.length; j++) {
          line = reader.readLine();
          String weights[] = split(line, " ");
          for (int k=0; k<structure.hiddenLayers[i].neurons[j].links.length; k++) {
            structure.hiddenLayers[i].neurons[j].links[k].weight = Float.parseFloat(weights[k]);
          }
        }
      }
      reader.close();
    }
    catch (IOException e) {
      e.printStackTrace();
    }
    catch (NumberFormatException e) {
      e.printStackTrace();
    }
  }
  
  
  
  void saveNetwork () {
    String fileName = networkName;
    if (! overwriteNN) {
      String nbNeuronsPerLayer = String.valueOf(structure.inputLayer.neurons.length);
      for (int i=0; i<structure.hiddenLayers.length; i++) {
        nbNeuronsPerLayer = nbNeuronsPerLayer.concat("-" + String.valueOf(structure.hiddenLayers[i].neurons.length));
      }
      nbNeuronsPerLayer = nbNeuronsPerLayer.concat("-" + String.valueOf(structure.outputLayer.neurons.length));
      String date = String.valueOf(day()) + "-" + String.valueOf(month()) + "-" + String.valueOf(year());
      String time = String.valueOf(hour()) + "-" + String.valueOf(minute()) + "-" + String.valueOf(second());
      fileName = networkName + "_" + nbNeuronsPerLayer + "_" + date + "_" + time + FILE_EXTENSION;
    }
    if (! fileName.endsWith(FILE_EXTENSION)) {
      fileName = fileName.concat(FILE_EXTENSION);
    }
    if (! fileName.startsWith(NETWORKS_DIRECTORY)) {
      fileName = NETWORKS_DIRECTORY.concat(fileName);
    }
    PrintWriter writer = createWriter(fileName);
    writer.print(structure.inputLayer.neurons.length);
    for (int i=0; i<structure.hiddenLayers.length; i++) {
      writer.print(" ");
      writer.print(structure.hiddenLayers[i].neurons.length);
    }
    writer.print(" ");
    writer.print(structure.outputLayer.neurons.length);
    writer.println();
    writer.println();
    for (int i=0; i<structure.inputLayer.neurons.length; i++) {
      for (int j=0; j<structure.inputLayer.neurons[i].links.length; j++) {
        writer.print(structure.inputLayer.neurons[i].links[j].weight);
        if (j < (structure.inputLayer.neurons[i].links.length - 1)) {
          writer.print(" ");
        }
      }
      writer.println();
    }
    if (structure.hiddenLayers.length > 0) {
      writer.println();
      for (int i=0; i<structure.hiddenLayers.length; i++) {
        for (int j=0; j<structure.hiddenLayers[i].neurons.length; j++) {
          for (int k=0; k<structure.hiddenLayers[i].neurons[j].links.length; k++) {
            writer.print(structure.hiddenLayers[i].neurons[j].links[k].weight);
            if (k < (structure.hiddenLayers[i].neurons[j].links.length - 1)) {
              writer.print(" ");
            }
          }
          writer.println();
        }
        writer.println();
      }
    }
    writer.flush();
    writer.close();
    println("Neural Network saved as: " + fileName);
  }
  
  
  
  void update () {
    if (isTraining) {
      if (counterToNbOfTests < nbOfTests) {
        if (inputType == InputType.IMAGE_BW  ||  inputType == InputType.IMAGE_COLOUR) {
          int randomDir = new Random().nextInt(outputs.length);
          expectedOutput = randomDir;
          String listFiles[] = new File(dataPath(pathTrainingSet + "\\" + listRoot[randomDir])).list();
          int randomFile = new Random().nextInt(listFiles.length);
          File file = new File(dataPath(pathTrainingSet + "\\" + listRoot[randomDir] + "\\" + listFiles[randomFile]));
          if (file.isFile()) {
            train(loadImage(file.getAbsolutePath()));
          }
        }
        else if (inputType == InputType.RAW) {
          int r = new Random().nextInt(rawInputTrainingSet.length);
          train(rawInputTrainingSet[r]);
        }
        counterToNbOfTests++;
      }
      else {
        isTraining = false;
        println("Data tested: " + counterTested);
        saveNetwork();
        println("Done");
        println();
      }
    }
    else if (isAnalysing) {
      if (counterToNbOfTests < nbOfTests) {
        if (inputType == InputType.IMAGE_BW  ||  inputType == InputType.IMAGE_COLOUR) {
          File file = new File(dataPath(pathDataSet + "\\" + listRoot[counterToNbOfTests]));
          if (file.isFile()) {
            resultedOutput = analyse(loadImage(file.getAbsolutePath()));
          }
        }
        else if (inputType == InputType.RAW) {
          resultedOutput = analyse(rawInputTrainingSet[counterToNbOfTests]);
        }
        counterToNbOfTests++;
      }
      else {
        isAnalysing = false;
        println("Data tested: " + counterTested);
        println("Done");
        println();
      }
    }
    else {
      // do nothing
    }
    graph.update(counterToNbOfTests, correctOutput);
  }
  
  
  
  void show () {
    // IMAGE
    if (inputType == InputType.IMAGE_BW  &&  currentImage != null) {
      if (currentImage.height < imageHeight) {
        currentImage.resize((currentImage.width * imageHeight / currentImage.height), imageHeight);
      }
      image(currentImage, imageX, imageY);
    }
    
    // STRUCTURE
    structure.show();
    
    // GRAPH
    graph.show();
    
    // RESULT
    fill(0);
    textSize(32);
    textAlign(LEFT, TOP);
    text("Test: " + counterTested + " / " + nbOfTests, width / 2, 25);
    text("Result: " + resultedOutput, width / 2, 25 * 2 + 32);
    if (! isAnalysing) {
      text("Expected: " + expectedOutput, width / 2, 25 * 3 + 32 * 2);
      text("Correct: " + correctOutput, width / 2, 25 * 4 + 32 * 3);
      text("Incorrect: " + (counterTested - correctOutput), width / 2, 25 * 5 + 32 * 4);
      text("Ratio: " + String.format("%.2f", correctRatio), width / 2, 25 * 6 + 32 * 5);
    }
  }
  
}
