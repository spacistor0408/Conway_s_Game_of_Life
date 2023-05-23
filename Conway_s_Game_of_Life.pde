import de.voidplus.leapmotion.*;

LeapMotion leap ;
PImage img ;
float aspectRatio ; // proportion

// set up the board
int size = 8 ;

int cols = 2560/size ;
int rows = 1440/size ;
int imgScaleSize = 2 ;
int[][] board = new int[cols][rows] ;
int[][] board_whiteblue = new int[cols][rows] ;
int[][] board_lightOrange = new int[cols][rows] ;

int[][] img_board = new int[cols][rows] ;

// setting pixel color
int color_BG = 45 ;
int R_BG = 45 ;
int G_BG = 45 ;
int B_BG = 45 ;


// set up initial status
void initRandomBoard() { 
  for (int y=0 ; y<rows ; y++) {
    for (int x=0 ; x<cols ; x++) {
      board[x][y] = int(random(2)) ;
      board_whiteblue[x][y] = int(random(2)) ;
      board_lightOrange[x][y] = int(random(2)) ;
    }
  }
} // initBoard()

void AddImageInTheBoard() {
  for ( int y=0 ; y < img.height ; y+= size ) {
    for ( int x=0 ; x < img.width ; x+= size ) {
      
      // skip the transparent pixel 
      float pixelAlphaValue = alpha( img.get(x, y) ) ;
      if ( pixelAlphaValue != 0 ) {
        fill(255) ;
        noStroke() ;
        rect( x, y, size, size ) ;
      } // if
    } // for
  } // for
} // AddImageInTheBoard()

void InitialImageBoard() {
  
  // set position to the middle
  int offset_y = (int)(((height/2)-(img.height/2))/size) ;
  int offset_x = (int)(((width/2)-(img.width/2))/size) ;
  
  for ( int y=0, h=0+offset_y ; y < img.height ; y+= size, h++ ) {
    for ( int x=0, w=0+offset_x ; x < img.width ; x+= size, w++ ) {
      
      img_board[w][h] = 0 ;
      float pixelAlphaValue = alpha( img.get(x, y) ) ;
      
      if ( pixelAlphaValue != 0 ) {
        img_board[w][h] = 1 ;
      } // if
    } // for
  } // for
} // InitialImageBoard()

void LoadImage() {
  img = loadImage("img/Doingood_logomark.png") ;
  // calculate aspect ratio
  aspectRatio = (float) img.width / img.height ;
  
  int newWidth ;
  int newHeight ;
  
  // Keep the proportion and resize to avoid image out of the window
  if ( height < width ) {
    newHeight = min(height, img.height) ;
    newWidth = (int) (newHeight * aspectRatio) ;
  }
  else {
    newWidth = min(width, img.width) ;
    newHeight = (int) (newWidth / aspectRatio) ;
  }

  img.resize( newWidth/imgScaleSize, newHeight/imgScaleSize ) ;
} // LoadImageAndSetUpSuitableSize()

void drawImage() {
  image( img, 0, 0 ) ;
} // drawImage()

// set up the screen
void setup() {
  fullScreen() ;
  //size(1920, 1080) ;
  
  frameRate(24) ;
  leap = new LeapMotion(this) ;
  initRandomBoard() ;
  LoadImage() ;
  InitialImageBoard() ;
} // setup()

// drawing the screen
void draw() {
  background(20) ;
  
  // compute the next
  int[][] next = new int[cols][rows] ;
  int[][] next2 = new int[cols][rows] ;
  int[][] next3 = new int[cols][rows] ;
  
  // calculate each boards color
  for ( int y=1 ; y<rows-1 ; y++ ) {
    for ( int x=1 ; x<cols-1 ; x++ ) {
      // First board pixel num
      int neighbours = countNeighbours(x, y) ;
      next[x][y] = ruleOfLife( board[x][y], neighbours ) ;
      
      // second board pixel num
      int neighbours2 = countNeighbours_board_whiteblue(x, y) ;
      next2[x][y] = ruleOfLife( board_whiteblue[x][y], neighbours2 ) ;
      
      // third board pixel num
      int neighbours3 = countNeighbours_board_lightOrange(x, y) ;
      next3[x][y] = ruleOfLife( board_lightOrange[x][y], neighbours3 ) ;
      
      // random generate next status
      if ( img_board[x][y] == 1 ) {
        next[x][y] = prob() ;
        next2[x][y] = prob() ;
        next3[x][y] = prob() ;
      } // if
    } // for
  } // for
  
  board = next ;
  board_whiteblue = next2 ;
  board_lightOrange = next3 ;
  LeapFingerControl() ;
  
  
  drawBoard() ;
  //AddImageInTheBoard() ;
  //drawImage() ;
} // draw()

