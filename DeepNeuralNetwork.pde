import graph2d.*;

final int NB_INPUTS = 4;
final int NB_HIDDENS[] = new int[]{8, 8};
final int NB_OUTPUTS = 16;

final String BW4pxOutputNames[] = new String[]{"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"};

Brain brain;



void setup () {
  size(800, 800);
  
  brain = new Brain(InputType.IMAGE_BW, NB_INPUTS, NB_HIDDENS, NB_OUTPUTS);
  //brain = new Brain(InputType.IMAGE_BW, "Black&White_4px_4-8-8-16", false);
  try {
    brain.initTraining("Black&White_4px", 100000);
    //brain.initAnalysis("Black&White_4px", BW4pxOutputNames);
  }
  catch (Exception e) {
    e.printStackTrace();
  }
}



void draw () {
  background(255);
  
  brain.update();
  brain.show();
}
