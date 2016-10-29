#TODO:
#fix printing for larger boards
#implement a % counter (how many times you hit / missed)
#fix coord input for larger boards

import random

DEFAULT_SIZE = 10

SHIP_NONE = 0
SHIP_ALIVE = 1
SHIP_DEAD = 2

VIEW_WATER = 0
VIEW_HIT = 1
VIEW_MISS = 2

class Board:

    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.board_ships = [[0]*height for i in range(width)]
        self.board_view = [[0]*height for i in range(width)]
        self.ships = []
        
    def checkBounds(self, x, y):
        if x < 0 or x >= self.width:
            return False
        if y < 0 or y >= self.height:
            return False
        return True
    
    def getView(self, x, y):
        return self.board_view[x][y] if self.checkBounds(x, y) else VIEW_WATER

    def getShip(self, x, y):
        return self.board_ships[x][y] if self.checkBounds(x, y) else SHIP_NONE

    def getNumShips(self):
        return len(self.ships)

    def addShip(self, x, y):
        if self.checkBounds(x, y):
            if self.board_ships[x][y] != SHIP_ALIVE:
                self.board_ships[x][y] = SHIP_ALIVE
                self.ships.append([x, y])
                return True
        return False

    def addShips(self, x, dx, y, dy):
        #when you have to iterate twice because you have to check first
        for i in range(x, x + dx):
            for j in range(y, y + dy):
                if (not self.checkBounds(i, j)) or self.board_ships[i][j] == SHIP_ALIVE:
                    return False
        #ugh
        for i in range(x, x + dx):
            for j in range(y, y + dy):
                self.addShip(i, j)
        return True
        
    #Launches a missile at the specified position
    #return True if hit else False
    def missile(self, x, y):
        if not self.checkBounds(x, y):
            return False
        if self.board_ships[x][y] == SHIP_ALIVE: #hit a ship
            self.board_view[x][y] = VIEW_HIT
            self.board_ships[x][y] = SHIP_DEAD
            self.ships.remove([x, y])
            return True
        elif self.board_view[x][y] == VIEW_HIT: #targeted a previous hit
            return False
        else: #miss
            self.board_view[x][y] = VIEW_MISS
            return False

    #"Board[WxH]"
    def __str__(self):
        return "Board [" + str(self.width) + "x" + str(self.height) + "]"



def printView(board):
    #print column and row labels
    #print view using characters from getViewCharacter(x, y)

    #print header (column labels)
    s = " "
    for x in range(board.width):
        s = s + getColumnLetter(x)
    print s
    #print
    for y in range(board.height):
        s = getRowLetter(y) #row labels (TODO: constant width using str.zfill)
        for x in range(board.width):
            s = s + getViewCharacter(board, x, y)
        print s

def getColumnLetter(index):
    return chr(index + 65)

def getColumnIndex(letter):
    return ord(letter.upper()) - 65
##    if isinstance(letter, str):
##        return ord(letter.upper()) - 65
##    else:
##        return int(letter) - 65

def getRowLetter(index):
    return str(index)

def getRowIndex(letter):
    return int(letter)

#the characters used to represent the states of the view array
def getViewCharacter(board, x, y):
    v = board.getView(x, y)
    if v == VIEW_HIT:
        return "x"
    elif v == VIEW_MISS:
        return "o"
    else:
        return "~"

if __name__ == "__main__":
    # run console
    print "Starting battleship"
    #custom board size
    w = raw_input("Enter width (or blank for default of " + str(DEFAULT_SIZE) + "): ")
    try:
        w = int(w)
    except Exception:
        w = DEFAULT_SIZE
    print "Width: " + str(w)
    h = raw_input("Enter height (or blank for default of " + str(w) + "): ")
    try:
        h = int(h)
    except Exception:
        h = w
    print "Height: " + str(h)
    board = Board(w, h)
    #custom ship count
    c = raw_input("Enter number of ships (or blank for default of " + str(DEFAULT_SIZE) + "): ")
    try:
        c = int(c)
    except Exception:
        c = DEFAULT_SIZE
    print "Number of ships: " + str(c)
    d = c
    safety = 0
    #add the ships
    while d > 0:
        x = random.randrange(w)
        y = random.randrange(h)
        axis = random.randrange(2)
        dx = random.randrange(w/2) + 1 if axis == 1 else 1
        dy = random.randrange(h/2) + 1 if axis == 0 else 1
        if board.addShips(x, dx, y, dy):
            d -= 1
        else:
            safety += 1
        if safety > 10000: #10000 failures is a pretty reasonable number of attempts imo
            print "Failed to generate " + str(c) + " ships. Sorry :("
            break
    #start the game
    print str(board.getNumShips()) + " hits left!"
    print "Note: when launching missiles, specify column then row. Ex: 'A 4' or 'b7'"
    moves = 0
    while board.getNumShips() > 0:
        print
        printView(board)
        while True:
            line = raw_input("Launch a missile! Coordinates: ")
            print
            line2 = line.split(" ")
            if len(line2) > 1:
                line = line2
            try:
                column = getColumnIndex(line[0])
                row = getRowIndex(line[1])
                if board.missile(column, row):
                    print "It's a hit!"
                else:
                    print "You missed!"
                moves += 1
                if board.getNumShips() > 0:
                    print str(board.getNumShips()) + " hits left!"
                break
            except Exception:
                print "Invalid coordinates specified"
        if board.getNumShips() <= 0:
            #end game
            print
            print "You win!"
            print "It took you " + str(moves) + " moves."
