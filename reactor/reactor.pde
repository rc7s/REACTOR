// REACTOR by RYAN CHIN - github @rc7s - www.ryanchin.co
// IMPORT MINIM LIBRARY
import ddf.minim.*;
import ddf.minim.analysis.*;
// VARIABLES
Minim minim; // start Minim library
AudioPlayer player; // player is an AudioPlayer
FFT fft; // FFT stands for Fast Fourier Transform - audio to visual analysis
// VARIABLES FOR SOUND ANALYSIS
int bassAmp, kickboxSensitivity;
int snareAmp, snareSensitivity;
float noiseAmp;
// VARIABLES FOR GRAPHICS
// vars for draw - 'scene selector'
int selector, weightage;
// vars for kickbox
int topLx, topLy, topCx, topCy, topRx, topRy; // values for kickbox top row
int midLx, midLy, midCx, midCy, midRx, midRy; // values for kickbox mid row
int botLx, botLy, botCx, botCy, botRx, botRy; // values for kickbox bot row
// vars for 3D square field
int driftX;
float randomRotateAmt;
// vars for circle scene
int circlepop;
int circleLoc;
// vars for spiral
float arcLength;
// vars for colored squares scene (UNUSED SCENE)
float xoffset = 0.0;
float yrise = 0.0;
int col;
color[] colorarray;

void setup() {
  //size(1920, 1080, P3D); //use windowed mode if fullscreen is buggy
  //frame.setLocation(1280,0); //for monitor select
  fullScreen(P3D);
  frameRate(60);
  background(0);
  noCursor();
  // allow the loading of files in data directory
  minim = new Minim(this);
  // load the audio track in data directory into the AudioPlayer 'player'
  player = minim.loadFile("song.mp3", 1024); //ensure song.mp3 is in data folder
  // FFT object with time domain buffer
  fft = new FFT(player.bufferSize(), player.sampleRate());
  // setup for scene selector
  selector = 2; // the scene number to select on frame 1
  weightage = 1;
  // setup for kickbox scene
  kickboxSensitivity = 125;
  println("Kickbox Sensitivity is " + kickboxSensitivity);
  snareSensitivity = 5;
  println("Snare Sensitivity is " + snareSensitivity);
  //setup for squarefield scene
  driftX = 0;
  randomRotateAmt = random(1, 24);
  stroke(255);
  //setup for circle scene
  circlepop = 0;
  circleLoc = width/2;
  //setup for spiral
  arcLength = 0.0005;
  //(UNUSED SCENE) setup for squares bloom scene
  colorarray = new color[6];
  colorarray[0] = color(39, 255, 97);
  colorarray[1] = color(70, 255, 251);
  colorarray[2] = color(226, 255, 92);
  colorarray[3] = color(255, 122, 93);
  colorarray[4] = color(252, 104, 255);
  colorarray[5] = color(255, 174, 62);
}

void draw() {
  // sound analysis each frame
  fft.forward(player.mix); // initiate FFT on AudioPlayer 'player' for frequency analysis
  bassAmp = int(fft.getFreq(50)); // analyse amplitude of 50Hz
  snareAmp = int(fft.getFreq(1760)); // analyse amplitude of 1760Hz
  noiseAmp = map(fft.getFreq(19000), 0, 1, 0, 500); // analyse amplitude of 19kHz and remap
  // changing of variables according to sound analysis
  if (bassAmp>kickboxSensitivity && frameCount>300) {
    selector = floor(random(1, 5.57)); //randomizes value used in scene selection
    weightage = int(random(1, 50)); //randomizes value used in stroke thickness
  } else {
    if (snareAmp>snareSensitivity) {
      weightage = int(random(1, 65));
    }
  }
  // selection of scenes to be displayed on screen
  if (selector==1) {
    //squarefield(rectangle width, rectangle height, colorOFF=0/colorON=1)
    strokeWeight(weightage + noiseAmp/15);
    squarefield(20, 20, 1);
  }
  if (selector==2) {
    if (bassAmp>kickboxSensitivity/3 & frameCount>600) {
      strokeWeight(weightage + noiseAmp/15);
      squarefield(20, 20, 0);
    } else {
      circlepop();
      fxRain();
    }
  }
  if (selector==3) {
    //kickbox(margin, randomness amount, color scheme "warm" or "cool", base thickness)
    kickbox(50, bassAmp, "warm", 2);
    if (bassAmp>kickboxSensitivity) {
      selector = floor(random(1, 2.99)); //further scene selection in a scene
    }
  }
  if (selector==4) {
    kickbox(50, bassAmp, "cool", 1);
    if (bassAmp>kickboxSensitivity) {
      selector = floor(random(1, 2.99)); //further scene selection in a scene
    }
  }
  if (selector==5) {
    spiral();
  }
  // monitoring text (for development & fine-tuning)  
  if (mousePressed) {
    fill(255);
    textSize(12);
    text(kickboxSensitivity, width-40, 30);
    text(bassAmp, width-80, 30);
    text(snareSensitivity, width-120, 30);
    text(snareAmp, width-160, 30);
  }
  //silence = black
  if (noiseAmp < 1) {
    selector = 2;
  }
  
  //reloads data - if you replace song.mp3 while song is playing, new song plays after current song finishes
  if (player.isPlaying() == false) {
      selector = 2;
      player = minim.loadFile("song.mp3", 1024);
      player.rewind();
      player.play();
  }
  
}

