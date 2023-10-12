// Libraries minim pour le traitement du son

import ddf.minim.*;

import ddf.minim.analysis.*; // FFT



Minim minim; // Objet qui va gérer le traitement du son

AudioPlayer player; // Permet de jouer la musique

FFT fft; //Fast fourir transform, analyse la fréquence de l'audio



float starsSpeed = 0.03; //La vitesse des étoiles



float colorRatio = 0.5; // Pour le controle du gradient avec la souris



// Pour servir de base au soleil et à son animation

int movingCircleLinesOffset = 20; // Décalage vertical 

float movingCircleLinesSpeed = 1; // Vitesse de déplacement des lignes

SynthwaveSun sun;



// Tours

int numTowers = 17;

Tower[] towers = new Tower[numTowers];



// La route

int numLines = 13; // Nombre de lignes horizontales

float[] yPos = new float[numLines]; // Y-coordonnée de chaque ligne

float[] yPosOffsets = new float[numLines]; // Décalage vertical de chaque ligne



// Coordonnées utilisées pour l'origine de la trajectoire de la pyramide

// et pour le calcul de sa trajectoire

PVector pvPyramid = new PVector(250, 400, 20);

PVector pvPyramidOrigin = new PVector(250, 400, 20);

// Constante pour controler la taille de la pyramide

int k = 2;



//-------------------------------- FONCTIONS --------------------------------



//------------------------------------ 2D -----------------------------------



// Fonction exponentielle qui calcule la distance entre la position de départ 

// et la position finale (offset) de chaque ligne en fonction de son indice

float exponentialFunction(float x) {

  float a = 25;

  float b = 1.263; //parametrable, augmente la vitesse

  return a * pow(b, x);

}



// Initialise les positions initiales de chaque ligne en fonction de son indice

// grâce à la fonction exponentielle.

// Remplit la table avec les offsets de chaque ligne

void initializeYPositions() {

  for (int i = 0; i < numLines; i++) {

    yPosOffsets[i] = exponentialFunction(i + 1); // Décalage vertical 

    yPos[i] = height / 2 + yPosOffsets[i]; // Position initiale

  }

}





// Lignes avec un effet de lueur, on redessigne la même ligne 3 fois

// Une est plus fine que l'autre. Leur transparence donne l'effet de lueur

void glowyLine(float x1, float y1, float x2, float y2){

    strokeWeight(7);

    stroke(255, 30);

    line(x1, y1, x2, y2);

    strokeWeight(5);

    stroke(255, 50);

    line(x1, y1, x2, y2);

    strokeWeight(2);

    stroke(255);

    line(x1, y1, x2, y2);

}



// Effet de lueur sur la route et autour du soleil, controlée par le scroll de la souris.

// L'effet est produit par la superposition d'une forme transparente qui se 

// diminue/augmente en taille.

void glow(){

  pushMatrix(); // Pour ne pas intervenir dans l'espace 3D

  noStroke();



  for (int i = 0; i <= 30; i++){ // i est parametrable 

    fill(50/colorRatio, 100, 200, 1+i*0.04); //couleur parametrable paar le scroll

    beginShape(); // lueur sur la route

    vertex((width/2 - 150) + i*5, height/2 + 35); // top left

    vertex(-900 + i*20, height); // bottom left

    vertex(width + 900 - i*20, height); // bottom right

    vertex((width/2 + 150) - i*5, height/2 + 35); // top right

    endShape();



    arc(width/2, height/2, 600 + i*5, 600 + i*5, PI, PI*2); // arc autour du soleil

  }

  popMatrix();

}



// Dessine les lignes verticales à partir d'un point de depart commun

void verticalLines(){

  for (int x = -4000; x <= width + 4000; x += 200) {

    float startX = width/2;

    float startY = height/2; //coordonnées pt de départ

    float endX = x; // coordonnée de la fin de la ligne

    glowyLine(startX, startY, endX, height); // dessine la ligne

  }

}





// Dessine les lignes horizontales en motion (màl les positions continuellement).

// Le facteur de vitesse permet de donner un movement plus graduel,

// si on diminue la valeur, la vitesse augmente.

// L'echange cyclique dans yPosOffsets est fait pour maintenir le movement continu des lignes.

// Quand une ligne atteint le bas de l'écran, on remet son offset à celui de la 

