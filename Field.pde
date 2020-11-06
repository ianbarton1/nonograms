class Field{
int grid_size_x;
int grid_size_y;
int clue_length_x;
int clue_length_y;
float sf_x;
float sf_y;
float sf_z;
//the grid data
//the solution grid
boolean grid[][];
//the proposed solution grid
boolean grid_2[][];
//state grid
boolean grid_3[][];
boolean grid_4[][];
String clue_rows[];
String clue_columns[];
String clue_rows_2[];
String clue_columns_2[];
IntList[] lines_x;
IntList[] lines_y;
int[][] row_clues;
int[][] col_clues;
boolean show_solution = false;

int last_ai_i = -1;
boolean last_ai_col = false;

int mines_count;
int start_x, start_y, end_x, end_y;
int last_click_x = -1, last_click_y = -1;
int last_click_action;
boolean dead;

Field (int x, int y){
grid_size_x = x;
grid_size_y = y;
grid = new boolean [grid_size_x][grid_size_y];
grid_2 = new boolean[grid_size_x][grid_size_y];
grid_3 = new boolean [grid_size_x][grid_size_y];
grid_4 = new boolean [grid_size_x][grid_size_y];
clue_rows = new String[grid_size_y];
clue_columns = new String[grid_size_x];
clue_rows_2 = new String[grid_size_y];
clue_columns_2 = new String[grid_size_x];
lines_x = new IntList[grid_size_y];
lines_y = new IntList[grid_size_x];
row_clues = new int[grid_size_y][];
col_clues = new int[grid_size_x][];
update_clues();
update_clues_1();
dead = false;
}

int[] row(int i) {
  int[] result = new int[grid_size_x];
 for (int j=0; j<  grid_size_x; j++) {
  if (grid_2[j][i] == true) result[j] = 1;
  else if (grid_3[j][i] == true) result[j] = -1;
  else result[j] = 0;   
 }
 return result;
}

int[] col(int i) {
  int[] result = new int[grid_size_y];
 for (int j=0; j<  grid_size_y; j++) {
  if (grid_2[i][j] == true) result[j] = 1;
  else if (grid_3[i][j] == true) result[j] = -1;
  else result[j] = 0;   
 }
 return result;
}

boolean[] act_row(int i, int[] action) {
  boolean action_taken = false;
  boolean line_valid = true;
  boolean[] results = new boolean[2];
  if (action[0] == -2) {
   results[0] = false;
   results[1] = false;
    return results;
  }
  
  for (int j=0; j<  grid_size_x; j++) {
  if (action[j] == -1 && grid_3[j][i] == false) {
    grid_2[j][i] = false;
    grid_3[j][i] = true;
    action_taken = true;
    //delay(100);
  }
  else if (action[j] == 1 && grid_2[j][i] == false) {
    grid_2[j][i] = true;
    grid_3[j][i] = false;
    action_taken = true;
    //delay(100);
  }  
 }
 update_clues_1();
 results[0] = action_taken;
 results[1] = true;
 return results;
}

boolean[] act_col(int i, int[] action) {
  boolean action_taken = false;
  boolean line_valid = true;
  boolean[] results = new boolean[2];
  if (action[0] == -2) {
   results[0] = false;
   results[1] = false;
    return results;
  }
  for (int j=0; j<  grid_size_y; j++) {
  if (action[j] == -1 && grid_3[i][j] == false) {
    grid_2[i][j] = false;
    grid_3[i][j] = true;
    action_taken = true;
    //delay(100);
  }
  else if (action[j] == 1 && grid_2[i][j] == false) {
    grid_2[i][j] = true;
    grid_3[i][j] = false;
    action_taken = true;
    //delay(100);
  }  
 }
 update_clues_1();
 results[0] = action_taken;
 results[1] = true;
 return results;
}

void restore(boolean[][][] restore_data) {
  for (int i = 0; i< restore_data[0].length; i++) {
   for (int j = 0; j< restore_data[0][0].length; j++) {
       grid_2[i][j] = restore_data[0][i][j];
       grid_3[i][j] = restore_data[1][i][j];
   }
  }
}

void populate(int mine_count, int seed) {
mines_count = mine_count;
randomSeed(seed);
float p = mine_count / float(grid_size_x * grid_size_y);
// set all cells to false
for (int i=0; i<grid_size_x; i++) {
 for (int j=0; j<grid_size_y; j++) { 
  grid[i][j] = false;
  grid_2[i][j] = false;
  grid_3[i][j] = false;
  grid_4[i][j] = false;
 }
 }
//place mines according to probability  
for (int i=0; i<grid_size_x; i++) {
 for (int j=0; j<grid_size_y; j++) { 
  if (random(1.00) < p) {
    grid[i][j] = true;
  }
 }
 }
 for (int i=0; i<grid_size_x; i++) {
   col_clues[i] = null;
 }
 
  for (int i=0; i<grid_size_y; i++) {
   row_clues[i] = null;
 }
 
 
}
    
void populate_old(int mine_count) {
mines_count = mine_count;
//initialise a counter for mines placed  
int mines_placed = 0;
// set all cells to false
for (int i=0; i<grid_size_x; i++) {
 for (int j=0; j<grid_size_y; j++) { 
  grid[i][j] = false;
  grid_2[i][j] = false;
  grid_3[i][j] = false;
  grid_4[i][j] = false;
 }
 }
 
 
//place mines according to probability  
while (mines_placed < mine_count) {
for (int i=0; i<grid_size_x; i++) {
 for (int j=0; j<grid_size_y; j++) { 

  if ((grid[i][j] == false) && (mines_placed < mine_count)) {
    int a = int(random(grid_size_x * grid_size_y + 1));
  if (a < mine_count) {
    grid[i][j] = true;
    mines_placed++;
  }
  }
 }
 }
}
}

void update_clues(){
  int count;
  clue_length_x =0;
  clue_length_y =0;
  String clue_string = "";
  
  //update the clues for the columns
  for (int i=0; i < grid_size_x; i++) {
  clue_string = "";
  count = 0;
  //println(i);
  lines_y[i] = null;
  lines_y[i] = new IntList();
    for (int j=0; j < grid_size_y; j++) {
  if (grid[i][j] == true){
    count++;
  }
  if (grid[i][j] == false && count > 0) {
   clue_string = clue_string.concat(String.valueOf(count))+ "\n";
  lines_y[i].append(count); 
  count = 0;
  }
    }
   if (count > 0) {
     clue_string = clue_string.concat(String.valueOf(count))+"\n";
     lines_y[i].append(count);
   }
   clue_columns[i] = clue_string;
   col_clues[i] = lines_y[i].array();
   //println("col: "+i+":"+col_clues[i].length);
   if (clue_columns[i].length() > clue_length_y) clue_length_y = clue_columns[i].length();
   }
   
    //update the clues for the rows
   for (int j=0; j < grid_size_y; j++) {
  clue_string = "";
  count = 0;
    lines_x[j] = null;
    lines_x[j] = new IntList();
    for (int i=0; i < grid_size_x; i++) {
  if (grid[i][j] == true){
    count++;
  }
  if (grid[i][j] == false && count > 0) {
 clue_string = clue_string.concat(String.valueOf(count))+" ";
 lines_x[j].append(count);
  count = 0;
  }
    }
   if (count > 0) { 
   clue_string = clue_string.concat(String.valueOf(count))+" ";
   lines_x[j].append(count);
   }
   clue_rows[j] = clue_string;
   row_clues[j] = lines_x[j].array();
   //println("row "+j+":"+row_clues[j].length);
    }
}

void show_line(int i) {
  int f = lines_x[i].size();
 for (int j =0; j<f; j++) {
  //print(lines_x[i].get(j)+","); 
 }
  //println();
}

boolean strict_death(int i, int j) {
  return grid[i][j];  
}


boolean logic_death_row(int row_id){
  return false;
}

boolean logic_death_column(int column_id) {
  return false;
  
}

void update_clues_1(){
  int count;
  String clue_string = "";
  
  //update the clues for the columns
  for (int i=0; i < grid_size_x; i++) {
  clue_string = "";
  count = 0;
    for (int j=0; j < grid_size_y; j++) {
  if (grid_2[i][j] == true){
    count++;
  }
  if (grid_2[i][j] == false && count > 0) {
 clue_string = clue_string.concat(String.valueOf(count))+ "\n";
  count = 0;
  }
    }
   if (count > 0)  clue_string = clue_string.concat(String.valueOf(count))+"\n";
   clue_columns_2[i] = clue_string;
   }
    
    //update the clues for the rows
   for (int j=0; j < grid_size_y; j++) {
  clue_string = "";
  count = 0;
    for (int i=0; i < grid_size_x; i++) {
  if (grid_2[i][j] == true){
    count++;
  }
  if (grid_2[i][j] == false && count > 0) {
 clue_string = clue_string.concat(String.valueOf(count))+" ";
  count = 0;
  }
    }
   if (count > 0)  clue_string = clue_string.concat(String.valueOf(count))+" ";
   clue_rows_2[j] = clue_string;
    }
}

boolean row_check(int i){
 return clue_rows[i].equals(clue_rows_2[i]);
}

boolean column_check(int i){
 return clue_columns[i].equals(clue_columns_2[i]);
}

boolean board_finished(){
for (int j=0; j < grid_size_y; j++) {
  if (row_check(j) == false) return false;
}
for (int j=0; j < grid_size_x; j++) {
  if (column_check(j) == false) return false;
}

for (int i=0; i < grid_size_x; i++) {
  for (int j=0; j < grid_size_y; j++) {
   if (grid_3[i][j] == false && grid_2[i][j] == false) return false;   
  }
}

return true; 
}

void show(int sx, int sy, int ex, int ey) {
  int o=255;
 if (show_solution == true) o = 0;
start_x = sx;
start_y = sy;
sf_x = grid_size_x / float(grid_size_x + clue_length_x / 2);
sf_y = grid_size_y / float(grid_size_y + clue_length_y / 2);
sf_z = min(sf_x, sf_y);
end_x = ex;
end_y = ey;
noFill();
stroke(255);
for (int i=0; i < grid_size_x; i++) {
  for (int j=0; j < grid_size_y; j++) {
    if (grid[i][j] == true && grid_2[i][j]== true || grid[i][j] == false && grid_3[i][j]== true) fill(0,255,0,255-o);
    else if (grid_3[i][j] == false && grid_4[i][j] == false) fill (0,0,0,255-o);
    else fill(255,0,0,255-o);
      pushMatrix();
      scale(sf_z);
      translate(sx + (ex-sx)/float(grid_size_x) * i,sy + (ey-sy)/float(grid_size_y) * j);
      rect(0,0, (ex-sx) / float(grid_size_x), (ey-sy) / float(grid_size_y));
      popMatrix();
    
    
    
    if (grid_2[i][j] == true) fill(255,0,0,o); else fill(0,0,0,o); 
    if (grid_4[i][j] == true) fill(128,128,0,o);  
    if (grid_3[i][j] == true) fill(0,192,0,o);
  pushMatrix();
  scale(sf_z);
  translate(sx + (ex-sx)/float(grid_size_x) * i,sy + (ey-sy)/float(grid_size_y) * j);
  rect(0,0, (ex-sx) / float(grid_size_x), (ey-sy) / float(grid_size_y));
  popMatrix();
    }
}

for(int i=0; i<grid_size_x; i++) {
  if (last_ai_col == false && last_ai_i == i) fill(255,255,0);
  else {
if (column_check(i) == true) fill(0,255,0); else fill(255,0,0);
  }
 textSize((ex-sx)/float(grid_size_x)*0.5);
 textAlign(LEFT,TOP);
 pushMatrix();
   scale(sf_z);
  translate(sx + (ex-sx)/float(grid_size_x) * i,ey);
  text(clue_columns[i],0,0);
 popMatrix();  
}

for(int i=0; i<grid_size_y; i++) {
    if (last_ai_col == true && last_ai_i == i) fill(255,255,0);
    else {
if (row_check(i) == true) fill(0,255,0); else fill(255,0,0);
    }
 textSize((ey-sy)/float(grid_size_y)*0.5);
 textAlign(LEFT,TOP);
 pushMatrix();
    scale(sf_z);
  translate(ex,sy + (ey-sy)/float(grid_size_y) * i);
  text(clue_rows[i],0,0);
 popMatrix();  
}

}

void click(int mx, int my){
  mx /= sf_z;
  my /= sf_z;
  //if our mouse press was outside of the bounds of the play field then we should do nothing and just get exit immediately.
 
  if (mx < start_x || mx > end_x || my < start_y || my > end_y) return;
  int i = int(((mx - start_x) / float(end_x - start_x)) * grid_size_x);
  int j = int(((my - start_y) / float(end_y - start_y)) * grid_size_y);
  if (last_click_x == i && last_click_y == j) return;
  last_click_x = i;
  last_click_y = j;
  i = constrain(i, 0, grid_size_x-1);
  j = constrain(j, 0, grid_size_y-1);
 if (mouseButton == RIGHT) { 
      if (grid_4[i][j] == false && grid_2[i][j] == false && grid_3[i][j] == false && (last_click_action == 1 || last_click_action == 0)) {
    grid_4[i][j] = true;
    last_click_action = 1;
   }
    if (grid_2[i][j] == false && grid_3[i][j] == false && grid_4[i][j] == true && (last_click_action == 2 || last_click_action == 0)) {
    grid_4[i][j] = false;
    grid_2[i][j] = true;
    update_clues_1();
    last_click_action = 2;
   }
   
    if (grid_2[i][j] == true && grid_3[i][j] == false && (last_click_action == 3 || last_click_action == 0)) {
    grid_4[i][j] = false;
    grid_2[i][j] = false;
    update_clues_1();
    last_click_action = 3;
   } 
   
   
   
 }
 
 
 if (mouseButton == LEFT) {
      //println(last_click_action);

   if  ((grid_2[i][j] == false) && (grid_4[i][j] == false)  && (grid_3[i][j] == true) && (last_click_action == 4 || last_click_action == 0)) {
grid_3[i][j] ^= true;
grid_4[i][j] = false;
last_click_action = 4;
   }
   if  ((grid_2[i][j] == false) && (grid_4[i][j] == false) && (grid_3[i][j] == false) && (last_click_action == 5 || last_click_action == 0)) {
grid_3[i][j] ^= true;
grid_4[i][j] = false;
last_click_action = 5;
if (grid[i][j] == true) dead = true;
   }

  
   if  ((grid_2[i][j] == false) && (grid_4[i][j] == true) && (last_click_action == 6 || last_click_action == 0)) {
grid_4[i][j] = false;
last_click_action = 6;
  }  
   
 }
  
}

void unclick() {
 last_click_x = -1;
 last_click_y = -1;
 last_click_action = 0;
}

}