void keyPressed() {
  // for player, spacebar is start song
  if (key == ' ') {
    if (player.isPlaying()) {
      player.pause();  
    } else {
      player.play();
    }
  }
  // for kickbox sensitivity, up is +10, left is -10 (THIS SETS THE THRESHOLD)
  if (key == CODED) {
    if (keyCode == UP) {
      kickboxSensitivity = kickboxSensitivity + 10;
      println("Kickbox Sensitivity is " + kickboxSensitivity);
    }
  }
  if (key == CODED) {
    if (keyCode == DOWN) {
      kickboxSensitivity = kickboxSensitivity - 10;
      println("Kickbox Sensitivity is " + kickboxSensitivity);
    }
  }
  // for snare sensitivity, right is +5, left is -5 (THIS SETS THE THRESHOLD)
  if (key == CODED) {
    if (keyCode == RIGHT) {
      snareSensitivity = snareSensitivity + 5;
      println("Snare Sensitivity is " + snareSensitivity);
    }
  }
  if (key == CODED) {
    if (keyCode == LEFT) {
      snareSensitivity = snareSensitivity - 5;
      println("Snare Sensitivity is " + snareSensitivity);
    }
  }
}

// GRAPHICS BELOW (SCENES)

// kickbox (graphic on beat)
void kickbox(int margin, int kickjerk, String colorMode, int thickness) {
  background(0);
  // top row
  topLx = margin+int(random(-kickjerk, kickjerk));
  topLy = margin+int(random(-kickjerk, kickjerk));
  topCx = width/2+int(random(-kickjerk, kickjerk));
  topCy = margin+int(random(-kickjerk, kickjerk));
  topRx = width-margin+int(random(-kickjerk, kickjerk));
  topRy = margin+int(random(-kickjerk, kickjerk));
  // mid row
  midLx = margin+int(random(-kickjerk, kickjerk));
  midLy = height/2+int(random(-kickjerk, kickjerk));
  midCx = width/2+int(random(-kickjerk, kickjerk));
  midCy = height/2+int(random(-kickjerk, kickjerk));
  midRx = width-margin+int(random(-kickjerk, kickjerk));
  midRy = height/2+int(random(-kickjerk, kickjerk));
  // bot row
  botLx = margin+int(random(-kickjerk, kickjerk));
  botLy = height-margin+int(random(-kickjerk, kickjerk));
  botCx = width/2+int(random(-kickjerk, kickjerk));
  botCy = height-margin+int(random(-kickjerk, kickjerk));
  botRx = width-margin+int(random(-kickjerk, kickjerk));
  botRy = height-margin+int(random(-kickjerk, kickjerk));
  // stroking
  if (colorMode == "cool") {
    if (bassAmp>kickboxSensitivity) {
      stroke(0, random(200, 255), random(150, 255), 230);
    } else { 
      noStroke();
    }
  }
  if (colorMode == "warm") {
    if (bassAmp>kickboxSensitivity) {
      stroke(random(180, 255), random(50, 75), random(30, 60), 230);
    } else { 
      noStroke();
    }
  }
  strokeWeight(random(thickness, thickness+10));
  // horizontal lines
  line(topLx, topLy, topCx, topCy);
  line(topCx, topCy, topRx, topRy);
  line(midLx, midLy, midCx, midCy);
  line(midCx, midCy, midRx, midRy);
  line(botLx, botLy, botCx, botCy);
  line(botCx, botCy, botRx, botRy);
  // vertical lines
  line(topLx, topLy, midLx, midLy);
  line(topCx, topCy, midCx, midCy);
  line(topRx, topRy, midRx, midRy);
  line(midLx, midLy, botLx, botLy);
  line(midCx, midCy, botCx, botCy);
  line(midRx, midRy, botRx, botRy);
}