// prémière ligne, comme ça elle reapparaitra dans la position de départ.

void horizontalLines(){



  for (int i = 0; i < numLines; i++) { // pour chaque ligne

    // on incrimente la position verticale

    yPos[i] += yPosOffsets[i] / 15; // ici 15 est le facteur de vitesse

    float y = yPos[i]; // coordonée utilisé pour afficher la ligne



    if (yPos[i] >= height) { // si la ligne a franchi le bas d'écran

      yPos[i] = height / 2; //on remet sa position au point de départ

      float temp = yPosOffsets[0];

      for (int j = 0; j < numLines - 1; j++) { // on decale les offsets d'une position

        yPosOffsets[j] = yPosOffsets[j + 1]; 

      }

      yPosOffsets[numLines - 1] = temp; //on remet le premier offset à la fin

    }

    glowyLine(0, y, width, y); // dessine la ligne

  }

}



// Dessine les étoiles

void nightStars() {

  pushMatrix();

  translate(0, 0, -500);

  stroke(255);

  

  // Genérer les étoiles 

  for (int i = 0; i < max(height, width)/4; i++) {

    float x = map(noise(i, frameCount * starsSpeed), 0, 1, 0, width);

    float y = map(noise(i, frameCount * starsSpeed + 1000), 0, 1, 0, height);

    float z = map(noise(i, frameCount * starsSpeed + 2000), 0, 1, 0, max(height, width)*2);

    float size = random(1, 5);

    strokeWeight(size);

    point(x, y, z);

  }

  popMatrix();

}





// Regroupe toutes les fonctions pour la partie 2D

void draw2d(){



  // Permet une manipulation coherente des fonctionnalités 2D dans un espace 3D

  hint(DISABLE_DEPTH_TEST);

  noStroke();

  nightStars();

  sun.display();

  

  // On initialise les couleurs pour un premier affichage

  sun.setColors(lerpColor(color(255, 0, 255), color(0, 0, 255), colorRatio),

                lerpColor(color(255, 255, 0), color(0, 255, 0), colorRatio));

  

  // La Route qui donne l'illusion de profondeur

  verticalLines();

  horizontalLines();

}





//------------------------------------ 3D -----------------------------------



// Une figure géométrique en 3D qui sert de décor et qui approche au fil

// de l'avancement du terrain

void incomingShape() {

  PVector p = pvPyramid;

  PVector pt = pvPyramidOrigin;



  // Translation permettant de déplacer la pyramide sur une trajectoire 

  translate(p.x, p.y, p.z);

  drawPyramid(k*10, pt);
  drawPyramid(k*10, pt);
  drawPyramid(k*10, pt);

  // Calcul de la prochaine position pour la trajectoire actuelle

  p.x -= 8;

  p.y += 5;

  p.z += 8;



  // Si on arrive au plus proche de l'écran on réinitialise

  // pour recommencer à l'origine définie

  if (p.z > 500) {

    p.x = 250;

    p.y = 400;

    p.z = 20;

  }

}





// Le dessin de la route produit des bouts de lignes indésirables

// Cette méthode permet ainsi de cacher l'origine de ces lignes verticales

void hideUnwantedLines(){

  pushMatrix();

  translate(width/2, height/2, -300);

  

  // Box s'étalant sur l'horizontal et avec une épaisseur permettant de cacher

  // les fameuses lignes indésirables

  fill(0);

  noStroke();

  box(width*2, 90, -200);

  popMatrix();

}



/*

* Il s'agit d'une représentation d'une tour grâce à box(),

* Cette classe regroupe des méthodes utilisées pour représenter ce qui est visualisé

* grâce au fichier son fourni. baseY car 

*/

class Tower {

  float x, baseY, w, h;

  color c;



  Tower(float x, float baseY) {

    this.x = x;

    this.baseY = baseY;

    this.w = width / numTowers;

    this.h = 0;

  }



  // Vu qu'il s'agit de Tour avec une base, on définit par la motié sa hauteur

  // En effet, l'origine de box() est située au centre, en divisant il y a meilleure 

  // visualition quand on veut utiliser cette méthode

  void setHeight(float h) {

    this.h = h/2;

  }

  

  void setColor(color c) {

    this.c = c;

  }



  // Affichage de la tour sous différente couleur suivant la position et la potentielle

  // utilisation du scroll de la souris

