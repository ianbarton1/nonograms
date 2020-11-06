# Nonogram Game
*note the code is nasty*
This is a processing 3 sketch that implements a binary nonogram game. The game features a solver as well.

# How to Use
        Please consult wikipedia for better explained rules of the game. You are presemted with a grid of tiles and some clues.
        The clues tell you how many red squares form a block.
        Example '1-2-1' means 1 red, ? green, 2 red, ? green, 1 red.
        
        Using logic it should be possible to deduce the layout of the board.
        The clues are by default red and will turn green when that row/column is 
        in a consistent state. The game is finished when all row/columns are consistent.
# Controls
        Mouse:
                Left-Click: Toggles a black square between green/black
                Right-Click: Toggles a black square between amber/red
                All mouse clicks can be held which will enable paint mode.
        Keyboard:
                '+': Increase the number of cells
                '-': Decreae the number of cells
                '*': Increase the percentage of red cells
                '/': Decrease the percentage of red cells
#Solver feature
        The solver should work although it can be quite slow, it was mainly added for fun.
                'e': Solve Board fully (note: the board must be in a valid starting state)
                'f': Start solver in step mode
                        'p': Tick solver one step at a time.
