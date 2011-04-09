/**
 * Based on GSVideo movie speed example.
 *
 * Thiago Alverenga Lechuga (thiagoalz@gmail.com)
 */

import codeanticode.gsvideo.*;

GSMovie myMovie;
PFont font;

//==============================================

//Set you moovies folder
String moviesFolder="/tmp/movies";

//==============================================

String[] feedssurl;
FeedReader feed;
FeedEntry entryList[];

int feedAtual=0;
int idNoticia=0;
float xFeed=width;
float Feedsize = 0;
float passoSegundo=500.0;
float passoQuadro=0;

String[] movieList;
int movieAtual=0;

String newline = System.getProperty("line.separator");


public void setup() {
  size(screenWidth+10, screenHeight+10);
  background(0);
  
  movieList=getMoviesList();
  loadNextMovie();
  
  
  font = loadFont("DejaVuSans-24.vlw");
  textFont(font, 24);
  
  
  ////////////////RSS//////////////////
  
  feedssurl= loadStrings("feeds.config");

  feed=loadNextFeed();
}

public void movieEvent(GSMovie myMovie) {  
  myMovie.read();
  
  //Used to make Feeds scrool at same speed even with movies with diferent Framerate
  passoQuadro=passoSegundo/myMovie.getSourceFrameRate();  
}

public void draw() {
  background(0);
  if (1 < myMovie.width && 1 < myMovie.height) {
    try{
      imageMode(CENTER);
      image(myMovie, width/2, height/2);
    }catch(Exception e){//Rack para arrumar erro estranho
      println("Rack de erro");
      e.printStackTrace(); 
    }
  }

  if(! myMovie.isPlaying()){
    loadNextMovie();
  }

  
  //Imprime o Texto
  if(feed.entry!=null){//Se conseguiu Carregar Algo;
    
    FeedEntry noticiaAtual = feed.entry[idNoticia];
    String texto=noticiaAtual.getTitle();//+newline+noticiaAtual.getDescription();
    Feedsize=textWidth(texto);//textWidth(noticiaAtual.getDescription());
    
    xFeed = xFeed - passoQuadro; //Incrementa posicao do texto na tela
    if (xFeed < 0 - Feedsize) {//Se chegou ao final
      xFeed = width;//Volta para o texto para o comeco
      idNoticia++; //Muda para o proximo item do feed atual
      if(idNoticia >= feed.numEntries || idNoticia>=9){ //Se ja mostrou todos
        feed=loadNextFeed();//Recarrega o feed
      }
    }
    translate(xFeed, 40);    
    fill(255);
    text(texto, 0, height-80);
    
  }else{
    feed=loadNextFeed();
  }
}

public String[] getMoviesList(){
   
  // we'll have a look in the data folder
  java.io.File folder = new java.io.File(moviesFolder);
   
  // list the files in the data folder
  String[] filenames = folder.list();
   
  // display the filenames
  println("Lista de Videos");
  for (int i = 0; i < filenames.length; i++) {
    println(filenames[i]);
  }
  
  return filenames;
}

void loadNextMovie(){
  if(myMovie!=null){
   myMovie.delete(); 
  }
  println("Carregando Filme:"+moviesFolder+"/"+movieList[movieAtual]);
  myMovie = new GSMovie(this, moviesFolder+"/"+movieList[movieAtual]);
  myMovie.play();
  
  
  //movieAtual=(movieAtual+1) % movieList.length; //Lista circular
  movieAtual=floor(random(0, (movieList.length) )); //Random order
}


public FeedReader loadNextFeed(){
 
  // load feed
  println("Loading feed: "+feedssurl[feedAtual]);
  FeedReader nextFeed=new FeedReader(feedssurl[feedAtual]);
  feedAtual= (feedAtual +1)%feedssurl.length ;
  idNoticia=0;
  
  // print feed data
  println("Feed: "+nextFeed.title);
  println("------------------------------");
  println("Description: "+nextFeed.description);
  println("\nNumber of entries: "+nextFeed.numEntries);
  println("------------------------------"); 
  
  return nextFeed;
  
}