  void display() {

    stroke(0);

    colorRatio = constrain(colorRatio, 0, 1); //limite la valeur ente 0 et 1



    // Calcul du dégradé de couleur

    for (int i = 0; i < numTowers; i++) {

      color c = lerpColor(lerpColor(color(255, 0, 255), color(0, 0, 255), colorRatio),

                          lerpColor(color(255, 255, 0), color(0, 255, 0), colorRatio),

                          map(i, 0, numTowers - 1, 0, 1));



      towers[i].setColor(c);

    }

    fill(c);



    // Dessin de la tour

    pushMatrix();

    translate(x + w/2, baseY - h/2);

    box(w, h, w);

    popMatrix();

  }

}



/*

* SynthwaveSun représente un soleil avec un dégradé entre deux couleurs

* Il inclut une animation pour lui donner un style orienté synthwave

*/

class SynthwaveSun {

  float centerX, centerY, diameter, linesSpeed;



  // Couleurs choisies pour le dégradé

  color colorA; //= color(255, 0, 255);

  color colorB; //= color(255, 255, 0);





  // Coordonnées du point le plus haut à gauche du carré

  float xStart;

  float yStart;



  // Le soleil "cercle" s'agit d'un carré avec des coins arrondis

  public SynthwaveSun(float cX, float cY, float diam) {

    this.centerX = cX;

    this.centerY = cY;

    this.diameter = diam;

    this.linesSpeed = 1;



    this.colorA = color(255, 0, 255); // Par défaut

    this.colorB = color(255, 255, 0);

    this.xStart = centerX - diameter/2;

    this.yStart = centerY - diameter/2;

  }



  void setSpeed(float speed) {

    if (speed >= 0) {

      this.linesSpeed = speed;

    }

  }



  void setColors(color a, color b) {

    this.colorA = a;

    this.colorB = b;

  }



  // Dégradé de couleur sur l'horizontal

  void colorFill() {



    for (int y = 0; y < diameter; y++) {

      for (int x = 0; x < diameter; x++) {



        // Choix de couleur actuelle à une position des ordonnées

        float colorLerp = map(y, 0, diameter, 0, 1);

        color currentColor = lerpColor(this.colorB, this.colorA, colorLerp);



        fill(currentColor);

        rect(x + xStart, y + yStart, 1, 1);

      }

    }

  }



  // Contraintes: il faut Loop et une remise à zéro du background

  // Sinon, les lignes reste sur les canvas des prochains draw()

  void movingLines() {



    color lineColor = color(0);

    // Epaisseur entre chaque ligne

    int thickness = (int)(diameter/12.0);



    for (int y = (int)yStart; y < (int)(yStart + diameter); y += thickness) {

      stroke(lineColor);



      // Poids du tracé qui change en fonction de des ordonnées et de l'épaisseur

      // Pour donner cet effet de rétrécissement

      strokeWeight(y/(thickness*2));



      // Les lignes recouvrent le carré sur sa toute sa surface

      // Elles sont positionné avec un décalage

      line(xStart, y + movingCircleLinesOffset, xStart + diameter, y + movingCircleLinesOffset);

    }



    // Le décalage est remis à zéro au moment de l'arrivée au sommet

    // Il ne s'agit pas de lignes générées à l'infini, les bordures

    // couverts permettent de mettre cet effet d'infini en avant

    movingCircleLinesOffset -= linesSpeed;

    if (movingCircleLinesOffset < 0) {

      movingCircleLinesOffset = 20;

    }

  }



  // On recouvre les angles du carré de sorte à avoir un cercle

  // Le cercle dessiné n'est pas rempli mais il a une grosse bordure

  void hideAngles() {

    noFill();

    stroke(0);

    strokeWeight(diameter/1.99);//Pas 2 car il y a un très petit bout qui dépasse

    ellipse(centerX, centerY, diameter*1.5, diameter*1.5);

  }

  



  void display() {

    noStroke();

    colorFill();

    movingLines();

    hideAngles();

  }

}



// Dessine une pyramide en 3D avec une taille et une origine

