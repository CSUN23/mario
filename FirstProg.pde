final static float MOVE_SPEED = 5;
final static float SPRITE_SCALE = 50.0/128;
final static float SPRITE_SIZE = 50;
final static float GRAVITY = 0.6;
final static float JUMP_SPEED = 14;

final static float RIGHT_MARGIN = 400;
final static float LEFT_MARGIN = 60;
final static float VERTICAL_MARGIN = 40;

final static int NEUTRAL_FACING = 0;
final static int RIGHT_FACING = 1;
final static int LEFT_FACING = 2;

final static float WIDTH = SPRITE_SIZE * 16;
final static float HEIGHT = SPRITE_SIZE * 12; 
final static float GROUND_LEVEL = HEIGHT - SPRITE_SIZE; 

//declare global variables
Player player;
PImage snow, red_brick, crate, brown_brick, gold, spider, p;
ArrayList<Sprite> platforms;
ArrayList<Sprite> coins;
Enemy enemy;

//int numCoins;
float view_x = 0;
float view_y = 0;

boolean isGameOver;
boolean finishedAllLevel;
int numCoins;

//temporary storage of player lives
int temp = 0;

//level
int level = 1;

//initialize them in setup().
void setup(){
  size(800,600);
  imageMode(CENTER);
  
  // create Player object 
  p = loadImage("player.png"); 
  player = new Player(p, 0.8); 
  player.setBottom(GROUND_LEVEL); 
  player.center_x = 100;  
  
  platforms = new ArrayList<Sprite>();
  coins = new ArrayList<Sprite>();
  player.change_x = 0;
  player.change_y = 0;
  
  numCoins = 0; 
  isGameOver = false; 
  
  
  //load images
  gold = loadImage("gold1.png");
  red_brick = loadImage("red_brick.png");
  snow = loadImage("snow.png");
  crate = loadImage("crate.png");
  brown_brick = loadImage("brown_brick.png");
  spider = loadImage("spider_walk_right1.png");
  createPlatforms("map.csv");
  
  view_x = 0; 
  view_y = 0; 
  
  //update player lives
  player.lives = player.lives-temp;
}

void setup2(){
  size(800,600);
  imageMode(CENTER);
  
  // create Player object 
  p = loadImage("player.png"); 
  player = new Player(p, 0.8); 
  player.setBottom(GROUND_LEVEL); 
  player.center_x = 100;  
  
  platforms = new ArrayList<Sprite>();
  coins = new ArrayList<Sprite>();
  player.change_x = 0;
  player.change_y = 0;
  
  numCoins = 0; 
  isGameOver = false; 
  
  
  //load images
  gold = loadImage("gold1.png");
  red_brick = loadImage("red_brick.png");
  snow = loadImage("snow.png");
  crate = loadImage("crate.png");
  brown_brick = loadImage("brown_brick.png");
  spider = loadImage("spider_walk_right1.png");
  createPlatforms("map2.csv");
  
  view_x = 0; 
  view_y = 0; 
  
  //update player lives
  player.lives = player.lives-temp;
}


// modify and update them in draw().
void draw(){
  background(255);
  
  // scroll needs to be the first method called
  scroll();
  
  // display objects
  displayAll(); 
  
  // update objects 
  if(!isGameOver) {
    updateAll(); 
    collectCoins(); 
    checkDeath(); 
    checkEndGame();
  }
}

void displayAll() {
  for(Sprite platform: platforms)
    platform.display();
    
  for(Sprite coin: coins){
    coin.display();
  }
    
  player.display();
  enemy.display();
  
  fill(255, 0, 0); 
  textSize(32); 
  text("Coin:" + numCoins, view_x + 50, view_y + 50); 
  text("Lives:" + player.lives, view_x + 50, view_y + 100);
  text("Level: " + level, view_x + 50, view_y + 150);
  
  if(isGameOver) { 
    fill(0, 0, 255); 
    text("GAME OVER", view_x + width/2 - 100, view_y + height/2); 
    if(player.lives == 0) 
      text("You lose!", view_x + width/2 - 100, view_y + height/2 + 50); 
    else if(finishedAllLevel)
      text("You win!", view_x + width/2 - 100, view_y + height/2 + 50); 
    else
      text("You win!", view_x + width/2 - 100, view_y + height/2 + 50); 
    text("Press SPACE to restart!", view_x + width/2 - 100, view_y + height/2 + 100); 
  }
}

void updateAll() {
  resolvePlatformCollision(player, platforms);
  enemy.update();
  enemy.updateAnimation();
  player.updateAnimation(); 
  
  for (Sprite coin: coins) {
    ((AnimatedSprite)coin).updateAnimation();
  }
  
  collectCoins(); 
  checkDeath(); 
  checkEndGame();
}

void checkDeath() {
  boolean collideEnemy = checkCollision(player, enemy); 
  boolean fallOffCliff = player.getBottom() > GROUND_LEVEL; 
  if (collideEnemy || fallOffCliff) {
    temp++;
    if(level==1)
      setup();
     else
      setup2();
    if (player.lives == 0) {
      isGameOver = true; 
    }
    else {
      player.center_x = 100; 
      player.setBottom(GROUND_LEVEL); 
    }
  }
}

