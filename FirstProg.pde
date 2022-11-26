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
Sprite p;
PImage snow, red_brick, crate, brown_brick, gold, spider;
ArrayList<Sprite> platforms;
ArrayList<Sprite> coins;
Enemy enemy;

//int numCoins;

float view_x = 0;
float view_y = 0;

//initialize them in setup().
void setup(){
  size(800,600);
  imageMode(CENTER);
  p = new Sprite("data/player.png", 1.0, 400, 100);
  platforms = new ArrayList<Sprite>();
  coins = new ArrayList<Sprite>();
  p.change_x = 0;
  p.change_y = 0;
  
  //load images
  gold = loadImage("gold1.png");
  red_brick = loadImage("red_brick.png");
  snow = loadImage("snow.png");
  crate = loadImage("crate.png");
  brown_brick = loadImage("brown_brick.png");
  spider = loadImage("spider_walk_right1.png");
  
  createPlatforms("map.csv");
}
//modify and update them in draw().
void draw(){
  background(0,255,0);
  
  //scroll needs to be the first method called
  scroll();
  p.display();
  resolvePlatformCollision(p, platforms);
  
  for(Sprite s: platforms)
    s.display();
  for(Sprite c: coins){
    c.display();
    ((AnimatedSprite)c).updateAnimation();
  }
  //collectCoins();
  //fill(255,0,0);
  //textSize(32);
  //text("Coins: " + numCoins, 50, 50);
  
  enemy.display();
  enemy.update();
  enemy.updateAnimation();
}
//scroll
void scroll(){
  float right_boundary = view_x + width - RIGHT_MARGIN;
  if(p.getRight() > right_boundary){
    view_x+= p.getRight() - right_boundary;
  }
  float left_boundary = view_x + LEFT_MARGIN;
  if(p.getLeft() < left_boundary){
    view_y-= p.getLeft() - left_boundary;
  }
  float top_boundary = view_y + VERTICAL_MARGIN;
  if(p.getTop() < top_boundary){
    view_y-= top_boundary - p.getTop();
  }
  float bottom_boundary = view_y + height - VERTICAL_MARGIN;
  if(p.getBottom() > bottom_boundary){
    view_y+= p.getBottom() - bottom_boundary;
  }
  translate(-view_x,-view_y);
}

//jump
public boolean isOnPlatforms(Sprite s, ArrayList<Sprite> walls){
  s.center_y+=5;
  ArrayList<Sprite> col_list = checkCollisionList(s, walls); 
  s.center_y-=5;
  if(col_list.size()>0){
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
    p.change_x= MOVE_SPEED;
  }
  else if(keyCode == LEFT){
    p.change_x=-MOVE_SPEED;
  }
  else if(keyCode == UP){
    p.change_y=-JUMP_SPEED;
  }
  else if(keyCode == DOWN){
    p.change_y=MOVE_SPEED;
  }
}
//called whenever a key is released
void keyReleased(){
  if(keyCode == RIGHT){
    p.change_x=0;
  }
  else if(keyCode == LEFT){
    p.change_x=0;
  }
  else if(keyCode == UP){
    p.change_y=0;
  }
  else if(keyCode == DOWN){
    p.change_y=0;
  }
}