void drawPyramid(float size, PVector p) {

  float halfSize = size / 2;

  

  pushMatrix();

  

  // Translation pour permettre de placer la pyramide sur une nouvelle origine

  translate(-p.x, -p.y, p.z);

  

  beginShape(TRIANGLES);

  fill(255, 0, 0); // Face rouge

  vertex(-halfSize, halfSize, -halfSize);

  vertex(halfSize, halfSize, -halfSize);

  vertex(0, -halfSize, 0);



  fill(0, 255, 0); // Face verte

  vertex(halfSize, halfSize, -halfSize);

  vertex(halfSize, halfSize, halfSize);

  vertex(0, -halfSize, 0);



  fill(0, 0, 255); // Face bleue

  vertex(halfSize, halfSize, halfSize);

  vertex(-halfSize, halfSize, halfSize);

  vertex(0, -halfSize, 0);



  fill(255, 255, 0); // Face jaune

  vertex(-halfSize, halfSize, halfSize);

  vertex(-halfSize, halfSize, -halfSize);

  vertex(0, -halfSize, 0);

  endShape();

  popMatrix();

}



// Regroupe les fonctions de la partie 3D

void draw3d(){

  // Annulation de l'effet précédent concernant les 2D pour pouvoir manipuler

  // d'une manière correcte les formes 3D de notre espace

  hint(ENABLE_DEPTH_TEST);

  

  glow(); //n'est pas 3D mais n'interagit pas correctement dans la partie 2D

  hideUnwantedLines();

  

  // Analyse de la bande son récupérée dans le fichier audio

  fft.forward(player.mix);

  

  // Calculs fait de manière à avoir des tours qui seront entre la partie 

  // gauche de la fenêtre et la gauche du soleil, et de même pour la partie 

  // droite afin de laisser un espace vide au niveau du soleil

  float sunLeft = sun.centerX - (sun.diameter / 2);

  float sunRight = sun.centerX + (sun.diameter / 2);

  int minTowerIndex = int(sunLeft / (width / numTowers));

  int maxTowerIndex = int(sunRight / (width / numTowers));



  for (int i = 0; i < numTowers; i++) {  

    // Si on est au niveau du soleil on saute le dessin de tour

    if (i >= minTowerIndex && i <= maxTowerIndex) {

      continue;

    }

    

    // Récupération de la fréquence après analyse

    float freqHeight = fft.getBand(i) * 20;

    

    // Condition pour limiter les hauteurs des tours qui peuvent être trop grandes

    if(freqHeight > height/2){

      towers[i].setHeight(freqHeight/5);

    }else{

      towers[i].setHeight(freqHeight); // on set la hauteur du tour

    }



    pushMatrix(); // pour assurer un bon comportement dans l'ensemble de l'image

    towers[i].display(); // affichage du tour

    popMatrix();    

  }

  

  // Partie de dessin d'une forme 3D qui sert de décor

  // La boucle est utilisée pour disperser les formes sur la bande

  // horizontale vide au niveau du soleil



    incomingShape();

}



//----------------------------------- Interaction --------------------------------------



// Changement de couleurs grâce au scroll de la souris

void mouseWheel(MouseEvent event) {

 float e = event.getCount();

  colorRatio += e * 0.05;

  colorRatio = constrain(colorRatio, 0, 1);



  for (int i = 0; i < numTowers; i++) {

    color c = lerpColor(lerpColor(color(255, 0, 255), color(0, 0, 255), colorRatio), lerpColor(color(255, 255, 0), color(0, 255, 0), colorRatio), map(i, 0, numTowers - 1, 0, 1));

    towers[i].setColor(c);

  }

}



///////////////////////////////////////////////////////////////////////////////////////////



void setup() {



  size(800, 800, P3D);

  background(0);

  frameRate(8);

  perspective(PI / 3.0, width / float(height), 10, 10000);



  sun = new SynthwaveSun(width/2, height/2, 300);

  initializeYPositions(); //initialisation de positions des lignes horizontales

  for (int i = 0; i < numTowers; i++) { //initialisation de tours

    towers[i] = new Tower(i * width / numTowers, height / 2 + 30);

  }



  // Récupération du fichier audio

  minim = new Minim(this);

  player = minim.loadFile("vocal-fry-cofeeshop-Shervin_Safineh.mp3");

  fft = new FFT(player.bufferSize(), player.sampleRate());

  player.loop();

}



void draw() {

  background(0);

  draw2d();

  draw3d();

 

  if(k > 60) // La pyramide augmente de taille jusqu'au moment de sa disparition de l'écran

    k = 2;

  k++;

}