void checkEndGame(){
  finishedAllLevel = level>2;
  if(finishedAllLevel)
    isGameOver = true;
}
  

void collectCoins() {
  ArrayList<Sprite> coin_list = checkCollisionList(player, coins); 
  if(coin_list.size() > 0) {
    for(Sprite coin: coin_list) {
      numCoins++; 
      coins.remove(coin); 
    }
  }
  // collect all coins to win! 
  if(coins.size() == 0) {
    //isGameOver = true; 
    level++;
    setup2();
  }
}

// scroll
void scroll(){
  float right_boundary = view_x + width - RIGHT_MARGIN;
  if(player.getRight() > right_boundary){
    view_x += player.getRight() - right_boundary;
  }
  float left_boundary = view_x + LEFT_MARGIN;
  if(player.getLeft() < left_boundary){
    view_y -= player.getLeft() - left_boundary;
  }
  float top_boundary = view_y + VERTICAL_MARGIN;
  if(player.getTop() < top_boundary){
    view_y -= top_boundary - player.getTop();
  }
  float bottom_boundary = view_y + height - VERTICAL_MARGIN;
  if(player.getBottom() > bottom_boundary){
    view_y += player.getBottom() - bottom_boundary;
  }
  translate(-view_x,-view_y);
}

//jump
public boolean isOnPlatforms(Sprite s, ArrayList<Sprite> walls){
  s.center_y += 5;
  ArrayList<Sprite> col_list = checkCollisionList(s, walls); 
  s.center_y -= 5;
  if(col_list.size() > 0){
    return true;
  }
  else{
    return false;
  }
}

//collision
public void resolvePlatformCollision(Sprite s, ArrayList<Sprite> walls){
  //add gravity to change_y of sprite
  s.change_y += GRAVITY;
  
  
  //move in y-direction by adding change_y to center_y to update y position.
  s.center_y += s.change_y;
  
  // Now resolve any collision in the y-direction:
  // compute collision_list between sprite and walls(platforms).
  ArrayList<Sprite> col_list = checkCollisionList(s, walls);
 
  if(col_list.size() > 0){
    Sprite collided = col_list.get(0);
    if(s.change_y > 0){
      s.setBottom(collided.getTop());
    }
    else if(s.change_y < 0){
      s.setTop(collided.getBottom());
    }
    s.change_y = 0;
  }

  //move in x-direction by adding change_x to center_x to update x position.
  s.center_x += s.change_x;
  
  //Now resolve any collision in the x-direction:
  //compute collision_list between sprite and walls(platforms).   
  col_list = checkCollisionList(s, walls);

  if(col_list.size() > 0){
    Sprite collided = col_list.get(0);
    if(s.change_x > 0){
        s.setRight(collided.getLeft());
    }
    else if(s.change_x < 0){
        s.setLeft(collided.getRight());
    }
  }  
}

boolean checkCollision(Sprite s1, Sprite s2){
  boolean noXOverlap = s1.getRight() <= s2.getLeft() || s1.getLeft() >= s2.getRight();
  boolean noYOverlap = s1.getBottom() <= s2.getTop() || s1.getTop() >= s2.getBottom();
  if(noXOverlap || noYOverlap)
    return false;
  else 
    return true;
}
public ArrayList<Sprite> checkCollisionList(Sprite s, ArrayList<Sprite> list){
  ArrayList<Sprite> collision_list = new ArrayList<Sprite>();
  for(Sprite p: list){
    if(checkCollision(s, p))
      collision_list.add(p);
  }
  return collision_list;
}

//platform
void createPlatforms(String fileName){
  String[] lines = loadStrings(fileName);
  for(int row = 0; row<lines.length;row++){
    String[] values = split(lines[row], ",");
    for(int col = 0; col<values.length;col++){
      if(values[col].equals("1")){
        Sprite s = new Sprite(red_brick, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("2")){
        Sprite s = new Sprite(snow, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("3")){
        Sprite s = new Sprite(brown_brick, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("4")){
        Sprite s = new Sprite(crate, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("5")){
        Coin c = new Coin(gold, SPRITE_SCALE);
        c.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        c.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        coins.add(c);
      }
      else if(values[col].equals("6")){
        float bLeft = col * SPRITE_SIZE;
        float bRight = bLeft + 4 * SPRITE_SIZE;
        enemy = new Enemy(spider, 50/72.0, bLeft, bRight);
        enemy.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        enemy.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
      }
    }
  }
}

//called whenever a key is pressed
void keyPressed(){
  if(keyCode == RIGHT){
    player.change_x = MOVE_SPEED;
  }
  else if(keyCode == LEFT){
    player.change_x = -MOVE_SPEED;
  }
  else if(keyCode == UP && isOnPlatforms(player, platforms)){
    player.change_y = -JUMP_SPEED;
  }
  else if(isGameOver && key == ' ') {
    temp = 0; 
    setup();  
  }
}

//called whenever a key is released
void keyReleased(){
  if(keyCode == RIGHT){
    player.change_x=0;
  }
  else if(keyCode == LEFT){
    player.change_x=0;
  }
  else if(keyCode == UP){
    player.change_y=0;
  }
  //else if(keyCode == DOWN){
  //  player.change_y=0;
  //}
}