void LeapFingerControl() {
  for ( Hand hand : leap.getHands() ) {
    for ( Finger finger : hand.getFingers() ) {
      PVector fingerPos = finger.getPosition() ;
      int fingerX = parseInt(fingerPos.x) / size ;
      int fingerY = parseInt(fingerPos.y) / size ;
      if ( fingerX-2 > 0 && fingerX+2 < cols && fingerY-2 > 0 && fingerY+2 < rows ) {
        for ( int i=-2 ; i<=2 ; i++ ) {
          for ( int j=-2 ; j<=2 ; j++ ) {
            board[fingerX+j][fingerY+i] = 1 ;
            board_whiteblue[fingerX+j][fingerY+i] = 1 ;
            board_lightOrange[fingerX+j][fingerY+i] = 1 ;
          } // for
        } // for
      } // if
    } // for
  } // Find finger
} // LeapFingerControl()

void keyPressed() {
  if ( key == 's' || key == 'S' ) {
    save("visual.png") ;
  }
}

/* ----------CALCULATING NEIGHBOURS---------- */

// count the number of neighbours
int countNeighbours( int x, int y ) {
  int neighbours = 0 ;
  for ( int i=-1 ; i<=1 ; i++ ) {
    for ( int j=-1 ; j<=1 ; j++ ) {
      neighbours += board[x+j][y+i] ;
    }
  }
  neighbours -= board[x][y] ;
  return(neighbours) ;
} // countNeighbours

// count the number of neighbours
int countNeighbours_board_whiteblue( int x, int y ) {
  int neighbours = 0 ;
  for ( int i=-1 ; i<=1 ; i++ ) {
    for ( int j=-1 ; j<=1 ; j++ ) {
      neighbours += board_whiteblue[x+j][y+i] ;
    }
  }
  neighbours -= board_whiteblue[x][y] ;
  return(neighbours) ;
} // countNeighbours

int countNeighbours_board_lightOrange( int x, int y ) {
  int neighbours = 0 ;
  for ( int i=-1 ; i<=1 ; i++ ) {
    for ( int j=-1 ; j<=1 ; j++ ) {
      neighbours += board_lightOrange[x+j][y+i] ;
    }
  }
  neighbours -= board_lightOrange[x][y] ;
  return(neighbours) ;
} // countNeighbours


/* ----------RULL OF LIFE---------- */

// apply the rules of life
int ruleOfLife( int status, int neighbours ) {
  if ( status >= 1 && neighbours > 3 ) return 0 ; // overpopulation
  else if ( status >= 1 && neighbours < 2 ) return 0 ; // underpopulation
  else if ( status == 0 && neighbours == 3 ) return 1 ; // reproduction
  else return status ;
} // ruleOfLife()

/* ----------PROBILITY FUNCTION---------- */

int prob() {
  float randNum = random(1) ;
  if (randNum > 0.7 ) {
    return 0 ;
  } // if
  else {
    return 1 ;
  } // else
} // prob

int SizeProb() {
  if (random(1) > 0.7 ) {
    return 0 ;
  } // if
  else {
    return 1 ;
  } // else
  
} // SizeProb

/* ----------DRAWING---------- */

// draw the board on the screen
void drawBoard() {
  for ( int y=0 ; y<rows ; y++ ) {
    for ( int x=0 ; x<cols ; x++ ) {
      
       int prob = prob() ;
      
      // fill color
      if ( board[x][y] == 1 ) {
        if ( prob == 1 ) fill(#EFEFEF) ;
        else fill ( #D3DEF1 ) ; // 69, 181, 255
      } // if
      
      // fill color in board_lightOrange
      else if ( board_lightOrange[x][y] == 1 ) fill( #F6AE54 ) ;
      
      // fill color in board_whiteblue
      else if ( board_whiteblue[x][y] == 1 ) fill( #D3DEF1 ) ;
      
      // background color
      else {
        fill(#EE782B) ;
      } // else
      
      
      // draw rectangle
      if ( SizeProb() == 1 ) {
        noStroke() ;
        rect( x*size, y*size, size, size ) ;
      } // if
      else {
        strokeWeight(random(1, 3)) ;
        stroke( color(#EE782B) ) ;
        rect( x*size, y*size, size, size ) ;
      } // else
      
    } // for
  } // for
} // drawBoard()