// squarefield (3D space filled with rotated squares)
void squarefield(int rectWidth, int rectHeight, int colorON) {
  background(0);
  pushMatrix();
  driftX = driftX - 5;
  if (driftX<-width*3) {
    driftX = 0;
  }
  if (bassAmp>kickboxSensitivity) {
    randomRotateAmt = random(1, 24);
    if (colorON==1) {
      stroke(random(125, 255), random(125, 255), random(125, 255));
    }
    if (colorON==0) {
      stroke(255);
    }
  }
  translate(driftX, 0);
  for (int iX = 20; iX<width*12; iX=iX+40) {
    for (int iY = 20; iY<height; iY=iY+40) {
      noFill();
      rotateY(randomRotateAmt);
      rect(iX, iY, rectWidth, rectHeight);
    }
  }
  popMatrix();
}

// the circle scene with glitchy triangles
void circlepop() {
  if(circleLoc==width){
    circleLoc = 0;
  } else { circleLoc = circleLoc + 1; }
  pushMatrix();
  background(0);
  translate(circleLoc, height/2);
  fill(255);
  noStroke();
  ellipse(0, 0, noiseAmp, noiseAmp);
  ellipse(-width/2, 0, noiseAmp, noiseAmp);
  ellipse(width/2, 0, noiseAmp, noiseAmp);
  fill(0);
  ellipse(0, 0, noiseAmp/1.1, noiseAmp/1.1);
  ellipse(-width/2, 0, noiseAmp/1.1, noiseAmp/1.1);
  ellipse(width/2, 0, noiseAmp/1.1, noiseAmp/1.1);
  if (noiseAmp>500) {
    stroke(255);
    strokeWeight(1);
    noFill();
    triangle(random(-800, 800), random(-800, 800), random(-800, 800), random(-800, 800), random(-800, 800), random(-800, 800));
    triangle(random(-800, 800), random(-800, 800), random(-800, 800), random(-800, 800), random(-800, 800), random(-800, 800));
    triangle(random(-800, 800), random(-800, 800), random(-800, 800), random(-800, 800), random(-800, 800), random(-800, 800));
  }
  popMatrix();
}

// spiral
void spiral() {
  background(0);
  noFill();
  arcLength = arcLength + 0.0001;
  if (arcLength == 10) {
    arcLength = 0.0005;
  }
  stroke(255);
  translate(width/2, height/2);
  for (int r=50; r<650; r=r+5) {
    rotate(millis()/2000.0);
    strokeWeight(3);
    arc(0, 0, r*bassAmp/10, r*bassAmp/10, 0, arcLength);
  }
}

// (UNUSED) squares scene
void squarebloom(int basesize) {
  xoffset = xoffset + .01;
  yrise = yrise - 1;
  if (yrise<-(height+15)) {
    yrise=0;
    noStroke();
    fill(0, 0, 0, 200);
    rect(0, 0, width, height);
  }
  float n = noise(xoffset) * bassAmp*2;
  println(n);
  strokeWeight(1);
  col = color(colorarray[(int)random(0, 5)]);
  noFill();
  stroke(col);
  rect(width/2+5+n, height+15+yrise, basesize+bassAmp/10, basesize+bassAmp/10);
  stroke(col);
  rect(width/2-5-n, 0-15-yrise, basesize+bassAmp/10, basesize+bassAmp/10);
}

// bootleg rain effect
void fxRain() {
  fill(255);
  textSize(random(noiseAmp));
  text("l", random(width), random(height));
}

// grain effect
void fxGrain() {
  fill(255);
  textSize(random(noiseAmp));
  text(".", random(width), random(height));
  text(".", random(width), random(height));
}