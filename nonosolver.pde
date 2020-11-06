class nonosolver {
int line_length;
int rule_length;
int[] line;
int[] rule;
int[] pos;
int[] solid;
boolean[] alive;
int[] pos_bak;
int[] solid_bak;
boolean[] alive_bak;
int current_block;
int[] belief;
boolean init_status;
int restore_point = 0;
boolean[][][] save_2 = new boolean[1000][100][100];
boolean[][][] save_3 = new boolean[1000][100][100];



void backup_blocks() {
 for (int i=0; i < rule_length; i++) {
  pos_bak[i] = pos[i];
  solid_bak[i] = solid[i];
  alive_bak[i] = alive[i];
 }
}


void recover_blocks() {
 for (int i=0; i < rule_length; i++) {
  pos[i] = pos_bak[i];
  solid[i] = solid_bak[i];
  alive[i] = alive_bak[i];
 }
}
  
int[] line_solver(int[] line_, int[] rule_) {
    //set all variables for the line
    line = line_;
    rule = rule_;
    line_length = line.length;
    rule_length = rule.length;
    pos = new int[rule_length];
    solid = new int[rule_length];
    alive = new boolean[rule_length];
        pos_bak = new int[rule_length];
    solid_bak = new int[rule_length];
    alive_bak = new boolean[rule_length];
    current_block = 0;
    belief = new int[line_length];
    boolean blocks = blocks_init(true);
    //show_blocks();
    boolean orphan = orphan_fix();
    if (blocks == false || orphan == false) {
      belief[0] = -2;
      return belief;
    }
    set_belief();
    //println("start belief");
    //show_belief();
    if (rule_length == 0) return belief;
    do{
      routine_a();
      if (routine_b() == false) break;
    } while (null == null);
    //println("final belief");
   //show_belief();
    return belief;
    }  
  
void update_belief_all() {
  int cur_block = 0;
  for (int i = 0; i < line_length; i++) {
   if (cur_block < rule_length && i >= pos[cur_block]+rule[cur_block]) cur_block++;
   if (cur_block < rule_length && i >= pos[cur_block] && i < pos[cur_block]+rule[cur_block]){
     if (belief[i] == -1) belief[i] = 0;
   } else if (belief[i] == 1) belief[i] = 0;
  }
}
  
  //it is buggy at the the moment so i'm forcing belief update through the more forceful update_belief_all function
  void update_belief(int block_id) {
    update_belief_all();
    return;
    //if (pos[block_id] - 1 >=0 && belief[pos[block_id] - 1] == 1) belief[pos[block_id] - 1]=0;
    //if (pos[block_id] + rule[block_id] < line_length && belief[pos[block_id] + rule[block_id]] == 1) belief[pos[block_id] + rule[block_id]]=0;
    //for (int i = pos[block_id] ; i < pos[block_id]+rule[block_id]; i++) {
    // if (i >= 0 || i<line_length) {
    //   if (belief[i] == -1) belief[i] = 0;
    // }
    //}
  }
  
void set_belief() {
  int cur_block = 0;
  for (int i = 0; i < line_length; i++) {
   if (cur_block < rule_length && i >= pos[cur_block]+rule[cur_block]) cur_block++;
   if (cur_block < rule_length && i >= pos[cur_block] && i < pos[cur_block]+rule[cur_block]){
   belief[i] = 1;
   } else belief[i] = -1;
  }
}
  
  void routine_a() {
  int current_block = rule_length-1;
  do {
  if (alive[current_block] == true) {
  if (block_next_pos(current_block, true, 1, true) == false) {
    current_block--;
  } else {
    update_belief(current_block);
    //show_blocks();
  }
  } else {
    current_block--;
  }
  } while (current_block >= 0);
  }
  
   boolean routine_b() {
    println("routine b begin");
  int current_block = 0;
  boolean blocks, orphan;
  do {
  if (alive[current_block] == true) {
    backup_blocks();
    if (block_next_pos(current_block, false, 1, false) == false) {
      println("b_end");
      show_blocks();
      pos[current_block] = 0;
      blocks_init(false);
      alive[current_block] = false;
      current_block++;
      continue;
    } else {
      //show_blocks();
      backup_blocks();
      blocks = blocks_init(false);
      orphan = orphan_fix();
      println(blocks, orphan);
      if (blocks == true && orphan == true) {
      println("b_in:");
      show_blocks();
      update_belief_all();
      routine_a();
      recover_blocks();
      println("b_return:");
      show_blocks();
      //alive[current_block] = false;
      //current_block++;
      continue;
      } else {
       recover_blocks();
       pos[current_block] = 0;
       blocks_init(false);
       alive[current_block] = false;
       current_block++;
       continue;
      }
    }
  } else {
    current_block++;
  }
  } while (current_block < rule_length);
  return false;
  }

//prints line out to console
void show_line() {
 //for (int i = 0; i < line_length; i++) {
 // if (line[i] == 0) print("?");
 // else if (line[i] == -1) print ("-");
 // else if (line[i] == 1) print ("#");
 //}
 //println();
}

void show_belief() {
 //for (int i = 0; i < line_length; i++) {
 // if (belief[i] == 0) print("?");
 // else if (belief[i] == -1) print ("-");
 // else if (belief[i] == 1) print ("#");
 //}
 //println();
}

//shows all block information
void show_blocks() {
//  int cur_block = 0;
//for (int i = 0; i < line_length; i++) {
// //println("block: "+i+" at "+pos[i]+" until: "+(pos[i]+rule[i]-1)+" solid: "+solid[i]+" alive: "+alive[i]+" release: ",is_releaseable(i));
// if (cur_block < rule_length && i >= pos[cur_block]+rule[cur_block]) cur_block++;
// if (cur_block < rule_length && i >= pos[cur_block] && i < pos[cur_block]+rule[cur_block]){
//   if (alive[cur_block]== true) print('#'); else print('D');
// } else print("-");
//}
//println();
}

//places blocks in a default starting position by placing a block and moving it to the first valid position
//should return true when a valid config is found and false upon failure
boolean blocks_init(boolean first_run) {
  init_status = false;
  for (int i = 0; i < rule_length; i++) {
    if (i > 0) {
     if (pos[i] <= pos[i-1]+rule[i-1]) {
       init_status = true;
       pos[i] = pos[i-1]+rule[i-1]+1;
     }
    }
    if (first_run == true) {
    solid[i] = -1;
    alive[i] = true;
    }
    if (block_next_pos(i, false, 0, false) == false) return false;
    update_solid(i);
  }
  return true;
}

//starts from the right hand side of the line and finds solids without a block attempts to move a block
//should return true when it was successful and false when it failed to move a block
boolean orphan_fix() {
int working_block;
  for (int i = line_length-1; i >= 0; i--) {
     if (line[i] == 1) {
       working_block = lh_block(i);
       if (working_block == -1) return false;
       if (i > pos[working_block]+rule[working_block]) {
        //pos[working_block] = i-rule[working_block];
        if (block_next_pos(working_block, false, i-pos[working_block]-rule[working_block]+1, false) == false) return false;
        i++;
       }
     }
  }
  blocks_init(false);
  if (init_status == true) return orphan_fix();
  return true;
}

//returns the block to the left of an index WORKING
int lh_block(int index) {
  for (int i= rule_length-1; i >= 0; i--) {
   if (index >= pos[i]) return i; 
  }
  return -1;
}

//calculates a new solid offset only useful for large movements and no-solid respect move
void update_solid(int block_id) {
 for (int i = 0; i < rule[block_id]; i++) {
    if (line[pos[block_id]+i] == 1) {
     solid[block_id] = i;
     return;
    }
 }
 solid[block_id] = -1;
}

//tells you if a block is valid in a position
int block_valid(int offset, int rule_length) {
  if (offset < 0 || offset+rule_length-1 > line_length-1) return -1;
  if (offset-1 >= 0 && line[offset-1] == 1) return -1;
  if (offset+rule_length <= line_length-1 && line[offset+rule_length] == 1) return -1;
  for (int i=offset; i < offset + rule_length ; i++) {
    if (line[i] == -1) return -1;
  }
  return 0;
}

//tells you whether or not a block can be released a block can only be freed if a lower numbered block is free
//the above definition is WRONG! blocks can be released in some circumstances!! hacking it to be true all the time
boolean is_releaseable(int block_id) {
  return true;
  //for (int i = block_id; i >= 0; i--) {
  //  if (solid[i] == -1) return true;
  //}
  //return false;
}




//moves a block to its next valid position and if it can't find a valid position does nothing
//outputs true on success and false on failure
//takes a block id as input and respect_solid which when true will not allow blocks to leave behind a solid
boolean block_next_pos(int block_id, boolean respect_solid, int min_movement, boolean respect_other_blocks) {
  int block_pos = pos[block_id];
  int solid_pos = solid[block_id];
  int next_block;
  int move_count = 0;
  if (block_id == rule_length-1 || respect_other_blocks == false) {
     next_block = -1; 
  } else {
     next_block = pos[block_id+1] - (pos[block_id] + rule[block_id]); 
  }
  
  if (min_movement == 0 && block_valid(block_pos, rule[block_id]) == 0) return true;
  
  
  while (block_pos+rule[block_id]-1 < line_length-1) {
  block_pos += 1;
  next_block--;
  move_count++;
  if (next_block == 0) {
    if (alive[block_id+1] == false) alive[block_id] = false;
    break;
  }
  if (respect_solid == true && solid_pos == 0) {
    if (is_releaseable(block_id) == false) alive[block_id] = false;
    break;
  }
  solid_pos -= 1;
  if (block_valid(block_pos, rule[block_id]) == 0 && move_count >= min_movement) {
    pos[block_id] = block_pos;
    if (respect_solid == true) {
    solid[block_id] = max(-1,solid_pos);
    } else {
    update_solid(block_id);
    }
    return true;
  }
  }
  if (block_pos+rule[block_id]-1 == line_length-1) alive[block_id] = false;
  return false;
}

void save_state(boolean g1[][],boolean g3[][], int grid_x, int grid_y) {
  //println("saving state"+restore_point);
for (int i = 0; i< grid_x; i++) {
 for (int j = 0; j< grid_y; j++) {
     save_2[restore_point][i][j] = g1[i][j];
     save_3[restore_point][i][j] = g3[i][j];
 }
}
restore_point++;
}

boolean[][][] restore_state (int grid_x, int grid_y) {
    restore_point--;
    //println("restoring state"+restore_point);
  boolean[][][] temp = new boolean[2][grid_x][grid_y];
  for (int i = 0; i< grid_x; i++) {
    for (int j = 0; j< grid_y; j++) {
     temp[0][i][j] = save_2[restore_point][i][j];
     temp[1][i][j] = save_3[restore_point][i][j];
 }
}
  return temp;
}

void print_last_save(){
    //println(restore_point + "<="+save_2[restore_point][0][0]);
}

}
