/**
 * Based on GSVideo movie speed example.
 *
 * Thiago Alverenga Lechuga (thiagoalz@gmail.com)
 */

import codeanticode.gsvideo.*;
import processing.opengl.*;

PImage logo1;
PImage logo2;

GSMovie myMovie;
PFont font;

//==============================================
//Set your data folder
String dataFolder="path/to/data/folder";
String moviesFolder=dataFolder+"/videos";

//Set Max itens by feed
int maxItens=10;
//==============================================

float passoSegundo=100.0;
float passoQuadro=0;

String[] feedssurl;
FeedReader feed;
FeedEntry entryList[];

int feedAtual=-1;
int idNoticia=0;
float xFeed=width;
float Feedsize = 0;


String promoList[];

int idPromo=0;
float xPromo=width;
float promoSize = 0;


String[] movieList;
int movieAtual=-1;

//String newline = System.getProperty("line.separator");

public void setup() {
  logo1 = loadImage("logo_invert.png");
  logo2 = loadImage("4.png");
  
  
  size(1280, 720, OPENGL);
  background(0);
  
  movieList=getMoviesList();
  loadNextMovie();
  
  
  font = loadFont("DejaVuSans-48.vlw");
  textFont(font, 24);
  
  ////////////////RSS//////////////////
  
  feedssurl= loadStrings(dataFolder+"feeds.config");

  loadNextFeed();
  
  //////////////Promo////////////////
  promoList= loadStrings(dataFolder+"promos.config");
}

public void movieEvent(GSMovie myMovie) {  
  myMovie.read();
}

public void draw() {
  //Used to make Feeds scrool at same speed even with movies with diferent Framerate
  passoQuadro=passoSegundo/frameRate;


  background(0);

  printStrips();
  
  printImages();
  
  
  //Printing movie
  if (1 < myMovie.width && 1 < myMovie.height) {
    try{
      imageMode(CENTER);
      image(myMovie, width/2, height/2);
    }catch(Exception e){//Rack to fix a strange error
      println("Rack de erro");
      e.printStackTrace(); 
    }
  }

  if(! myMovie.isPlaying()){
    loadNextMovie();
  } 
  
  printFeed();
  
  printPromo();
  
}



//////////Print methods//////////

void printStrips(){
   
   pushMatrix();
   translate(0, 0, -10);
   //Desenhando faixas sob os textos 
   noStroke();//Remove bordas
   
   fill(0, 200, 200);
   rect(-10, height-96, width+20,height*0.05);
  
   fill(0, 100, 100);
   rect(-10, height-60, width+20,height*0.05);
   popMatrix();
}

void printImages(){
  
  int b_larg=logo2.width/3;
  int b_alt=logo2.height/3;
  
  image(logo1, width/2, 55);
  image(logo2, 65, height-63, b_larg, b_alt);
  
}

void printFeed(){
  
  // cria o formatador  
  SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");  

  
  //Add Text to screen
  if(feed.entry!=null){//If the feed was loaded
    
    FeedEntry noticiaAtual = feed.entry[idNoticia];
    
    String data= noticiaAtual.getDate()!=null ? formatador.format(noticiaAtual.getDate()) : "";
    String texto="["+feed.title+"] "+noticiaAtual.getTitle()+". "+data;//+newline+noticiaAtual.getDescription();
    Feedsize=textWidth(texto);
    
    xFeed = xFeed - passoQuadro; //Incrementa posicao do texto na tela
    if (xFeed < 0 - Feedsize) {//Se chegou ao final
      xFeed = width;//Volta para o texto para o comeco
      idNoticia++; //Muda para o proximo item do feed atual
      if(idNoticia >= feed.numEntries || idNoticia>=(maxItens-1) ){ //Se ja mostrou todos, ou chegou no limite
        loadNextFeed();//Load next feed
      }
    }
     
     
    pushMatrix();
    fill(255);
    translate(xFeed, 0,-1);    
    text(texto, 0, height-35);
    popMatrix();
    
  }else{
    loadNextFeed();
  }
  
}


void printPromo(){
  
  //Add Text to screen
  if(promoList!=null){//If the promo was loaded
    
    String texto=promoList[idPromo];
    promoSize=textWidth(texto);
    
    xPromo = xPromo - (passoQuadro/2); //Incrementa posicao do texto na tela
    if (xPromo < 0 - promoSize) {//Se chegou ao final
      xPromo = width;//Volta para o texto para o comeco
      idPromo=(idPromo+1) % promoList.length; //Muda para o proximo item da promo atual
    }
     
     
    pushMatrix();
    fill(255);
    translate(xPromo,0,-1);
    text(texto, 0, height-68);
    popMatrix();
    
  }
}

//////////Auxiliar methods//////////

String[] getMoviesList(){
   
  // Load movies folder
  println(moviesFolder);
  java.io.File folder = new java.io.File(moviesFolder);
   
  // list the files in it
  String[] filenames = folder.list();
   
  // display filenames
  println("Video List");
  for (int i = 0; i < filenames.length; i++) {
    println("["+i+"]"+filenames[i]);
  }
  
  return filenames;
}


void loadNextMovie(){
  if(myMovie!=null){
   myMovie.delete(); 
  }
  
  //movieAtual=(movieAtual+1) % movieList.length; //Circular list
  movieAtual=floor(random(0, (movieList.length) )); //Random order
  println("Atual= "+movieAtual);
  
  println("Loading Movie:"+moviesFolder+"/"+movieList[movieAtual]);
  myMovie = new GSMovie(this, moviesFolder+"/"+movieList[movieAtual]);
  myMovie.play();
}


void loadNextFeed(){
  
  //feedAtual= (feedAtual +1)%feedssurl.length; //Circular list
  feedAtual= floor(random(0, (feedssurl.length) )); //Random order
 
  // load feed
  println("Loading feed: "+feedssurl[feedAtual]);
  feed=new FeedReader(feedssurl[feedAtual]);
  
  idNoticia=0;
  
  // print feed data
  println("Feed: "+feed.title);
  println("------------------------------");
  println("Description: "+feed.description);
  println("\nNumber of entries: "+feed.numEntries);
  println("\nWill display: "+maxItens);
  println("------------------------------"); 
  
}
