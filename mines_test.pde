int cell_count = 100;
float density = 0.5;
int x, y;
boolean[][][] temp_2 = new boolean[2][][];
boolean ai_step = false;
boolean ai_lock = false;
int difficulty;
Field field = new Field(10, 10);
nonosolver edison;
int seed = 0;

void setup() {
  field.populate(1, seed);
  field.update_clues();
  //size(900 , 900);
  fullScreen(P2D);
  frameRate(60);
  background(0);
  edison = new nonosolver();
  start_board(cell_count, density);
}


void start_board(int count, float den) {
  cell_count = count;
  density = den;
  field = null;
  x = round(1.333333333 * sqrt(cell_count));
  y = round((cell_count)/float(x));
  //x = round(1 * sqrt(cell_count));
  //y = round((cell_count)/float(x));

  field = new Field(x, y);
  field.populate(round(cell_count * density), seed);
  field.update_clues();
}



void draw() {
  background(0);
  field.show(0, 0, 1920, 1080);
  fill(0, 190, 0);
  text(seed, width - 200, height -100);
  text(difficulty, width - 200, height -200);
  fill(0, 190, 190);
  text(cell_count, width - 400, height - 100);
  text(int(density * 100), width - 550, height - 100);
}

int step_i;
int loop = 0;
void keyPressed() {
  int j;
  if (key == '+') cell_count += 10;
  if (key == '-') cell_count -= 10;
  if (key == '*') density += 0.01;
  if (key == '/') density -= 0.01;
  if (key == 'e') {
    ai_lock = true;
    ai_step = true;
    thread ("ai_solver");
  }

  if (key == 'f') {
    ai_lock = false;
    ai_step = false;
    thread ("ai_solver");
  }
  if (key == 'q') edison.save_state(field.grid_2, field.grid_3, field.grid_size_x, field.grid_size_y);
  if (key == 'w') {
    field.restore(edison.restore_state(field.grid_size_x, field.grid_size_y));
  }
  if (key == 'a') edison.print_last_save();

  if (key == 'p') ai_step = true;
  if (key == 'o') field.show_solution ^= true;


  //  if (key == 's') {
  //    if (loop == 0) {
  //      if (step_i == field.grid_size_y) {
  //      loop = 1;
  //      step_i=0;
  //      } else {
  //        j=step_i;
  //     field.act_row(j,edison.line_solver(field.row(j), field.row_clues[j]));
  //       step_i++;
  //      }
  //    }
  //  if (loop == 1) {
  //    if (step_i == field.grid_size_x) {
  //      loop = 0;
  //      step_i = 0;
  //      } else {
  //        j = step_i;
  //     field.act_col(j,edison.line_solver(field.col(j), field.col_clues[j]));
  //     step_i++;
  //      }
  //  }
  //}
}

void ai_solver() {
  difficulty = 0;
  boolean a;
  boolean run;
  edison.restore_point = 0;
  boolean[] temp = new boolean[2];
  boolean[][][] temp_2 = new boolean[2][][];
  do {
    do {
      run = false;
      //println("ai");
      for (int i=0; i < field.grid_size_y; i++) {
        if (ai_step == true) {
          //print("ai_x");
          temp = field.act_row(i, edison.line_solver(field.row(i), field.row_clues[i]));
          if (temp[0] == true) difficulty++;
          if (temp[0] == true && ai_lock == false) {
            field.last_ai_col = true;
            field.last_ai_i = i;
            ai_step=false;
          }
          if (temp[0] == true && run == false) {
            run = true;
          }
          if (temp[1] == false) {
            //println("oh shit row! "+i+" "+edison.restore_point);
            if (edison.restore_point == -1) { 
              return;
            }
            //println("restored state"+edison.restore_point);
            field.restore(edison.restore_state(field.grid_size_x, field.grid_size_y));
          }
        } else i--;
        print();
      }
      for (int i=0; i < field.grid_size_x; i++) {
        if (ai_step == true) {
          //print("ai_y");
          //ai_step = false;
          temp = field.act_col(i, edison.line_solver(field.col(i), field.col_clues[i]));
          if (temp[0] == true) difficulty++;
          if (temp[0] == true && ai_lock == false) {
            ai_step=false;
            field.last_ai_col = false;
            field.last_ai_i = i;
          }
          if (temp[0] == true && run == false) {
            run = true;
          }
          if (temp[1] == false) {
            //println("oh shit col! "+i+" "+edison.restore_point);
            if (edison.restore_point == -1) { 
              return;
            }
            //println("restored state"+edison.restore_point);
            field.restore(edison.restore_state(field.grid_size_x, field.grid_size_y));
          }
        } else i--;
        print();
      }
    } while (run == true);
    run = false;
    if (field.board_finished() == false) {
      for (int i = 0; i<field.grid_size_x; i++) {
        for (int j=0; j<field.grid_size_y; j++) {
          if (field.grid_2[i][j] == false && field.grid_3[i][j] == false) {
            field.grid_2[i][j] = true;
            field.grid_3[i][j] = false;
            //println("saved state"+edison.restore_point);
            edison.save_state(field.grid_2, field.grid_3, field.grid_size_x, field.grid_size_y);
            field.grid_2[i][j] = false;
            field.grid_3[i][j] = true;
            run = true;
            break;
          }
        }
        if (run == true) break;
      }
    } else return;
  } while (null == null);
  print ("ai_end");
}

void mousePressed() {
  field.click(mouseX, mouseY);
  if (field.board_finished() == true) {
    //cell_count += 10;
    seed++;
    start_board(cell_count, density);
  }
  if (mouseX > width - 200 && mouseY > height - 100) {
    start_board(cell_count, density);
    //println("---New--Game---");
  }
  //if (field.dead == true) {
  // start_board(cell_count, density);
  //}
}

void mouseDragged() {
  field.click(mouseX, mouseY);
  if (field.board_finished() == true) {
    //cell_count += 10;
    start_board(cell_count, 0.2);
    field.last_click_action = 7;
  }
  //if (field.dead == true) {
  // start_board(cell_count, density);
  //}
}



void mouseReleased() {
  field.unclick();
}
